# ✅ Use official Tomcat image WITH Corretto JDK
FROM tomcat:9.0.86-jdk21-corretto-al2

# Remove the default ROOT application
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the WAR file into Tomcat
COPY target/livedemo.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080
EXPOSE 8080

# Tomcat starts automatically — no need to override CMD unless needed
