#!/bin/sh

registry_address=${REGISTRY_HTTP_ADDR:-localhost:5000}

start_docker() {
    docker daemon --host=unix:///var/run/docker.sock \
                  --host=tcp://0.0.0.0:2375 \
                  --storage-driver=vfs \
                  --pidfile=/var/run/docker.pid
}

stop_docker() {
    kill -9 `cat /var/run/docker.pid`
}

clean_local_registry() {
    docker system prune -a
}

populate_registry() {

    start_docker &

    # give it some time to set up
    sleep 10

    input="/images/names"
    if [ ! -s "$input" ]; then
        echo "WARNING: names file doesn't exist or is empty."

        clean_local_registry
        stop_docker

        return
    fi

    cd /images

    line_no=0
    while IFS= read -r line
    do
      line_no=$((line_no+1))

      file="$(echo ${line} | cut -d' ' -f1)"
      tag="$(echo ${line} | cut -d' ' -f2)"
      version="$(echo ${line} | cut -d' ' -f3)"

      if [ "${file}" = "" ] || [ "${tag}" = "" ] || [ "${version}" = "" ]; then
          echo "Skipping line ${line_no}, not enough parameters."
          continue
      fi

      basename=$(basename $file .tar)

      echo "Adding: file '${file}' (basename '$basename') as '${tag}:${version}'"
      docker import ${file} ${tag}:${version}
      docker tag ${basename} ${registry_address}/${tag}
      docker push ${registry_address}/${tag}
    done < "$input"

    clean_local_registry
    stop_docker
}

if [ -d "/images" ]; then
    populate_registry &
else
     echo "WARNING: The directory /images doesn't exist. Nothing to populate."
fi

/bin/sh /entrypoint.sh "$@"
