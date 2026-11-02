# Скриншоты для отчёта (задание 2)

Снимки делаются в терминале (`Win + Shift + S`), имена файлов — латиницей.
Все команды ниже выполняются из каталога `task2`.

| Файл | Что снять | Команды (в одном кадре) |
|------|-----------|--------------------------|
| `kube-system-pods.png` | системные поды кластера (п. 5) | `kubectl get pods -n kube-system` |
| `volume-demo.png` | общий том `emptyDir` в двух контейнерах (п. 6) | см. ниже, две команды подряд |
| `replicaset.png` | ReplicaSet, число реплик и поды (п. 7) | `kubectl get rs,pods -n lab4-task2 -l app=web-rs` |
| `pvc.png` *(необязательно)* | PVC и динамический PV | `kubectl get pvc -n lab4-task2`, затем `kubectl get pv` |

## `volume-demo.png`: как получить «совпадающий» кадр

```powershell
kubectl exec -n lab4-task2 volume-demo -c writer -- head -3 /data/log.txt
kubectl exec -n lab4-task2 volume-demo -c reader -- sh -c "wget -qO- http://localhost/ | head -3"
```

Обе команды выводят **первые три строки** файла: у `writer` — прямо из тома,
у `reader` — по HTTP через nginx из того же тома. Строки совпадают побайтно,
это и есть доказательство общего тома.

> Почему `head`, а не `tail`: `writer` дописывает строку каждые 5 секунд, поэтому
> конец файла постоянно меняется и два снимка `tail` не совпали бы. Начало файла неизменно.

В PowerShell двойные кавычки вокруг `wget ... | head -3` обязательны: без них `|`
будет воспринят как конвейер PowerShell, а не контейнера.

Листинги тех же команд лежат в каталоге [`../evidence/`](../evidence/),
поэтому скриншоты — дополнение, а не единственное доказательство.

## Что должно быть видно

* `kube-system-pods.png` — 12 строк, все `STATUS=Running`;
* `volume-demo.png` — одинаковые строки `record 1…3 from volume-demo at …` в обоих выводах;
* `replicaset.png` — `DESIRED/CURRENT/READY` равны 3 и ровно три пода `web-rs-*`;
* `pvc.png` — `data-pvc` в статусе `Bound`, рядом PV `pvc-…` с `CAPACITY 128Mi`.
