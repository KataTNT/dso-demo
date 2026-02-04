FROM maven:4.0.0-rc-5-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY . .
RUN mvn package -DskipTests

FROM eclipse-temurin:17-jre-alpine AS run
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /run/demo.jar

ARG USER=appuser
ENV HOME=/home/$USER
RUN addgroup -S $USER && \
    adduser -H -S -G $USER $USER && \
    chown $USER:$USER /run/demo.jar
RUN apk add curl
HEALTHCHECK --interval=30s --timeout=10s --retries=2 --start-period=20s \
  CMD curl -f http://localhost:8080/ || exit 1

USER $USER
EXPOSE 8080
CMD ["java", "-jar", "/run/demo.jar"]