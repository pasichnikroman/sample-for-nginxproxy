FROM nginx:alpine

RUN addgroup -g 1000 -S www-data \
 && adduser -u 1000 -D -S -G www-data www-data

RUN apk add --update bash && rm -rf /var/cache/apk/*
RUN apk -U add openssl

ENV VERSION 0.2.3
RUN wget -qO- https://github.com/arschles/envtpl/releases/download/$VERSION/envtpl_linux_amd64 -O /usr/local/bin/envtpl && chmod 755 /usr/local/bin/envtpl


RUN mkdir /etc/nginx/sites-available /etc/nginx/sites-enabled
RUN touch /etc/nginx/sites-available/default.conf && ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/


CMD ["nginx"]

EXPOSE 80
EXPOSE 443
