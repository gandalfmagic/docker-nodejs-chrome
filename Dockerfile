# gandalfmagic/nodejs-chrome:14.15.4-alpine3.12-1
FROM alpine:3.12.3 AS build

RUN apk update && apk add wget unzip && rm -rf /var/cache/apk/* && \
    wget --quiet -O /tmp/sonar-scanner-cli-linux.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.0.2311-linux.zip && \
    cd /tmp/ && unzip sonar-scanner-cli-linux.zip && \
    mv /tmp/sonar-scanner-4.6.0.2311-linux /tmp/sonar-scanner && \
    sed -i 's/^use_embedded_jre=true.*/use_embedded_jre=false/' /tmp/sonar-scanner/bin/sonar-scanner

FROM node:14.15.4-alpine3.12

ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium
ENV PATH="${PATH}:/opt/sonar-scanner/bin"

# Install latest Chromium
RUN npm install -g npm@6.14.10 && \
    apk add --no-cache \
    python3 make g++ \
    git curl wget \
    chromium \
    openjdk11-jre && \
    rm -rf /var/cache/* && \
    mkdir /var/cache/apk

COPY --from=build /tmp/sonar-scanner/lib /opt/sonar-scanner/lib
COPY --from=build /tmp/sonar-scanner/conf /opt/sonar-scanner/conf
COPY --from=build /tmp/sonar-scanner/bin /opt/sonar-scanner/bin

# Add Chrome as a user
RUN mkdir -p /usr/src/app \
    && adduser -D chrome \
    && chown -R chrome:chrome /usr/src/app
# Run Chrome as non-privileged user
USER chrome
WORKDIR /usr/src/app
