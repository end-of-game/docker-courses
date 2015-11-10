#!/bin/bash

if [ ! -f /.tomcat_admin_created ]; then
    /create_tomcat_admin_user.sh
fi

echo ":: VARIABLE D'ENVIRONNEMENT ::"
env

exec ${CATALINA_HOME}/bin/catalina.sh run

