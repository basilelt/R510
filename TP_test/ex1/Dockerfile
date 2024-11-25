# FROM debian:bookworm-slim

# RUN mkdir /data
# WORKDIR /data
# COPY test.zip /data

# RUN apt-get update
# RUN apt-get install -y unzip
# RUN apt-get install -y iputils-ping
# RUN unzip test.zip
# RUN chmod +x script.sh

# ENTRYPOINT ["/bin/sh", "-c", "/data/script.sh"]

FROM alpine:latest AS builder
RUN apk add --no-cache unzip
COPY test.zip /test.zip
RUN unzip /test.zip

FROM alpine:latest
RUN mkdir /data
COPY --from=builder /script.sh /data/

CMD ["/bin/sh", "/data/script.sh"]