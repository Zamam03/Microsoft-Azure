# Build stage
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o app

# Final stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/app .
CMD ["./app"]