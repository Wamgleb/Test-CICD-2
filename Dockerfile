# Base image
FROM tomcat:latest

# Set the working directory in the container
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file from the local Maven build to the container
COPY /msi-ui/trucks/target/*.war .

# Remove the default ROOT application from the Tomcat webapps directory
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Rename the WAR file to ROOT.war to make it the default application
RUN mv *.war ROOT.war

# Expose the Tomcat port
EXPOSE 8081

# Start Tomcat when the container is run
CMD ["catalina.sh", "run"]
 