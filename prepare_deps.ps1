# prepare_deps.ps1
$depRoot = Join-Path $PWD.Path "deps"
New-Item -ItemType Directory -Force -Path $depRoot | Out-Null

# OpenSSL Win64
$sslZip = Join-Path $depRoot "openssl.zip"
Invoke-WebRequest -Uri "https://github.com/IndySquad/openssl-windows-binaries/releases/download/3.0.12/openssl-3.0.12-x64.zip" -OutFile $sslZip
Expand-Archive $sslZip -DestinationPath (Join-Path $depRoot "openssl-win64") -Force

# pthreads-win32
$pthreadZip = Join-Path $depRoot "pthreads.zip"
Invoke-WebRequest -Uri "https://github.com/GerHobbelt/pthread-win32/releases/download/v3.0.0/pthreads-w64.zip" -OutFile $pthreadZip
Expand-Archive $pthreadZip -DestinationPath (Join-Path $depRoot "pthreads-win64") -Force

# PCRE Win64
$pcreZip = Join-Path $depRoot "pcre.zip"
Invoke-WebRequest -Uri "https://github.com/10gic/vanitygen-plusplus-deps/raw/main/pcre-w64.zip" -OutFile $pcreZip
Expand-Archive $pcreZip -DestinationPath (Join-Path $depRoot "pcre-win64") -Force

Write-Host "Dependencies download & extract finished."
