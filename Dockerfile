FROM  alpine:latest

RUN adduser -S -D -H -G root -h /home app

RUN apk --no-cache upgrade \
 && apk --no-cache add \
      cmake libuv-dev build-base \
      bash wget curl \
      openssh rsync augeas \
      python git nodejs nodejs-npm

# Install dumb-init (avoid PID 1 issues). https://github.com/Yelp/dumb-init
RUN curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 \
 && chmod +x /usr/local/bin/dumb-init 

# Grant privileges
RUN chgrp -R 0     /var /etc /home \
 && chmod -R g+rwX /var /etc /home \
 && chmod 664 /etc/passwd /etc/group

# Prepare SSH service
RUN echo "Port 2022" >> /etc/ssh/sshd_config \
 && mkdir -p /var/empty && chmod 700 /var/empty

WORKDIR /home

# Install XMRIG
RUN git clone https://github.com/xmrig/xmrig xmrig_source \
 && cd xmrig_source \
 && mkdir build \
 && cmake -DCMAKE_BUILD_TYPE=Release . \
 && make \
 && mv xmrig /usr/bin \
 && cd .. \
 && rm -rf xmrig_source

# Install Wetty
RUN git clone https://github.com/amolinado/wetty \
 && cd wetty \
 && npm install

EXPOSE 3000 8000


USER app
ADD entrypoint.sh /
ENTRYPOINT  ["dumb-init","/entrypoint.sh"]
