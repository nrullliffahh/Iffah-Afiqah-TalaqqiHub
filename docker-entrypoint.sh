#!/bin/sh
set -eu

TOMCAT_HOME="/usr/local/tomcat"
CONTEXT_DIR="${TOMCAT_HOME}/conf/Catalina/localhost"
CONTEXT_FILE="${CONTEXT_DIR}/ROOT.xml"

mkdir -p "${CONTEXT_DIR}"

# Kerocket and other hosts inject PORT; default Tomcat 8080 locally.
if [ -n "${PORT:-}" ] && [ "${PORT}" != "8080" ]; then
  sed -i "s/port=\"8080\"/port=\"${PORT}\"/" "${TOMCAT_HOME}/conf/server.xml"
fi

# Resolve database settings from Kerocket-style env vars.
JDBC_URL=""
DB_USER=""
DB_PASSWORD=""

if [ -n "${DATABASE_URL:-}" ]; then
  case "${DATABASE_URL}" in
    jdbc:*)
      JDBC_URL="${DATABASE_URL}"
      DB_USER="${DB_USER:-${MYSQLUSER:-${MYSQL_USER:-}}}"
      DB_PASSWORD="${DB_PASSWORD:-${MYSQLPASSWORD:-${MYSQL_PASSWORD:-}}}"
      ;;
    mysql://*|mariadb://*)
      # mysql://user:pass@host:3306/dbname
      REST="${DATABASE_URL#*://}"
      USERINFO="${REST%%@*}"
      HOSTPART="${REST#*@}"
      DB_USER="${USERINFO%%:*}"
      DB_PASSWORD="${USERINFO#*:}"
      HOST="${HOSTPART%%/*}"
      DBNAME="${HOSTPART#*/}"
      DBNAME="${DBNAME%%\?*}"
      HOST_ONLY="${HOST%%:*}"
      PORT_PART="${HOST#*:}"
      if [ "${HOST}" = "${HOST_ONLY}" ]; then
        PORT_PART="3306"
      fi
      JDBC_URL="jdbc:mysql://${HOST_ONLY}:${PORT_PART}/${DBNAME}?useSSL=false&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true"
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
    JDBC_URL="jdbc:mysql://${MYSQLHOST}:${MYSQLPORT}/${MYSQLDATABASE}?useSSL=false&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true"
  fi
fi

if [ -z "${JDBC_URL}" ]; then
  DB_URL="${DB_URL:-jdbc:mysql://127.0.0.1:3306/talaqqihub_db?useSSL=false&serverTimezone=UTC&connectTimeout=5000&socketTimeout=10000&allowPublicKeyRetrieval=true}"
  JDBC_URL="${DB_URL}"
  DB_USER="${DB_USER:-root}"
  DB_PASSWORD="${DB_PASSWORD:-}"
fi

if [ -n "${JDBC_URL}" ]; then
  cat > "${CONTEXT_FILE}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Context>
  <Resource name="jdbc/TalaqqiHubDB"
            auth="Container"
            type="javax.sql.DataSource"
            maxTotal="20"
            maxIdle="5"
            maxWaitMillis="10000"
            username="${DB_USER}"
            password="${DB_PASSWORD}"
            driverClassName="com.mysql.cj.jdbc.Driver"
            url="${JDBC_URL}"/>
</Context>
EOF
  echo "Configured Tomcat JNDI datasource at ${CONTEXT_FILE}"
else
  echo "No database environment variables found; skipping JNDI context generation."
fi

exec catalina.sh run
