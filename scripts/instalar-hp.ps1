# Instala hp-agent en el HP (Windows 10 o posterior, 64 bits) y lo deja arrancando al iniciar sesión.
# Se puede repetir. Por defecto la tarea lleva --live: telemetría, y bloquear, reiniciar y apagar con 60 s.
# -DryRun deja solo la telemetría. -Desinstalar quita la tarea, la carpeta y la configuración. No desinstala Python.
#
# Una línea, en PowerShell como administrador (la contraseña de la Pi la pide ssh; el token no se muestra):
#   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $u='https://raw.githubusercontent.com/Sopa-IA/Control-deck/cursor/bandeja-v2-modular-6d15/scripts/instalar-hp.ps1'; $p=Join-Path $env:TEMP 'instalar-hp.ps1'; Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $p; powershell -NoProfile -ExecutionPolicy Bypass -File $p
# Solo mirar, la misma línea y al final: -DryRun
#
# El token está en el .env de la raíz del clon. scripts/gen-token.sh lo escribe ahí y
# scripts/instalar-pi.sh lo copia a /etc/orbit/orbitd.env (ese archivo es de root: orbit no lo lee).
# En la Pi de Miguel el clon es /home/orbit/Control-deck/.env.
#Requires -Version 5.1

param(
    [switch]$DryRun,
    [switch]$Desinstalar,
    [string]$PiHost = '10.0.0.2',
    [string]$PiUser = 'orbit',
    [string]$HubUrl = 'ws://10.0.0.2:8765/ws',
    [string]$Destino = 'C:\Orbit\Control-deck',
    [string]$Rama = 'cursor/bandeja-v2-modular-6d15'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    # .NET ya usa TLS del sistema.
}

$Tarea = 'OrbitHpAgent'
$PythonUrl = 'https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe'
$OrbitTokenPy = @'
import os, pathlib, sys
extra = os.environ.get("ORBIT_ENV_DIR", "").strip()
if extra:
    cands = [pathlib.Path(extra)]
else:
    cands = [
        pathlib.Path.home() / "Control-deck" / ".env",
        pathlib.Path("/home/orbit/Control-deck/.env"),
    ]
seen = set()
for p in cands:
    key = str(p)
    if key in seen:
        continue
    seen.add(key)
    if not p.is_file():
        continue
    try:
        lines = p.read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        continue
    for line in lines:
        if line.startswith("\ufeff"):
            line = line.lstrip("\ufeff")
        if not line.startswith("ORBIT_HP_TOKEN="):
            continue
        value = line.split("=", 1)[1].strip().strip('"').strip("'")
        if value:
            sys.stdout.write(value)
            raise SystemExit(0)
sys.stderr.write("sin-token\n")
raise SystemExit(1)
'@

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = New-Object Security.Principal.WindowsPrincipal($id)
    return $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Paso([string]$Texto) {
    Write-Host "== $Texto"
}

function Stop-OrbitProcesos {
    try {
        Get-CimInstance Win32_Process -Filter "Name = 'pythonw.exe' OR Name = 'python.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -and ($_.CommandLine -like '*-m hp_agent*') } |
            ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    } catch {
        # No hay procesos que parar.
    }
}

function Stop-OrbitTarea {
    $existe = Get-ScheduledTask -TaskName $Tarea -ErrorAction SilentlyContinue
    if (-not $existe) { return }
    Stop-ScheduledTask -TaskName $Tarea -ErrorAction SilentlyContinue
    for ($i = 0; $i -lt 20; $i++) {
        $t = Get-ScheduledTask -TaskName $Tarea -ErrorAction SilentlyContinue
        if (-not $t -or $t.State -ne 'Running') { break }
        Start-Sleep -Milliseconds 400
    }
    Stop-OrbitProcesos
}

function Remove-OrbitInstalacion {
    Write-Paso "Quito la tarea, la carpeta y la configuración"
    Stop-OrbitTarea
    Unregister-ScheduledTask -TaskName $Tarea -Confirm:$false -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $Destino) {
        Remove-Item -LiteralPath $Destino -Recurse -Force
    }
    $toml = Join-Path $env:APPDATA 'orbit\hp-agent.toml'
    if (Test-Path -LiteralPath $toml) {
        Remove-Item -LiteralPath $toml -Force
    }
    $logDir = Join-Path $env:LOCALAPPDATA 'orbit'
    foreach ($nombre in @('hp-agent.log', 'hp-agent.log.1', 'hp-agent.log.2')) {
        $f = Join-Path $logDir $nombre
        if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f -Force }
    }
    Write-Host "hp-agent desinstalado. Python 3.12, si se instaló, sigue en el equipo."
    Write-Host "Para instalar otra vez, la misma línea de PowerShell, sin -Desinstalar."
}

function Find-Python312 {
    $fijos = @(
        (Join-Path $env:ProgramFiles 'Python312\python.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Python312\python.exe'),
        (Join-Path $env:LocalAppData 'Programs\Python\Python312\python.exe')
    )
    foreach ($c in $fijos) {
        if ($c -and (Test-Path -LiteralPath $c)) { return $c }
    }
    $py = Join-Path $env:WINDIR 'py.exe'
    if (Test-Path -LiteralPath $py) {
        $exe = & $py -3.12 -c "import sys; print(sys.executable)" 2>$null
        if ($LASTEXITCODE -eq 0 -and $exe) {
            $uno = ($exe | Select-Object -First 1).ToString().Trim()
            if (Test-Path -LiteralPath $uno) { return $uno }
        }
    }
    return $null
}

function Install-Python312 {
    $ya = Find-Python312
    if ($ya) {
        Write-Paso "Python 3.12 ya está"
        return $ya
    }
    Write-Paso "Instalo Python 3.12"
    $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($winget) {
        & winget.exe install --id Python.Python.3.12 -e --scope machine --accept-package-agreements --accept-source-agreements --disable-interactivity
        $ya = Find-Python312
        if ($ya) { return $ya }
        Write-Host "winget no ha dejado Python 3.12. Sigo con el instalador oficial."
    } else {
        Write-Host "No hay winget. Bajo el instalador oficial de Python 3.12."
    }
    $setup = Join-Path $env:TEMP 'python-3.12.10-amd64.exe'
    Invoke-WebRequest -UseBasicParsing -Uri $PythonUrl -OutFile $setup
    $proc = Start-Process -FilePath $setup -Wait -PassThru -ArgumentList @(
        '/quiet', 'InstallAllUsers=1', 'PrependPath=1', 'Include_pip=1',
        'Include_test=0', 'Include_launcher=1', 'Shortcuts=0'
    )
    if ($proc.ExitCode -ne 0) {
        throw "El instalador de Python terminó con código $($proc.ExitCode)."
    }
    $ya = Find-Python312
    if (-not $ya) {
        throw "Python 3.12 no aparece tras instalarlo. Se buscó en $env:ProgramFiles\Python312\python.exe."
    }
    return $ya
}

function Ensure-OpenSsh {
    $ssh = Join-Path $env:WINDIR 'System32\OpenSSH\ssh.exe'
    if (Test-Path -LiteralPath $ssh) { return $ssh }
    $cmd = Get-Command ssh.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    Write-Paso "Instalo el cliente OpenSSH (hace falta para leer el token en la Pi)"
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 | Out-Null
    if (Test-Path -LiteralPath $ssh) { return $ssh }
    throw "No está ssh.exe. En Características opcionales, añade Cliente de OpenSSH y vuelve a lanzar esto."
}

function Get-TomlToken([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        if ($line -match '^\s*token\s*=\s*"(.*)"\s*$') {
            return $Matches[1]
        }
    }
    return $null
}

function Test-TokenForma([string]$Value) {
    return ($Value -match '^[A-Za-z0-9_-]{20,200}$')
}

function Get-TokenDeLaPi([string]$Ssh) {
    # stdout va a una tubería (el valor no sale en pantalla). La contraseña la pide ssh en la consola.
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($OrbitTokenPy))
    # B64 es [A-Za-z0-9+/=]: no lleva comillas ni $. La orden remota queda entre comillas para bash.
    $remoto = "python3 -c `"import base64; exec(base64.b64decode('$b64').decode())`""
    $remotoCmd = $remoto.Replace('\', '\\').Replace('"', '\"')
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Ssh
    $psi.Arguments = "-o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 -o NumberOfPasswordPrompts=3 ${PiUser}@${PiHost} `"$remotoCmd`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $false
    $psi.RedirectStandardError = $false
    $psi.RedirectStandardOutput = $true
    $psi.CreateNoWindow = $false
    try { $psi.StandardOutputEncoding = [Text.Encoding]::UTF8 } catch { }
    Write-Host "SSH a ${PiUser}@${PiHost}. Escribe la contraseña de la Pi. El token no se muestra."
    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    $raw = $proc.StandardOutput.ReadToEnd()
    $proc.WaitForExit()
    $code = $proc.ExitCode
    $leido = ($raw -replace '[\0\r\n]', '').Trim()
    if ($code -ne 0 -or -not (Test-TokenForma $leido)) {
        return $null
    }
    return $leido
}

function Write-OrbitToml([string]$Path, [string]$Token, [bool]$EnVivo, [string]$Url) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
    $tail = ''
    if (Test-Path -LiteralPath $Path) {
        $prev = [System.IO.File]::ReadAllText($Path)
        $idx = $prev.IndexOf("[apps]")
        if ($idx -ge 0) { $tail = $prev.Substring($idx).Trim() }
    }
    $esc = $Token.Replace('\', '\\').Replace('"', '\"')
    $flag = 'false'
    if ($EnVivo) { $flag = 'true' }
    $cuerpo = @(
        "hub_url = `"$Url`"",
        "token = `"$esc`"",
        'telemetry_period_s = 2.0',
        "live = $flag",
        ''
    ) -join "`n"
    if ($tail) { $cuerpo = $cuerpo + $tail + "`n" }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $cuerpo, $utf8)
    & icacls.exe $Path /inheritance:r /grant:r "${env:USERDOMAIN}\${env:USERNAME}:(R,W)" | Out-Null
}

function Register-OrbitTarea([string]$PythonW, [string]$Trabajo, [string]$Argumentos) {
    $cuenta = "$env:USERDOMAIN\$env:USERNAME"
    function Esc([string]$s) {
        return ($s -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;')
    }
    $xml = @"
<?xml version="1.0"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Orbit Terminal hp-agent. Telemetría hacia la Pi. Órdenes reales si los argumentos llevan --live.</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <UserId>$(Esc $cuenta)</UserId>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$(Esc $cuenta)</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>999</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$(Esc $PythonW)</Command>
      <Arguments>$(Esc $Argumentos)</Arguments>
      <WorkingDirectory>$(Esc $Trabajo)</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@
    Register-ScheduledTask -TaskName $Tarea -Xml $xml -Force | Out-Null
}

if (-not (Test-Admin)) {
    Write-Host "Ábrelo en PowerShell como administrador: clic derecho, Ejecutar como administrador."
    exit 1
}
if (-not [Environment]::Is64BitOperatingSystem) {
    Write-Host "Hace falta Windows de 64 bits."
    exit 1
}

if ($Desinstalar) {
    Remove-OrbitInstalacion
    exit 0
}

New-Item -ItemType Directory -Force -Path 'C:\Orbit' | Out-Null
if ($PSCommandPath) {
    Copy-Item -LiteralPath $PSCommandPath -Destination 'C:\Orbit\instalar-hp.ps1' -Force
}

Write-Paso "Paro el agente si ya estaba en marcha"
Stop-OrbitTarea

$python = Install-Python312
$ver = (& $python -c "import sys; print('%d.%d' % sys.version_info[:2])").ToString().Trim()
if ($ver -ne '3.12') {
    throw "Se esperaba Python 3.12 y está $ver ($python)."
}

Write-Paso "Bajo la rama $Rama (zip, sin git)"
$zip = Join-Path $env:TEMP 'orbit-control-deck.zip'
$stage = Join-Path $env:TEMP ('orbit-src-' + [guid]::NewGuid().ToString('n'))
$zipUrl = "https://github.com/Sopa-IA/Control-deck/archive/refs/heads/$Rama.zip"
Invoke-WebRequest -UseBasicParsing -Uri $zipUrl -OutFile $zip
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Expand-Archive -LiteralPath $zip -DestinationPath $stage -Force
$raiz = Get-ChildItem -LiteralPath $stage -Directory | Select-Object -First 1
if (-not $raiz) { throw "El zip de la rama no trae carpeta." }
if (-not (Test-Path -LiteralPath $Destino)) {
    New-Item -ItemType Directory -Force -Path $Destino | Out-Null
}
Get-ChildItem -LiteralPath $Destino -Force | Where-Object { $_.Name -ne '.venv' } | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $raiz.FullName '*') -Destination $Destino -Recurse -Force
Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue

Write-Paso "Entorno Python e instalación de hp-agent"
$venvPy = Join-Path $Destino '.venv\Scripts\python.exe'
$venvOk = $false
if (Test-Path -LiteralPath $venvPy) {
    $vver = (& $venvPy -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null)
    if ($LASTEXITCODE -eq 0 -and "$vver".Trim() -eq '3.12') { $venvOk = $true }
}
if (-not $venvOk) {
    if (Test-Path -LiteralPath (Join-Path $Destino '.venv')) {
        Remove-Item -LiteralPath (Join-Path $Destino '.venv') -Recurse -Force
    }
    & $python -m venv (Join-Path $Destino '.venv')
    if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el venv." }
}
$venvPy = Join-Path $Destino '.venv\Scripts\python.exe'
$venvW = Join-Path $Destino '.venv\Scripts\pythonw.exe'
if (-not (Test-Path -LiteralPath $venvW)) {
    throw "No está pythonw.exe en el venv. Sin él la tarea abriría una ventana."
}
& $venvPy -m pip install -U pip
if ($LASTEXITCODE -ne 0) { throw "pip no se actualizó. El HP necesita internet, además del cable 10.0.0.1." }
& $venvPy -m pip install -e (Join-Path $Destino 'software\shared\python') -e (Join-Path $Destino 'software\hp-agent')
if ($LASTEXITCODE -ne 0) { throw "No se instaló hp-agent. El HP necesita internet para PyPI." }

$toml = Join-Path $env:APPDATA 'orbit\hp-agent.toml'
Write-Paso "Leo el token en la Pi (no se muestra)"
$ssh = Ensure-OpenSsh
$token = Get-TokenDeLaPi $ssh
if (-not (Test-TokenForma $token)) {
    $previo = Get-TomlToken $toml
    if (Test-TokenForma $previo) {
        Write-Host "No se ha podido leer el token de la Pi. Se deja el que ya estaba. No se muestra."
        $token = $previo
    } else {
        throw "No hay ORBIT_HP_TOKEN en /home/orbit/Control-deck/.env (raíz del clon, el .env de instalar-pi.sh). SSH tiene que entrar como ${PiUser}@${PiHost}. No se muestra el valor."
    }
}
$enVivo = -not $DryRun
$argumentos = '-m hp_agent'
if ($enVivo) { $argumentos = '-m hp_agent --live' }
try {
    Write-OrbitToml -Path $toml -Token $token -EnVivo $enVivo -Url $HubUrl
} catch {
    throw "No se pudo escribir la configuración de hp-agent. El token no se muestra."
}
$token = $null

Write-Paso "Tarea al iniciar sesión, oculta, y la arranco"
Register-OrbitTarea -PythonW $venvW -Trabajo $Destino -Argumentos $argumentos
Start-ScheduledTask -TaskName $Tarea
Start-Sleep -Seconds 3
$estado = (Get-ScheduledTask -TaskName $Tarea).State
$info = Get-ScheduledTaskInfo -TaskName $Tarea
$log = Join-Path $env:LOCALAPPDATA 'orbit\hp-agent.log'

Write-Host ""
if ($DryRun) {
    Write-Host "Listo. hp-agent está en seco: solo telemetría. Bloquear, Reiniciar y Apagar no se ejecutan."
    Write-Host "En el registro tiene que decir DRY-RUN."
} else {
    Write-Host "Listo. hp-agent está en vivo: telemetría, y Bloquear, Reiniciar y Apagar (60 s) sí se ejecutan."
    Write-Host "En el registro tiene que decir conectado a $HubUrl y LIVE."
}
Write-Host "Tarea: $Tarea. Estado: $estado. Último resultado: $($info.LastTaskResult)."
Write-Host "En Orbit OS, Sistemas, la tarjeta del HP tiene que decir hp-agent conectado."
Write-Host "La temperatura puede salir como raya: este Windows no da sensores a psutil."
Write-Host "Registro: $log"
Write-Host "Comprobar la tarea: schtasks /Query /TN $Tarea /FO LIST /V"
if ($DryRun) {
    Write-Host "Para activar bloquear, reiniciar y apagar, lanza otra vez la misma línea sin -DryRun."
} else {
    Write-Host "Para dejar solo la telemetría, la misma línea y al final -DryRun."
}
Write-Host "Desinstalar: powershell -NoProfile -ExecutionPolicy Bypass -File C:\Orbit\instalar-hp.ps1 -Desinstalar"
exit 0
