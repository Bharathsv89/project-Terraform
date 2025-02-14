FROM tomcat:9.0
COPY . /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]