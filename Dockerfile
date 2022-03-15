ARG VERSION=unspecified

FROM debian:bullseye-slim

ARG VERSION

LABEL org.opencontainers.image.authors="rom35.vicnent@gmail.com"
LABEL org.opencontainers.image.vendor="Fork from Cybersecurity and Infrastructure Security Agency"

ARG GOPHISH_VERSION="0.11.0"
ARG UID=421

ENV USERNAME="cisa" \
    GROUPNAME="cisa" \
    HOME="/home/$USERNAME" \
    SCRIPT_DIR="/usr/local/bin"
   
RUN addgroup --system --gid ${UID} ${USERNAME} \
  && adduser --system --uid ${UID} --ingroup ${USERNAME} ${GROUPNAME}

RUN apt-get update && \
apt-get install --no-install-recommends -y \
unzip \
ca-certificates \
wget && \
apt-get install -y sqlite3 libsqlite3-dev && \
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY bin/get-api-key ${SCRIPT_DIR}

USER ${USERNAME}
WORKDIR ${HOME}

RUN wget -nv https://github.com/gophish/gophish/releases/download/v${GOPHISH_VERSION}/gophish-v${GOPHISH_VERSION}-linux-64bit.zip && \
unzip gophish-v${GOPHISH_VERSION}-linux-64bit.zip && \
rm -f gophish-v${GOPHISH_VERSION}-linux-64bit.zip

RUN chmod +x gophish && ln -snf /run/secrets/config.json config.json && \
mkdir -p data && ln -snf data/gophish.db gophish.db

EXPOSE 3333/TCP 8080/TCP
ENTRYPOINT ["./gophish"]
