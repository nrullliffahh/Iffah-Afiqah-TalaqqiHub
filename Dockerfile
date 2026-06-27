# TalaqqiHub — Java Servlet/JSP on Tomcat 9 (NOT Node.js).
# Kerocket: Docker build. Tomcat listens on 0.0.0.0:$PORT (see docker-entrypoint.sh).
# Required env at runtime: DB_URL + DB_USER + DB_PASSWORD, or DATABASE_URL from attached MySQL.

FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -B -DskipTests dependency:go-offline

COPY . .

RUN mvn -B -DskipTests package \
    && test -f target/TalaqqiHub.war \
    && MYSQL_JAR="$(find /root/.m2/repository/com/mysql/mysql-connector-j -name 'mysql-connector-j-*.jar' 2>/dev/null | sort -V | tail -1)" \
    && test -n "${MYSQL_JAR}" \
    && cp "${MYSQL_JAR}" /tmp/mysql-connector-j.jar

FROM tomcat:9.0-jdk17

LABEL org.opencontainers.image.title="TalaqqiHub" \
      org.opencontainers.image.description="Java Servlet/JSP web application on Apache Tomcat 9" \
      io.kerocket.stack="java-tomcat" \
      io.kerocket.build="dockerfile"

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /app/target/TalaqqiHub.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=build /tmp/mysql-connector-j.jar /usr/local/tomcat/lib/mysql-connector-j.jar

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Kerocket sets PORT at runtime (often 8080 for Java/Tomcat). Entrypoint rewrites server.xml to bind 0.0.0.0:$PORT.
ENV PORT=8080

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
