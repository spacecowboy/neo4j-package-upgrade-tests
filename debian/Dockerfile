FROM debian:stretch

RUN apt update -qq \
    && apt install -y -qq \
        curl \
        wget \
    && rm -rf /var/lib/apt/lists/*

COPY script.sh /bin/
COPY ../helpers.sh /bin/

CMD ["/bin/script.sh"]
