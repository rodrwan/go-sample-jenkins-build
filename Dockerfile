FROM alpine

WORKDIR /usr/bin

COPY webapp .

ENTRYPOINT ["./webapp"]

