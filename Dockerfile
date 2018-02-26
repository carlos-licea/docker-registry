LABEL mantainer="cl@carloslicea.com"

FROM registry

RUN apk add --no-cache docker bash

VOLUME ["/images"]

COPY ./new-entrypoint.sh /new-entrypoint.sh
ENTRYPOINT ["/new-entrypoint.sh]"d

CMD ["/etc/docker/registry/config.yml"]
