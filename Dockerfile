FROM nginx:alpine

RUN mkdir -p /etc/nginx/conf.d/sites-available

RUN mkdir -p /etc/nginx/conf.d/sites-enabled

RUN mkdir -p /etc/ssl/private

RUN rm /etc/nginx/conf.d/nginx.conf

COPY ./certs/ /etc/ssl/private/

COPY ./conf.d/ /etc/nginx/conf.d/

COPY ./sites-available/ /etc/nginx/conf.d/sites-available/


RUN ln -s /etc/nginx/conf.d/sites-available/* /etc/nginx/conf.d/sites-enabled/

RUN systemctl reload nginx
