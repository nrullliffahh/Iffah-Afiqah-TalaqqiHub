#!/bin/sh
set -eu

TOMCAT_HOME="/usr/local/tomcat"
CONTEXT_DIR="${TOMCAT_HOME}/conf/Catalina/localhost"
CONTEXT_FILE="${CONTEXT_DIR}/ROOT.xml"
CONF_DIR="${TOMCAT_HOME}/conf"

mkdir -p "${CONTEXT_DIR}"

HTTP_PORT="${PORT:-8080}"
SERVER_XML="${TOMCAT_HOME}/conf/server.xml"

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

write_secret_file() {
  _path="$1"
  _value="$2"
  printf '%s' "$_value" > "${_path}"
  chmod 600 "${_path}"
}

parse_mysql_url_credentials() {
  _raw="$1"
  case "${_raw}" in
    mysql://*|mariadb://*)
      _rest="${_raw#*://}"
      _userinfo="${_rest%%@*}"
      if [ "${_userinfo}" = "${_rest}" ]; then
        return 0
      fi
      DB_USER="${_userinfo%%:*}"
      DB_PASSWORD="${_userinfo#*:}"
      ;;
  esac
}

JDBC_URL=""
DB_USER=""
DB_PASSWORD=""

echo "DB env at startup: DB_URL=$([ -n "${DB_URL:-}" ] && echo set || echo missing) DATABASE_URL=$([ -n "${DATABASE_URL:-}" ] && echo set || echo missing) DB_USER=$([ -n "${DB_USER:-}" ] && echo set || echo missing) DB_PASSWORD=$([ -n "${DB_PASSWORD:-}" ] && echo set || echo missing)"

if [ -n "${DB_URL:-}" ]; then
  JDBC_URL="${DB_URL}"
  DB_USER="${DB_USER:-${MYSQLUSER:-${MYSQL_USER:-}}}"
  DB_PASSWORD="${DB_PASSWORD:-${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}}"
  if [ -z "${DB_USER}" ] || [ -z "${DB_PASSWORD}" ]; then
    parse_mysql_url_credentials "${DATABASE_URL:-}"
  fi
  DB_USER="${DB_USER:-root}"
fi

if [ -z "${JDBC_URL}" ] && [ -n "${DATABASE_URL:-}" ]; then
  case "${DATABASE_URL}" in
    jdbc:*)
      JDBC_URL="${DATABASE_URL}"
      DB_USER="${DB_USER:-${MYSQLUSER:-${MYSQL_USER:-}}}"
      DB_PASSWORD="${DB_PASSWORD:-${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}}"
      parse_mysql_url_credentials "${DATABASE_URL}"
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
  echo "Configured Tomcat JNDI datasource (user=${DB_USER:-<empty>})"

  write_secret_file "${CONF_DIR}/db.jdbc.url" "${JDBC_URL}"
  write_secret_file "${CONF_DIR}/db.jdbc.user" "${DB_USER}"
  write_secret_file "${CONF_DIR}/db.jdbc.password" "${DB_PASSWORD}"

  PROPFILE="${CONF_DIR}/talaqqihub-db.properties"
  {
    printf 'db.url.b64=%s\n' "$(b64_encode "${JDBC_URL}")"
    printf 'db.user.b64=%s\n' "$(b64_encode "${DB_USER}")"
    printf 'db.password.b64=%s\n' "$(b64_encode "${DB_PASSWORD}")"
  } > "${PROPFILE}"
  chmod 600 "${PROPFILE}"
  echo "Wrote JDBC credential files under ${CONF_DIR}"
else
  echo "ERROR: No database environment variables found."
  echo "Set DB_URL+DB_USER+DB_PASSWORD or attach DATABASE_URL from Kerocket MySQL service."
fi

exec "$@"
