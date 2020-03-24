FROM golang:alpine as builder

WORKDIR /app

COPY main.go .
COPY go.mod .

RUN CGO_ENABLED=0 GOOS=linux go build -o webapp

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /usr/bin

COPY --from=builder /app/webapp .

EXPOSE 8080
CMD ["./webapp"]

