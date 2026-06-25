# TalaqqiHub — Java Servlet/JSP app (no Maven/Gradle).
# Rocket AI / Kerocket: Nixpacks cannot auto-build this layout; this Dockerfile is the build path.
# Pre-compiled .class files and WEB-INF/lib/*.jar are copied into Tomcat at deploy time.

FROM tomcat:9.0-jdk17

RUN rm -rf /usr/local/tomcat/webapps/*

COPY . /usr/local/tomcat/webapps/ROOT

# Tomcat already provides the Servlet API; keeping this JAR can cause classloader conflicts.
RUN rm -f /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/javax.servlet-api-*.jar

EXPOSE 8080

CMD ["catalina.sh", "run"]
