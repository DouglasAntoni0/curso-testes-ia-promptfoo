# Setup completo do ambiente: Ollama + modelos Qwen + dependências + .env
# Uso (na raiz do repositório):  powershell -ExecutionPolicy Bypass -File .\setup.ps1
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$env:OLLAMA_BASE_URL = 'http://localhost:11434'

function Find-Ollama {
  $cmd = Get-Command ollama -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe",
    "$env:ProgramFiles\Ollama\ollama.exe"
  )
  foreach ($path in $candidates) { if (Test-Path $path) { return $path } }
  return $null
}

Write-Host '== 1/4 Ollama ==' -ForegroundColor Cyan
$ollama = Find-Ollama
if (-not $ollama) {
  Write-Host 'Ollama não encontrado. Instalando via winget...'
  winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
  $ollama = Find-Ollama
  if (-not $ollama) { throw 'Instalação do Ollama não encontrada. Instale manualmente em https://ollama.com/download e rode o script de novo.' }
}
Write-Host "Ollama: $ollama"

# Garante que o servidor do Ollama está respondendo em http://localhost:11434
$up = $false
try { Invoke-RestMethod "$env:OLLAMA_BASE_URL/api/version" -TimeoutSec 3 | Out-Null; $up = $true } catch {}
if (-not $up) {
  Write-Host 'Iniciando o servidor do Ollama...'
  Start-Process -FilePath $ollama -ArgumentList 'serve' -WindowStyle Hidden
  for ($i = 0; $i -lt 30 -and -not $up; $i++) {
    Start-Sleep -Seconds 1
    try { Invoke-RestMethod "$env:OLLAMA_BASE_URL/api/version" -TimeoutSec 3 | Out-Null; $up = $true } catch {}
  }
  if (-not $up) { throw "O servidor do Ollama não respondeu em $env:OLLAMA_BASE_URL" }
}

Write-Host '== 2/4 Modelos ==' -ForegroundColor Cyan
& $ollama pull qwen3.5:9b
if ($LASTEXITCODE -ne 0) { throw 'Falha ao baixar qwen3.5:9b' }
& $ollama pull qwen3.8
if ($LASTEXITCODE -ne 0) { throw 'Falha ao baixar qwen3.8' }
& $ollama list

Write-Host '== 3/4 Dependências ==' -ForegroundColor Cyan
Push-Location (Join-Path $root 'app');   npm install; Pop-Location
Push-Location (Join-Path $root 'tests'); npm install; Pop-Location

Write-Host '== 4/4 Arquivos .env ==' -ForegroundColor Cyan
foreach ($dir in 'app', 'tests') {
  $envFile = Join-Path $root "$dir\.env"
  if (-not (Test-Path $envFile)) {
    Copy-Item (Join-Path $root "$dir\.env.example") $envFile
    Write-Host "Criado $dir\.env"
  } else {
    Write-Host "$dir\.env já existe (mantido)"
  }
}

Write-Host ''
Write-Host 'Pronto!' -ForegroundColor Green
Write-Host '  App:    cd app;   npm start        -> http://localhost:3000'
Write-Host '  Testes: cd tests; npm test         (com o app rodando)'
