#!/usr/bin/env bash
# Сбор доказательств по заданию 2 в каталог evidence/.
#
# Запуск из каталога task2 (Git Bash / Linux):
#   bash scripts/collect-evidence.sh
#
# Скрипт не только снимает состояние, но и заново проделывает демонстрации:
# удаляет один pod ReplicaSet (тот создаётся заново) и масштабирует набор 3 -> 5 -> 3.

set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p evidence
NS=lab4-task2

save() {
    local file="evidence/$1"
    shift
    { echo "\$ $*"; "$@"; } >"$file" 2>&1
    echo "saved: $file"
}

# --- 1. Ресурсы кластера: api-resources, namespaces -------------------------
{
    echo '$ kubectl api-resources | wc -l'
    kubectl api-resources --no-headers | wc -l
    echo
    echo '$ kubectl api-resources --api-group=apps'
    kubectl api-resources --api-group=apps
    echo
    echo '$ kubectl api-resources --api-group=""  # core/v1'
    kubectl api-resources --api-group="" | head -20
    echo
    echo '$ kubectl get ns'
    kubectl get ns
    echo
    echo '$ kubectl get ns lab4-task2 --show-labels'
    kubectl get ns lab4-task2 --show-labels
} >evidence/01-api-resources.txt 2>&1
echo "saved: evidence/01-api-resources.txt"

# --- 2. Системные поды (п. 5 задания) --------------------------------------
save 02-kube-system-pods.txt kubectl get pods -n kube-system -o wide

save 03-kube-system-images.txt kubectl get pods -n kube-system -o custom-columns='NAME:.metadata.name,NODE:.spec.nodeName,IMAGE:.spec.containers[0].image'

# --- 3. Том emptyDir, смонтированный в два контейнера (п. 6) ---------------
{
    echo '$ kubectl get pod volume-demo -n lab4-task2 -o wide'
    kubectl get pod volume-demo -n "$NS" -o wide
    echo
    echo '$ kubectl describe pod volume-demo -n lab4-task2 | sed -n "/Volumes:/,/Events:/p"'
    kubectl describe pod volume-demo -n "$NS" | sed -n '/Volumes:/,/Events:/p'
    echo
    echo '$ kubectl exec volume-demo -c writer -- ls -l /data'
    kubectl exec -n "$NS" volume-demo -c writer -- ls -l /data
    echo
    echo '$ kubectl exec volume-demo -c writer -- head -3 /data/log.txt'
    kubectl exec -n "$NS" volume-demo -c writer -- head -3 /data/log.txt
    echo
    echo '$ kubectl exec volume-demo -c writer -- wc -l /data/log.txt'
    kubectl exec -n "$NS" volume-demo -c writer -- wc -l /data/log.txt
    echo
    echo '$ kubectl exec volume-demo -c reader -- ls -l /usr/share/nginx/html'
    kubectl exec -n "$NS" volume-demo -c reader -- ls -l /usr/share/nginx/html
    echo
    echo '$ kubectl exec volume-demo -c reader -- wget -qO- http://localhost/ | head -3'
    kubectl exec -n "$NS" volume-demo -c reader -- sh -c 'wget -qO- http://localhost/ | head -3'
} >evidence/04-volume-emptydir.txt 2>&1
echo "saved: evidence/04-volume-emptydir.txt"

# --- 4. PVC: динамический PV и сохранность данных -------------------------
{
    echo '$ kubectl get pvc -n lab4-task2'
    kubectl get pvc -n "$NS"
    echo
    echo '$ kubectl get pv'
    kubectl get pv
    echo
    echo '$ kubectl describe pvc data-pvc -n lab4-task2 | sed -n "/Name:/,/Events:/p"'
    kubectl describe pvc data-pvc -n "$NS" | sed -n '/Name:/,/Events:/p'
} >evidence/05-pvc.txt 2>&1
echo "saved: evidence/05-pvc.txt"

{
    echo '# 1) записываем файл в том'
    echo '$ kubectl exec pvc-demo -- sh -c "..."'
    kubectl exec -n "$NS" pvc-demo -- sh -c \
        'echo "written by pod $HOSTNAME at $(date +%Y-%m-%dT%H:%M:%S)" > /data/persist.txt; cat /data/persist.txt'
    echo
    echo '# 2) удаляем pod'
    echo '$ kubectl delete pod pvc-demo -n lab4-task2'
    kubectl delete pod pvc-demo -n "$NS"
    echo
    echo '# 3) создаём pod заново из того же манифеста'
    echo '$ kubectl apply -f manifests/03-pod-pvc.yaml'
    kubectl apply -f manifests/03-pod-pvc.yaml
    echo
    echo '$ kubectl wait --for=condition=Ready pod/pvc-demo -n lab4-task2 --timeout=90s'
    kubectl wait --for=condition=Ready pod/pvc-demo -n "$NS" --timeout=90s
    echo
    echo '# 4) читаем файл в новом pod — данные на месте'
    echo '$ kubectl exec pvc-demo -- cat /data/persist.txt'
    kubectl exec -n "$NS" pvc-demo -- cat /data/persist.txt
} >evidence/06-pvc-persistence.txt 2>&1
echo "saved: evidence/06-pvc-persistence.txt"

# --- 5. ReplicaSet: набор подов, самовосстановление, масштабирование -------
{
    echo '# исходное состояние'
    echo '$ kubectl get rs -n lab4-task2 web-rs'
    kubectl get rs -n "$NS" web-rs
    echo
    echo '$ kubectl get pods -n lab4-task2 -l app=web-rs -o wide'
    kubectl get pods -n "$NS" -l app=web-rs -o wide
    echo
    echo '# удаляем один pod: ReplicaSet должен создать замену'
    VICTIM=$(kubectl get pods -n "$NS" -l app=web-rs -o jsonpath='{.items[0].metadata.name}')
    echo "\$ kubectl delete pod $VICTIM -n lab4-task2"
    kubectl delete pod "$VICTIM" -n "$NS"
    sleep 8
    echo
    echo '$ kubectl get pods -n lab4-task2 -l app=web-rs -o wide'
    kubectl get pods -n "$NS" -l app=web-rs -o wide
    echo
    echo '$ kubectl get rs -n lab4-task2 web-rs'
    kubectl get rs -n "$NS" web-rs
} >evidence/07-replicaset.txt 2>&1
echo "saved: evidence/07-replicaset.txt"

{
    echo '# масштабирование 3 -> 5'
    echo '$ kubectl scale rs web-rs --replicas=5 -n lab4-task2'
    kubectl scale rs web-rs --replicas=5 -n "$NS"
    sleep 8
    kubectl get rs -n "$NS" web-rs
    kubectl get pods -n "$NS" -l app=web-rs -o wide
    echo
    echo '# масштабирование 5 -> 3'
    echo '$ kubectl scale rs web-rs --replicas=3 -n lab4-task2'
    kubectl scale rs web-rs --replicas=3 -n "$NS"
    sleep 8
    kubectl get rs -n "$NS" web-rs
    kubectl get pods -n "$NS" -l app=web-rs -o wide
} >evidence/08-replicaset-scale.txt 2>&1
echo "saved: evidence/08-replicaset-scale.txt"

# --- 6. Сводка -------------------------------------------------------------
{
    echo '$ kubectl get all -n lab4-task2'
    kubectl get all -n "$NS"
    echo
    echo '$ kubectl get pvc,pv -n lab4-task2'
    kubectl get pvc -n "$NS"
    kubectl get pv
} >evidence/09-summary.txt 2>&1
echo "saved: evidence/09-summary.txt"

echo "Готово: результаты в каталоге evidence/"
