#!/bin/bash
NAME="homelib-kiwix"
PORT="8084"
ZIM="/mnt/hdd1/docker/kiwix"
docker rm -f $NAME 2>/dev/null
mkdir -p $ZIM
echo '<?xml version="1.0"?><library version="20110515"></library>' > $ZIM/library.xml
docker run -d --name $NAME -p $PORT:8080 -v $ZIM:/data --restart unless-stopped ghcr.io/kiwix/kiwix-tools:latest kiwix-serve --port=8080 --nolibrarybutton --library /data/library.xml
echo "✅ Kiwix: http://192.168.1.46:$PORT/"
