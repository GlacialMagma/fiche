FROM alpine:3.7 as build

RUN apk update && apk add \
    curl \
    gcc \
    make \
    musl-dev

WORKDIR /usr/src/fiche

COPY * ./

RUN make -f Makefile

FROM alpine:3.7

COPY --from=build /usr/src/fiche/fiche /usr/local/bin

RUN apk add --no-cache tini

RUN addgroup -g 901 fiche \
    && adduser -G fiche -D -u 901 fiche \
    && mkdir /code \
    && chown fiche:fiche /code

USER fiche

EXPOSE 9999

VOLUME ["/data"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/fiche"]