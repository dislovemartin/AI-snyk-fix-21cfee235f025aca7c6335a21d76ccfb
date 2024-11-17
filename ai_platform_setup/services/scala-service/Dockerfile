
# Scala Service Dockerfile
FROM hseeberger/scala-sbt:11.0.14_1.6.2_2.13.8

WORKDIR /app
COPY . .
RUN sbt compile

EXPOSE 8080
CMD ["sbt", "run"]
