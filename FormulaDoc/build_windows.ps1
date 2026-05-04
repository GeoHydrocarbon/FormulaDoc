# 在 FormulaDoc 目录生成 dist\FormulaDoc\FormulaDoc.exe（目录分发，Qt 更稳定）
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$py = Join-Path $root "conda_env\python.exe"
if (-not (Test-Path $py)) {
    $py = Join-Path $root "conda_env\Scripts\python.exe"
}
if (-not (Test-Path $py)) {
    Write-Error "未找到 FormulaDoc\conda_env 下可用的 python.exe。请先在当前项目目录下创建本地环境。"
}

& $py -m PyInstaller --version *> $null
if ($LASTEXITCODE -ne 0) {
    & $py -m pip install -q -r (Join-Path $root "requirements-build.txt")
    if ($LASTEXITCODE -ne 0) {
        throw "安装打包依赖失败。"
    }
}

# 某些环境会装入 pathlib 的旧回移植包，PyInstaller 会直接拒绝启动；打包前定点移除
$envRoot = Split-Path $py -Parent
if ((Split-Path $envRoot -Leaf) -ieq "Scripts") {
    $envRoot = Split-Path $envRoot -Parent
}
$sitePackages = Join-Path $envRoot "Lib\site-packages"
$pathlibTargets = @(
    (Join-Path $sitePackages "pathlib.py"),
    (Join-Path $sitePackages "pathlib-1.0.1.dist-info"),
    (Join-Path $sitePackages "__pycache__\pathlib.cpython-312.pyc"),
    (Join-Path $sitePackages "__pycache__\pathlib.cpython-313.pyc")
)
foreach ($target in $pathlibTargets) {
    if (Test-Path $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
    }
}

# 避免 PyInstaller 清理 dist 时因 exe 仍占用而 Permission denied
Stop-Process -Name "FormulaDoc" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
& $py -m PyInstaller --noconfirm --clean (Join-Path $root "FormulaDoc.spec")
if ($LASTEXITCODE -ne 0) {
    throw "PyInstaller 打包失败。"
}

Write-Host ""
Write-Host "完成。运行: $($root)\dist\FormulaDoc\FormulaDoc.exe"
