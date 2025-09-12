FROM maven AS buildstage
RUN mkdir /opt/webapp
WORKDIR /opt/webapp
COPY . .
RUN mvn clean install    ## artifact -- .war 

## tomcat deploy stage 
FROM tomcat 
WORKDIR webapps 
COPY --from=buildstage /opt/webapp/target/*.war .
RUN rm -rf ROOT && mv *.war ROOT.war
EXPOSE 8080
