FROM nginx:alpine

RUN mkdir -p /etc/nginx/sites-available

RUN mkdir -p /etc/nginx/sites-enabled

RUN mkdir -p /etc/ssl/private

#RUN rm /etc/nginx/nginx.conf
COPY ./nginx.conf /etc/nginx/

COPY ./certs/ /etc/ssl/private/

COPY ./conf.d/ /etc/nginx/conf.d/

COPY ./sites-available/ /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

#RUN nginx -s reload
