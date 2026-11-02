#!/usr/bin/env bash
# Сбор доказательств работающего кластера Kubernetes (задание 1) в каталог evidence/.
#
# Запуск из каталога task1 (Git Bash / Linux / macOS):
#   bash scripts/collect-evidence.sh

set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p evidence

save() {
    local file="evidence/$1"
    shift
    { echo "\$ $*"; "$@"; } >"$file" 2>&1
    echo "saved: $file"
}

{
    echo '$ docker version --format "{{.Server.Version}} ({{.Server.Os}}/{{.Server.Arch}})"'
    docker version --format '{{.Server.Version}} ({{.Server.Os}}/{{.Server.Arch}})'
    echo '$ kind version'
    kind version
    echo '$ kubectl version'
    kubectl version
} >evidence/01-versions.txt 2>&1
echo "saved: evidence/01-versions.txt"
save 02-cluster-info.txt    kubectl cluster-info
save 03-nodes.txt           kubectl get nodes -o wide
save 04-namespaces.txt      kubectl get namespaces
save 05-pods-all.txt        kubectl get pods -A -o wide
save 06-kind-clusters.txt   kind get clusters
save 07-kubeconfig-context.txt kubectl config get-contexts
save 09-node-labels.txt     kubectl get nodes -L tier

{
    echo '$ kubectl get nodes -o wide'
    kubectl get nodes -o wide
    echo
    echo '$ kubectl get pods -A'
    kubectl get pods -A
} >evidence/08-demo-summary.txt 2>&1
echo "saved: evidence/08-demo-summary.txt"

echo "Готово: результаты в каталоге evidence/"
