FROM eclipse-temurin:17-jre

RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

COPY target/*.jar app.jar

RUN chown spring:spring app.jar

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
