# TalaqqiHub — Java Servlet/JSP on Tomcat 9 (NOT Node.js).
# Kerocket: Docker build only. Maven compiles WAR; entrypoint binds $PORT on 0.0.0.0.
# Required env: DB_URL + DB_USER + DB_PASSWORD, or DATABASE_URL from attached MySQL.

FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
COPY . .

RUN mvn -B -DskipTests package \
    && cp target/TalaqqiHub/WEB-INF/lib/mysql-connector-j-*.jar /tmp/mysql-connector-j.jar

FROM tomcat:9.0-jdk17

LABEL org.opencontainers.image.title="TalaqqiHub" \
      org.opencontainers.image.description="Java Servlet/JSP web application on Apache Tomcat 9"

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /app/target/TalaqqiHub.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=build /tmp/mysql-connector-j.jar /usr/local/tomcat/lib/mysql-connector-j.jar

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

ENV PORT=8080

EXPOSE 8080

# Starts Tomcat via entrypoint (configures $PORT + database JNDI before catalina.sh run).
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
