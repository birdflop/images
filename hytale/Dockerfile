FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/temurin-25-jdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Base packages needed by Pterodactyl and the Hytale downloader
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    tzdata \
    bash \
    openssl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Add Adoptium (Eclipse Temurin) repository for JDK 25
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
        | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] \
        https://packages.adoptium.net/artifactory/deb \
        $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/adoptium.list

# Install Temurin OpenJDK 25
RUN apt-get update && \
    apt-get install -y temurin-25-jdk && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user expected by Pterodactyl
RUN useradd -d /home/container -m -r -s /bin/bash container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container start.sh /start.sh
RUN chmod +x /entrypoint.sh /start.sh

CMD ["/bin/bash", "/entrypoint.sh"]
