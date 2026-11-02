# Скриншоты для отчёта (задание 1)

Снимки делаются в терминале, имена файлов — как указано ниже (латиница, чтобы не ломать Git).

| Файл | Что снять | Команда |
|------|-----------|---------|
| `kubectl-get-nodes.png` | три узла в состоянии `Ready` | `kubectl get nodes -o wide` |
| `kubectl-get-pods.png` | служебные поды в состоянии `Running` | `kubectl get pods -A` |
| `kind-create-cluster.png` *(необязательно)* | процесс создания кластера | `kind create cluster --config kind-config.yaml` |

Третий снимок делается только при пересоздании кластера: если кластер уже существует,
`kind create cluster` завершится ошибкой «node(s) already exist for a cluster with the name lab4».

Листинги тех же команд уже сохранены в каталоге [`../evidence/`](../evidence/),
поэтому скриншоты — дополнение, а не единственное доказательство.
