#!/bin/bash
docker rm -f homelib-kiwix 2>/dev/null; docker rmi ghcr.io/kiwix/kiwix-tools:latest 2>/dev/null; echo "✅ Удалён"
