# Создание локального кластера Kubernetes (kind) для лабораторной работы №4.
#
# Запуск из каталога task1:
#   powershell -ExecutionPolicy Bypass -File .\scripts\create-cluster.ps1

$ErrorActionPreference = "Stop"

$candidates = @(
    (Join-Path $env:USERPROFILE "bin"),
    "C:\Program Files\Docker\Docker\resources\bin",
    (Join-Path $env:LOCALAPPDATA "Programs\DockerDesktop\resources\bin")
)
$env:Path = ($candidates -join ";") + ";" + $env:Path

$kind    = (Get-Command kind.exe    -ErrorAction SilentlyContinue).Source
$kubectl = (Get-Command kubectl.exe -ErrorAction SilentlyContinue).Source

if (-not $kind -or -not $kubectl) {
    Write-Host "kind/kubectl не найдены. Установите утилиты (см. README) и повторите." -ForegroundColor Red
    exit 1
}

Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "== 1. Проверка Docker ==" -ForegroundColor Cyan
& docker.exe version --format "Docker server: {{.Server.Version}}"

Write-Host "== 2. Создание кластера lab4 (1 control-plane + 2 worker) ==" -ForegroundColor Cyan
& $kind create cluster --config .\kind-config.yaml

Write-Host "== 3. Проверка кластера ==" -ForegroundColor Cyan
& $kubectl cluster-info
& $kubectl get nodes -o wide

Write-Host "Кластер готов, контекст kubectl: kind-lab4" -ForegroundColor Green
