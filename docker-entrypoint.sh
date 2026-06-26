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

# Parsed from attached MySQL service (DATABASE_URL) — authoritative Aiven credentials.
SVC_USER=""
SVC_PASSWORD=""
SVC_JDBC_URL=""

parse_database_url() {
  _raw="${1:-}"
  case "${_raw}" in
    mysql://*|mariadb://*)
      _rest="${_raw#*://}"
      _userinfo="${_rest%%@*}"
      _hostpart="${_rest#*@}"
      if [ "${_userinfo}" = "${_rest}" ]; then
        return 0
      fi
      SVC_USER="${_userinfo%%:*}"
      SVC_PASSWORD="${_userinfo#*:}"
      _host="${_hostpart%%/*}"
      _path_and_query="${_hostpart#*/}"
      _dbname="${_path_and_query%%\?*}"
      _query_params="${_path_and_query#*\?}"
      if [ "${_path_and_query}" = "${_dbname}" ]; then
        _query_params=""
      fi
      _host_only="${_host%%:*}"
      _port_part="${_host#*:}"
      if [ "${_host}" = "${_host_only}" ]; then
        _port_part="3306"
      fi
      if [ -n "${_query_params}" ]; then
        _query_params="$(printf '%s' "${_query_params}" | sed 's/ssl-mode=/sslMode=/g')"
        SVC_JDBC_URL="jdbc:mysql://${_host_only}:${_port_part}/${_dbname}?${_query_params}&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true"
      else
        SVC_JDBC_URL="jdbc:mysql://${_host_only}:${_port_part}/${_dbname}?sslMode=REQUIRED&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true"
      fi
      ;;
    jdbc:*)
      SVC_JDBC_URL="${_raw}"
      parse_database_url "$(printf '%s' "${_raw}" | sed 's|^jdbc:mysql://|mysql://|')"
      ;;
  esac
}

JDBC_URL=""
DB_USER=""
DB_PASSWORD=""

echo "DB env at startup: DB_URL=$([ -n "${DB_URL:-}" ] && echo set || echo missing) DATABASE_URL=$([ -n "${DATABASE_URL:-}" ] && echo set || echo missing) DB_USER=$([ -n "${DB_USER:-}" ] && echo set || echo missing)"

if [ -n "${DATABASE_URL:-}" ]; then
  parse_database_url "${DATABASE_URL}"
fi

# JDBC URL: prefer explicit DB_URL (database name) but fall back to DATABASE_URL service URL.
if [ -n "${DB_URL:-}" ]; then
  JDBC_URL="${DB_URL}"
elif [ -n "${SVC_JDBC_URL}" ]; then
  JDBC_URL="${SVC_JDBC_URL}"
fi

# Credentials: prefer DATABASE_URL (Aiven avnadmin) — Kerocket DB_USER is often wrong (e.g. 'kerocket').
if [ -n "${SVC_USER}" ]; then
  DB_USER="${SVC_USER}"
  DB_PASSWORD="${SVC_PASSWORD}"
else
  DB_USER="${DB_USER:-${MYSQLUSER:-${MYSQL_USER:-root}}}"
  DB_PASSWORD="${DB_PASSWORD:-${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}}"
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
  echo "Configured Tomcat JNDI datasource (user=${DB_USER:-<empty>}, from=$([ -n "${SVC_USER}" ] && echo DATABASE_URL || echo env))"

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
  echo "Attach DATABASE_URL from Kerocket MySQL service or set DB_URL+DB_USER+DB_PASSWORD."
fi

exec "$@"
