# Удаление кластера lab4.
# Запускать из каталога task1:  powershell -ExecutionPolicy Bypass -File .\scripts\delete-cluster.ps1

$ErrorActionPreference = "Stop"
kind delete cluster --name lab4
Write-Host "Кластер lab4 удалён." -ForegroundColor Yellow
