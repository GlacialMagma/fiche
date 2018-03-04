FROM alpine:3.7 as build

RUN apk update && apk add \
    curl \
    gcc \
    make \
    musl-dev

WORKDIR /usr/src/fiche

COPY * ./

RUN make -f Makefile clean \
    && make -f Makefile \
    && make -f Makefile install

FROM alpine:3.7

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

COPY --from=build /usr/local/bin/fiche /usr/local/bin

RUN apk add --no-cache tini

RUN addgroup -g 901 fiche \
    && adduser -G fiche -D -u 901 fiche \
    && mkdir /code \
    && chown fiche:fiche /code

USER fiche

EXPOSE 9999

VOLUME ["/data"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/fiche"]

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Pi-hole tricorder" \
      org.label-schema.description="Debugging logfile pastebin for the Pi-hole project." \
      org.label-schema.url="https://tricorder.pi-hole.net" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/pi-hole/tricorder" \
      org.label-schema.vendor="Pi-hole LLC" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"