# Сбор доказательств работающего кластера Kubernetes (задание 1) в каталог evidence/.
#
# Запуск из каталога task1:
#   powershell -ExecutionPolicy Bypass -File .\scripts\collect-evidence.ps1

$ErrorActionPreference = "Continue"

# Каталоги, где обычно лежат утилиты (kind ставится в %USERPROFILE%\bin, kubectl/docker — с Docker Desktop)
$candidates = @(
    (Join-Path $env:USERPROFILE "bin"),
    "C:\Program Files\Docker\Docker\resources\bin",
    (Join-Path $env:LOCALAPPDATA "Programs\DockerDesktop\resources\bin")
)
$env:Path = ($candidates -join ";") + ";" + $env:Path

$docker  = (Get-Command docker.exe  -ErrorAction SilentlyContinue).Source
$kind    = (Get-Command kind.exe    -ErrorAction SilentlyContinue).Source
$kubectl = (Get-Command kubectl.exe -ErrorAction SilentlyContinue).Source

if (-not $kubectl -or -not $kind) {
    Write-Host "kubectl или kind не найдены в PATH. Установите утилиты и повторите." -ForegroundColor Red
    exit 1
}

Set-Location (Join-Path $PSScriptRoot "..")
New-Item -ItemType Directory -Force -Path .\evidence | Out-Null

function Save([string]$file, [string]$header, [scriptblock]$body) {
    $header | Out-File -FilePath $file -Encoding utf8
    & $body 2>&1 | Out-File -FilePath $file -Append -Encoding utf8
    Write-Host ("saved: " + $file) -ForegroundColor Green
}

Save ".\evidence\01-versions.txt" '$ docker version --format "Docker server: {{.Server.Version}}" / kind version / kubectl version' {
    & $docker version --format "Docker server: {{.Server.Version}}"
    & $kind version
    & $kubectl version
}

Save ".\evidence\02-cluster-info.txt" '$ kubectl cluster-info' {
    & $kubectl cluster-info
}

Save ".\evidence\03-nodes.txt" '$ kubectl get nodes -o wide' {
    & $kubectl get nodes -o wide
}

Save ".\evidence\04-namespaces.txt" '$ kubectl get namespaces' {
    & $kubectl get namespaces
}

Save ".\evidence\05-pods-all.txt" '$ kubectl get pods -A -o wide' {
    & $kubectl get pods -A -o wide
}

Save ".\evidence\06-kind-clusters.txt" '$ kind get clusters' {
    & $kind get clusters
}

Save ".\evidence\07-kubeconfig-context.txt" '$ kubectl config get-contexts' {
    & $kubectl config get-contexts
}

Save ".\evidence\09-node-labels.txt" '$ kubectl get nodes -L tier' {
    & $kubectl get nodes -L tier
}

Write-Host "Готово: результаты в каталоге evidence/" -ForegroundColor Green
