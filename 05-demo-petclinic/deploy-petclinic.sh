#!/bin/bash

cd spring-petclinic
rm -rf target
mvn clean package -DskipTests

rm -rf ../archives/petclinic*
cp target/petclinic.war ../archives


