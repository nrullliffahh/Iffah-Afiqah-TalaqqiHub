# TalaqqiHub — Java Servlet/JSP WAR on Apache Tomcat 9.
# Kerocket: use Docker build (kerocket.toml builder=docker).
# Runtime binds HTTP to 0.0.0.0:$PORT via docker-entrypoint.sh.

FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -B -DskipTests dependency:go-offline

COPY . .
RUN mvn -B -DskipTests clean package \
    && test -f target/TalaqqiHub.war \
    && MYSQL_JAR="$(find /root/.m2/repository/com/mysql/mysql-connector-j -name 'mysql-connector-j-*.jar' 2>/dev/null | sort -V | tail -1)" \
    && test -n "${MYSQL_JAR}" \
    && cp "${MYSQL_JAR}" /tmp/mysql-connector-j.jar

FROM tomcat:9.0-jre17-temurin

LABEL org.opencontainers.image.title="TalaqqiHub" \
      org.opencontainers.image.description="Java Servlet/JSP web application on Apache Tomcat 9" \
      io.kerocket.stack="java-tomcat" \
      io.kerocket.build="dockerfile"

RUN rm -rf /usr/local/tomcat/webapps/* \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 1001 app \
    && useradd --system --uid 1001 --gid app --home-dir /usr/local/tomcat app

COPY --from=build /app/target/TalaqqiHub.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=build /tmp/mysql-connector-j.jar /usr/local/tomcat/lib/mysql-connector-j.jar

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && chown -R app:app /usr/local/tomcat

# Kerocket injects PORT at runtime (commonly 8080). Entrypoint rewrites server.xml connector.
ENV PORT=8080

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD sh -c 'curl -fsS "http://127.0.0.1:${PORT:-8080}/" >/dev/null || exit 1'

USER app

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
