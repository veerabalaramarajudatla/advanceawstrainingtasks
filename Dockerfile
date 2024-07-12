# Use the official Tomcat 9 image as the base image
FROM tomcat:9.0.86-jdk21-corretto-al2

# Remove the default ROOT application
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the WAR file from local machine into the webapps directory of Tomcat
COPY target/livedemo.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 to the outside world
EXPOSE 8080

# Start Tomcat when the container starts
CMD ["catalina.sh", "run"]

