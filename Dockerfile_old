# gRPC
FROM golang:alpine as builder

# Install git.
# Git is required for fetching the dependencies.
RUN apk add --no-cache git

WORKDIR $GOPATH/src/github.com/<github-user>/rpc/
COPY . .

# Fetch dependencies
RUN go mod tidy

# Build the binary. for grpc gateway
RUN go build ./cmd/server

RUN pwd
RUN echo $GOPATH

#EXPOSE 9090
# Run the hello binary.
#ENTRYPOINT ["./cmd/server"]

# final build
FROM alpine:3.11.3
RUN apk --no-cache add bash curl ca-certificates
RUN apk update && apk add mysql-client
WORKDIR /root/
COPY --from=builder /go/src/github.com/<github-user>/rpc/server .
ENTRYPOINT ["bash", "-c", "/root/server -grpc-port=$grpc_port_env -db-host=$db_host -db-user=$db_user -db-password=$db_password -db-schema=$db_schema"]

# kafka
FROM golang:1.13.14-alpine3.11 AS builder
RUN mkdir -p /go/src/github.com/mailgun/kafka-pixy
COPY . /go/src/github.com/mailgun/kafka-pixy
WORKDIR /go/src/github.com/mailgun/kafka-pixy
RUN apk add build-base
RUN go mod download 
RUN go build -v -o /go/bin/kafka-pixy

FROM alpine:3.11
LABEL maintainer="Maxim Vladimirskiy <horkhe@gmail.com>"
COPY --from=builder /go/bin/kafka-pixy /usr/bin/kafka-pixy
EXPOSE 19091 19092
ENTRYPOINT ["/usr/bin/kafka-pixy"]

# Jave
FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /opt/app
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline
COPY ./src ./src
RUN ./mvnw spring-javaformat:apply
RUN ./mvnw clean package

FROM eclipse-temurin:17-jre-jammy
ARG JAR_NAME
LABEL name="spring-pet-clinic" \
description="Docker image for spring pet clinic" 
RUN addgroup appadmin; adduser  --ingroup appadmin --disabled-password appadmin
USER appadmin
WORKDIR /opt/app
EXPOSE 8080
#COPY target/*.jar /opt/app/spring-petclinic.jar
COPY --from=builder /opt/app/target/${JAR_NAME}.jar /opt/app/spring-petclinic.jar
ENTRYPOINT ["java", "-jar", "/opt/app/spring-petclinic.jar" ]

# Python

FROM python:latest
 
ENV SRC_DIR /usr/bin/src/test_server/src
COPY src/* ${SRC_DIR}/
WORKDIR ${SRC_DIR}
 
ENV PYTHONUNBUFFERED=1
 
CMD ["python", "server.py"]

# Node

FROM node:latest
WORKDIR /app
ADD package*.json ./
RUN npm install
ADD index.js ./
CMD [ "node", "index.js"]
