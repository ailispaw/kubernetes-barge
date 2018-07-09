FROM alpine:3.7

RUN apk add --update --no-cache openvswitch

VOLUME [ "/var/log/openvswitch", "/var/lib/openvswitch", "/var/run/openvswitch", "/etc/openvswitch" ]

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
