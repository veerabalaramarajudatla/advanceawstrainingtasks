# ✅ Use Tomcat from Amazon Public ECR to avoid Docker Hub limits
FROM public.ecr.aws/docker/library/tomcat:9.0.86-jdk21-corretto-al2

# Remove default ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy your WAR file
COPY target/livedemo.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080
EXPOSE 8080
