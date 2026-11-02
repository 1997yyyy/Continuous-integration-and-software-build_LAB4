#!/usr/bin/env bash
# Загрузка образов в узлы kind без обращения к Docker Hub.
#
# Зачем: в этом окружении включён containerd-image-store в Docker Desktop,
# поэтому `kind load docker-image` падает с ошибкой
# "ctr: content digest ...: not found" (в архиве нет блобов чужих платформ),
# а kubelet не может тянуть образы из registry (в контейнерах недоступен proxy).
# Решение: `docker save` -> поток в контейнер узла -> `ctr images import --platform linux/amd64`.
#
# Запуск из каталога task2:
#   bash scripts/load-images.sh nginx:alpine python:3.12.1-alpine

set -euo pipefail

IMAGES=("$@")
if [ ${#IMAGES[@]} -eq 0 ]; then
    IMAGES=("nginx:alpine" "python:3.12.1-alpine")
fi

NODES=(lab4-control-plane lab4-worker lab4-worker2)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

for image in "${IMAGES[@]}"; do
    file="$TMP/$(echo "$image" | tr '/:' '__').tar"
    echo "==> docker save $image"
    docker save "$image" -o "$file"

    for node in "${NODES[@]}"; do
        echo "    -> $node"
        # MSYS_NO_PATHCONV обязателен в Git Bash, иначе /tmp превращается в C:/...
        MSYS_NO_PATHCONV=1 docker exec -i "$node" sh -c 'cat > /tmp/image.tar' <"$file"
        MSYS_NO_PATHCONV=1 docker exec "$node" \
            ctr -n k8s.io images import --platform linux/amd64 \
            --snapshotter=overlayfs /tmp/image.tar >/dev/null
        MSYS_NO_PATHCONV=1 docker exec "$node" rm -f /tmp/image.tar
    done
done

echo "Готово: образы загружены на ${#NODES[@]} узла(ов)."
