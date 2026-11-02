# Overview

Report on LabRabota4 — Методы и средства оркестрации в многоконтейнерных системах
(НИиСПО, ФПМИ БГУ).

Лабораторная работа №4, группа 13. По критериям оценивания группа 13 выполняет
**задания 1–2**; задание 3 (развёртывание приложения через Deployment) — только для групп 10–12.

| Задание | Каталог | Содержание | Статус |
|---------|---------|------------|--------|
| Задание 1. Подготовка окружения для локального кластера | [`task1/`](task1/) | установка `kind`/`kubectl`, конфигурация кластера (1 control-plane + 2 worker), создание и демонстрация кластера | выполнено |
| Задание 2. Знакомство с ресурсами Kubernetes | [`task2/`](task2/) | разбор системных подов, том `emptyDir` в двух контейнерах, PVC с динамическим PV, ReplicaSet (самовосстановление и масштабирование) | выполнено |
| Задание 3. Работа с Kubernetes | — | не выполняется для группы 13 | — |

## Кластер

| Параметр | Значение |
|----------|----------|
| Инструмент | `kind` v0.33.0 (Kubernetes IN Docker) |
| Версия Kubernetes | v1.37.0 (`kindest/node:v1.37.0`) |
| Узлы | `lab4-control-plane`, `lab4-worker`, `lab4-worker2` |
| Контекст kubectl | `kind-lab4` |
| API-сервер | `https://127.0.0.1:59567` |

# Usage

Отчёт по лабораторной работе: [`docs/report.md`](docs/report.md) — цель работы, вариант
задания, код конфигурационных файлов, результаты демонстраций и ответы на 23 контрольных
вопроса. Исходные файлы: [`task1/`](task1/) (задание 1) и [`task2/`](task2/) (задание 2).

Создание кластера и проверка:

```powershell
cd task1
kind create cluster --config kind-config.yaml
kubectl get nodes -o wide
kubectl get pods -A
```

Сбор доказательств в `task1/evidence/`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\collect-evidence.ps1
```

Объекты задания 2:

```powershell
cd task2
bash scripts/load-images.sh          # загрузка образов в узлы kind
kubectl apply -f manifests/          # namespace, pod с томом, PVC, pod с PVC, ReplicaSet
kubectl get all,pvc -n lab4-task2
bash scripts/collect-evidence.sh     # доказательства в task2/evidence/
```

Удаление объектов задания 2: `kubectl delete namespace lab4-task2`.
Удаление кластера: `kind delete cluster --name lab4`.

Подробности — в [task1/README.md](task1/README.md) и [task2/README.md](task2/README.md).

# Author

Цзэн Яосинь (ZENG YAOXIN), студент группы 13, ФПМИ БГУ.

# Additional Notes

Отчёт опубликован в каталоге [`docs/`](docs/) по требованиям методических указаний
(цель работы, вариант задания, код конфигураций, ответы на 23 контрольных вопроса).
Материалы, подтверждающие работу: `task1/evidence/`, `task2/evidence/` и скриншоты
в `task*/screenshots/`.

Задание 3 в репозиторий не включено: по критериям оценивания его выполняют только
группы 10–12, группа 13 сдаёт задания 1–2.
# Continuous-integration-and-software-build_LAB4
