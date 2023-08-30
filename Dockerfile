FROM semaphoreui/semaphore:v2.9.2
COPY start.sh /usr/bin/start.sh

USER root
RUN chmod +x /usr/bin/start.sh
RUN apk add --no-cache openrc
RUN curl -fsSL https://tailscale.com/install.sh | sh

CMD "start.sh"