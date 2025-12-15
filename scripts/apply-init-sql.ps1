# PowerShell 脚本：手动执行初始化 SQL
# 这个脚本可以在数据库已存在的情况下重新执行初始化 SQL

Write-Host "正在执行初始化 SQL 脚本..." -ForegroundColor Cyan

# 检查容器是否运行
$containerName = "allia-graph-postgres-custom-1"
$containerExists = docker ps --format "{{.Names}}" | Select-String -Pattern $containerName

if (-not $containerExists) {
    Write-Host "错误: postgres-custom 容器未运行" -ForegroundColor Red
    Write-Host "请先运行: docker-compose up -d postgres-custom" -ForegroundColor Yellow
    exit 1
}

# 获取脚本目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlFile = Join-Path $scriptDir "init-custom-db.sql"

# 执行 SQL 脚本
Get-Content $sqlFile | docker exec -i $containerName psql -U custom_user -d custom_db

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SQL 脚本执行成功" -ForegroundColor Green
} else {
    Write-Host "❌ SQL 脚本执行失败" -ForegroundColor Red
    exit 1
}

