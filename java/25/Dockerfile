FROM eclipse-temurin:25-jre

LABEL author="Birdflop" maintainer="development@birdflop.com"

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates openssl git tar sqlite3 fontconfig tzdata iproute2 libfreetype6 bash \
    && useradd -d /home/container -m container \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]