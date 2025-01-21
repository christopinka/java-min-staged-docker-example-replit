# CI/CD Process Overview

- git pr to develop is tested and approved by team with change release notes and versions bumped
- code changes merged to branch "develop"
- bamboo triggers build process:
  - code is checked out from git
  - run build code (java)
  - run unit+integration tests
  - deploy versioned artifact to nexus/artifactory
  - build docker image with artifact - dockerfile
    - use explicit tags and lock at version with checksum
    - multi-stage
    - jlink
    - scans?
    - tag docker image with artifact version
    - push image to docker hub
    - deploy to aws with sdk or possibly have kubernetes detect image change and pull from docker hub




# Optimizing Java Base Docker Images Size: From 674MB to 58MB

- **Article Overview**: 
  - The article discusses methods to reduce the size of Java-based Docker images.
  - The focus is on transforming a large Docker image (674MB) to a much smaller one (58MB).

- **Key Techniques Used**:
  1. **Choosing the Right Base Image**:
     - Switch from `openjdk:11` to a smaller, optimized base image like `adoptopenjdk:11-jre-hotspot`.
     - This significantly reduces the image size by using a minimal Java runtime.

  2. **Multi-Stage Builds**:
     - Multi-stage builds allow separating the build environment from the runtime environment.
     - The final image includes only the necessary runtime components, excluding build tools and dependencies.

  3. **Minimizing the Application Dependencies**:
     - Reduce unnecessary dependencies within the application.
     - Use `maven` or `gradle` to manage dependencies and include only required ones.

  4. **Using Distroless Images**:
     - Consider using Google’s distroless images for runtime.
     - These images do not include a shell or package manager, minimizing the attack surface and size.

  5. **Leveraging JLink for Custom JRE**:
     - Use `jlink` to create a custom, minimal JRE that includes only the necessary modules for the application.
     - This reduces the Java runtime size significantly by excluding unused Java libraries.

- **Final Dockerfile Optimization**:
  - The optimized Dockerfile uses a multi-stage build, the smallest possible JDK, and a custom JRE created with `jlink`.
  - Final image size is reduced from 674MB to 58MB, a massive improvement.

- **Benefits**:
  - Reduced Docker image size improves deployment times.
  - Smaller images lead to faster downloads and reduced storage overhead.
  - Better security by reducing unnecessary components in the image.

- **Conclusion**:
  - Using the right base images and optimizing your Dockerfile with multi-stage builds and custom JRE creation can significantly reduce Docker image sizes, enhancing efficiency in containerized Java applications.

### Complete Example of Optimized Dockerfile

```Dockerfile
# Stage 1: Build Stage
FROM maven:3.6.3-jdk-11 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# Stage 2: Runtime Stage
FROM adoptopenjdk:11-jre-hotspot AS runtime
WORKDIR /app
COPY --from=build /app/target/myapp.jar /app/myapp.jar

# Use jlink to create a custom JRE with only the necessary modules
RUN jlink --module-path /opt/java/openjdk/jmods --add-modules java.base,java.logging,java.sql --output /app/jre

# Run the application with the minimal JRE
CMD ["/app/jre/bin/java", "-jar", "/app/myapp.jar"]
```


# Notes

https://snyk.io/blog/best-practices-to-build-java-containers-with-docker/

https://medium.com/@RoussiAbdelghani/optimizing-java-base-docker-images-size-from-674mb-to-58mb-c1b7c911f622