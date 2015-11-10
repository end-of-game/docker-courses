FROM busybox

RUN mkdir -p /tomcat/webapps
ADD hello.war /tomcat/webapps/hello.war

VOLUME ["/tomcat/webapps"]

CMD /bin/sh

