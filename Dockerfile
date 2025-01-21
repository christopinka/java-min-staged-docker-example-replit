

FROM debian:slim@sha256:c5c5200ff1e9c73ffbf188b4a67eb1c91531b644856b4aefe86a58d2f0cb05be


# Stage 1: Build Stage
FROM maven:3.6.3-jdk-11@sha256:66c14be1d6257c363f7e22ebc7bc656dbe7573fae7bbb271343f0ee4476a96d3 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# Stage 2: Runtime Stage with custom JRE using jlink
FROM adoptopenjdk:11-jre-hotspot@sha256:3f66ca022431afc9d51c6f57f51e77b1def0873cde6c4d2d93ac5fe10f6f30ff AS runtime
WORKDIR /app

# Copy the built JAR from build stage
COPY --from=build /app/target/myartifactid-0.0-SNAPSHOT.jar /app/app.jar

# Create minimal JRE with only required modules
RUN jlink \
    --module-path /opt/java/openjdk/jmods \
    --add-modules java.base \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /app/custom-jre

# Final stage with minimal footprint
FROM debian:slim@sha256:c5c5200ff1e9c73ffbf188b4a67eb1c91531b644856b4aefe86a58d2f0cb05be
WORKDIR /app
COPY --from=runtime /app/custom-jre /app/custom-jre
COPY --from=runtime /app/app.jar /app/app.jar

# Set environment variables
ENV JAVA_HOME=/app/custom-jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Run the application
CMD ["./custom-jre/bin/java", "-jar", "/app/app.jar"]
