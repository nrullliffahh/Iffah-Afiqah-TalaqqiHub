# TalaqqiHub — Java Servlet/JSP (Tomcat 9).
# Kerocket: set Build strategy to Dockerfile (not Nixpacks).
# Required env in Kerocket Settings: DATABASE_URL or MYSQLHOST + MYSQLUSER + MYSQLPASSWORD + MYSQLDATABASE

FROM tomcat:9.0-jdk17

RUN rm -rf /usr/local/tomcat/webapps/*

COPY . /usr/local/tomcat/webapps/ROOT

# Tomcat already provides the Servlet API.
RUN rm -f /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/javax.servlet-api-*.jar

# MySQL driver must be on Tomcat's classpath for JNDI DataSource wiring.
RUN cp /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/mysql-connector-j-*.jar /usr/local/tomcat/lib/

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV PORT=8080

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
