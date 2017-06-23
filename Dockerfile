FROM alpine:3.6

ENV OCSERV_VERSION 0.11.8
ENV CA_CN VPN CA
ENV CA_ORG Big Corp
ENV SRV_CN VPN server
ENV SRV_ORG MyCompany

RUN set -ex \
    && echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --no-cache --virtual .build-dependencies \
    readline-dev \
    libnl3-dev \
    xz \
    openssl \
    make \
    gcc \
    autoconf \
    musl-dev \
    wget \
    linux-headers \
    gnutls-dev \
    linux-pam-dev \
    libseccomp-dev \
    lz4-dev \
    libev-dev \
    oath-toolkit-dev \
    protobuf-c-dev \
    krb5-dev \
    gnutls-utils \
    && wget ftp://ftp.infradead.org/pub/ocserv/ocserv-$OCSERV_VERSION.tar.xz \
    && mkdir -p /etc/ocserv \
    && tar xf ocserv-$OCSERV_VERSION.tar.xz \
    && rm ocserv-$OCSERV_VERSION.tar.xz \
    && cd ocserv-$OCSERV_VERSION \
    && ./configure \
    && make \
    && make install \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/local/sbin/ocserv \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && cd .. \
    && rm -rf ocserv-$OCSERV_VERSION \
    && mkdir -p /etc/ocserv/certs \
    && cd /etc/ocserv/certs \
    && certtool --generate-privkey --ecc --outfile ca-key.pem \
    && touch ca.tmpl \
    && echo "cn = $CA_CN" >> ca.tmpl \
    && echo "organization = $CA_ORG" >> ca.tmpl \
    && echo "serial = 1" >> ca.tmpl \
    && echo "expiration_days = -1" >> ca.tmpl \
    && echo "ca" >> ca.tmpl \
    && echo "signing_key" >> ca.tmpl \
    && echo "cert_signing_key" >> ca.tmpl \
    && echo "crl_signing_key" >> ca.tmpl \
    && certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem \
    && certtool --generate-privkey --ecc --outfile server-key.pem \
    && touch server.tmpl \
    && echo "cn = $SRV_CN" >> server.tmpl \
    && echo "organization = $SRV_ORG" >> server.tmpl \
    && echo "expiration_days = -1" >> server.tmpl \
    && echo "signing_key" >> server.tmpl \
    && echo "tls_www_server" >> server.tmpl \
    && certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem \
    && touch /etc/ocserv/ocpasswd \
    && apk del .build-dependencies \
    && apk add --no-cache --virtual .run-deps $runDeps iptables \
    && rm -rf /var/cache/apk/*

WORKDIR /etc/ocserv

COPY ocserv.conf /etc/ocserv/ocserv.conf
COPY entrypoint.sh /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"]
