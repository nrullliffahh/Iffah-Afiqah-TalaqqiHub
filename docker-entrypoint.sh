#!/bin/sh
set -eu

TOMCAT_HOME="/usr/local/tomcat"
CONTEXT_DIR="${TOMCAT_HOME}/conf/Catalina/localhost"
CONTEXT_FILE="${CONTEXT_DIR}/ROOT.xml"

mkdir -p "${CONTEXT_DIR}"

HTTP_PORT="${PORT:-8080}"
SERVER_XML="${TOMCAT_HOME}/conf/server.xml"

# Kerocket injects PORT — bind Tomcat HTTP connector on all interfaces.
sed -i "s/port=\"8080\"/port=\"${HTTP_PORT}\"/" "${SERVER_XML}"
if ! grep -q 'address="0.0.0.0"' "${SERVER_XML}"; then
  sed -i "s/<Connector port=\"${HTTP_PORT}\"/<Connector address=\"0.0.0.0\" port=\"${HTTP_PORT}\"/" "${SERVER_XML}"
fi
echo "Tomcat HTTP connector listening on 0.0.0.0:${HTTP_PORT}"

escape_xml_attr() {
  printf '%s' "$1" | sed 's/&/\&amp;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

b64_encode() {
  printf '%s' "$1" | base64 | tr -d '\n'
}

JDBC_URL=""
DB_USER=""
DB_PASSWORD=""

# Prefer explicit JDBC vars from Kerocket env file (supports sslMode=REQUIRED for Aiven).
if [ -n "${DB_URL:-}" ]; then
  JDBC_URL="${DB_URL}"
  DB_USER="${DB_USER:-${MYSQLUSER:-${MYSQL_USER:-root}}}"
  DB_PASSWORD="${DB_PASSWORD:-${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}}"
fi

if [ -z "${JDBC_URL}" ] && [ -n "${DATABASE_URL:-}" ]; then
  case "${DATABASE_URL}" in
    jdbc:*)
      JDBC_URL="${DATABASE_URL}"
      DB_USER="${DB_USER:-${MYSQLUSER:-${MYSQL_USER:-}}}"
      DB_PASSWORD="${DB_PASSWORD:-${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}}"
      ;;
    mysql://*|mariadb://*)
      REST="${DATABASE_URL#*://}"
      USERINFO="${REST%%@*}"
      HOSTPART="${REST#*@}"
      DB_USER="${USERINFO%%:*}"
      DB_PASSWORD="${USERINFO#*:}"
      HOST="${HOSTPART%%/*}"
      PATH_AND_QUERY="${HOSTPART#*/}"
      DBNAME="${PATH_AND_QUERY%%\?*}"
      QUERY_PARAMS="${PATH_AND_QUERY#*\?}"
      if [ "${PATH_AND_QUERY}" = "${DBNAME}" ]; then
        QUERY_PARAMS=""
      fi
      HOST_ONLY="${HOST%%:*}"
      PORT_PART="${HOST#*:}"
      if [ "${HOST}" = "${HOST_ONLY}" ]; then
        PORT_PART="3306"
      fi
      if [ -n "${QUERY_PARAMS}" ]; then
        QUERY_PARAMS="$(printf '%s' "${QUERY_PARAMS}" | sed 's/ssl-mode=/sslMode=/g')"
        JDBC_URL="jdbc:mysql://${HOST_ONLY}:${PORT_PART}/${DBNAME}?${QUERY_PARAMS}&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true"
      else
        JDBC_URL="jdbc:mysql://${HOST_ONLY}:${PORT_PART}/${DBNAME}?sslMode=REQUIRED&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true"
      fi
      ;;
  esac
fi

if [ -z "${JDBC_URL}" ]; then
  MYSQLHOST="${MYSQLHOST:-${MYSQL_HOST:-}}"
  MYSQLDATABASE="${MYSQLDATABASE:-${MYSQL_DATABASE:-talaqqihub_db}}"
  MYSQLPORT="${MYSQLPORT:-${MYSQL_PORT:-3306}}"
  DB_USER="${DB_USER:-${MYSQLUSER:-${MYSQL_USER:-root}}}"
  DB_PASSWORD="${DB_PASSWORD:-${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}}"
  if [ -n "${MYSQLHOST}" ]; then
    JDBC_URL="jdbc:mysql://${MYSQLHOST}:${MYSQLPORT}/${MYSQLDATABASE}?sslMode=REQUIRED&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true"
  fi
fi

if [ -n "${JDBC_URL}" ]; then
  U="$(escape_xml_attr "$(printf '%s' "${DB_USER}")")"
  P="$(escape_xml_attr "$(printf '%s' "${DB_PASSWORD}")")"
  URL_XML="$(escape_xml_attr "$(printf '%s' "${JDBC_URL}")")"

  cat > "${CONTEXT_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context>
  <Resource name="jdbc/TalaqqiHubDB"
            auth="Container"
            type="javax.sql.DataSource"
            factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
            maxTotal="20"
            maxIdle="5"
            maxWaitMillis="10000"
            testOnBorrow="true"
            validationQuery="SELECT 1"
            username="${U}"
            password="${P}"
            driverClassName="com.mysql.cj.jdbc.Driver"
            url="${URL_XML}"/>
</Context>
EOF
  echo "Configured Tomcat JNDI datasource at ${CONTEXT_FILE} (user=${DB_USER:-<empty>}, host from DB_URL)"

  PROPFILE="${TOMCAT_HOME}/conf/talaqqihub-db.properties"
  {
    printf 'db.url.b64=%s\n' "$(b64_encode "${JDBC_URL}")"
    printf 'db.user.b64=%s\n' "$(b64_encode "${DB_USER}")"
    printf 'db.password.b64=%s\n' "$(b64_encode "${DB_PASSWORD}")"
  } > "${PROPFILE}"
  chmod 600 "${PROPFILE}"
  echo "Wrote Java DB config to ${PROPFILE}"
else
  echo "No database environment variables found; skipping JNDI context generation."
  echo "Set DB_URL+DB_USER+DB_PASSWORD or DATABASE_URL in Kerocket Deploy tab."
fi

exec "$@"
