#!/usr/bin/env bash
# Создание локального кластера Kubernetes (kind) для лабораторной работы №4.
#
# Запуск из каталога task1 (Git Bash / Linux / macOS):
#   bash scripts/create-cluster.sh
#
# Требуется: Docker (запущенный), kind, kubectl.

set -euo pipefail

cd "$(dirname "$0")/.."

echo "== 1. Проверка зависимостей =="
docker version --format 'Docker server: {{.Server.Version}}'
kind version
kubectl version --client

echo "== 2. Создание кластера lab4 (1 control-plane + 2 worker) =="
kind create cluster --config kind-config.yaml

echo "== 3. Проверка кластера =="
kubectl cluster-info
kubectl get nodes -o wide

echo "Кластер готов, контекст kubectl: kind-lab4"
