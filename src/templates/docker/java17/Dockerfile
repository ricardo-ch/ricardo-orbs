# base image to build a JRE
FROM amazoncorretto:17.0.7 as corretto-jdk

# required for strip-debug to work and unzipping the jar
RUN yum install -y binutils unzip

# Identify modules
COPY target/*.jar app.jar
RUN unzip -d unpacked app.jar && \
    $JAVA_HOME/bin/jdeps \
    --ignore-missing-deps \
    --print-module-deps \
    -q \
    --recursive \
    --multi-release 17 \
    --class-path="/unpacked/BOOT-INF/lib/*" \
    --module-path="/unpacked/BOOT-INF/lib/*" \
    ./app.jar > /modules.info

# Build small JRE image
RUN $JAVA_HOME/bin/jlink \
    --verbose \
    --add-modules $(cat /modules.info) \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /jre

FROM ubuntu:22.04
ENV JAVA_HOME=/jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# copy JRE from the base image
COPY --from=corretto-jdk /jre $JAVA_HOME

# Non-root user
USER 1984:1984

COPY --chown=1984:1984 target/*.jar app.jar

ENTRYPOINT ["java","-XX:MaxRAMPercentage=75.0","-Djava.security.egd=file:/dev/urandom","-jar","/app.jar"]
