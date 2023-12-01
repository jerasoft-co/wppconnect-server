FROM alpine:latest

RUN apk --no-cache add openssl

COPY secret_generator.sh /usr/src/wpp-server/

CMD ["/bin/sh", "/usr/src/wpp-server/secret_generator.sh"]
