# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: Java (glibc support)
# Minimum Panel Version: 0.6.0
# ----------------------------------
  FROM        openjdk:15-slim

  LABEL       author="Birdflop" maintainer="development@birdflop.com"
  
  RUN apt-get update -y \
      && apt-get install -y curl ca-certificates openssl git tar sqlite3 fontconfig tzdata iproute2 \
      && useradd -d /home/container -m container

  USER container
  ENV  USER=container HOME=/home/container
  
  USER        container
  ENV         USER=container HOME=/home/container
  
  WORKDIR     /home/container
  
  COPY        ./entrypoint.sh /entrypoint.sh
  
  CMD         ["/bin/bash", "/entrypoint.sh"]