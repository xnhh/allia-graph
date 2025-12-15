# PowerShell 设置脚本
# 用于初始化 The Graph 子图项目

Write-Host "🚀 初始化 Allia Graph 子图项目..." -ForegroundColor Green

# 检查 Node.js 是否安装
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js 版本: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误: 未找到 Node.js，请先安装 Node.js" -ForegroundColor Red
    exit 1
}

# 检查 Docker 是否安装（可选）
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker 已安装" -ForegroundColor Green
} catch {
    Write-Host "⚠️  警告: 未找到 Docker，将无法使用 Docker Compose 启动本地 Graph Node" -ForegroundColor Yellow
}

# 安装依赖
Write-Host "📦 安装依赖..." -ForegroundColor Cyan
npm install

# 检查是否配置了 API Key
if (-not $env:ALCHEMY_API_KEY) {
    Write-Host "⚠️  警告: 未设置 ALCHEMY_API_KEY 环境变量" -ForegroundColor Yellow
    Write-Host "   请设置: `$env:ALCHEMY_API_KEY='your-api-key-here'" -ForegroundColor Yellow
}

# 检查是否配置了 WBTC 合约地址
$subgraphContent = Get-Content subgraph.yaml -Raw
if ($subgraphContent -match "0x\.\.\.") {
    Write-Host "⚠️  警告: subgraph.yaml 中的 WBTC 合约地址需要更新" -ForegroundColor Yellow
    Write-Host "   请编辑 subgraph.yaml 并替换合约地址" -ForegroundColor Yellow
}

Write-Host "✅ 设置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "1. 更新 subgraph.yaml 中的 WBTC 合约地址"
Write-Host "2. 运行 'npm run codegen' 生成类型定义"
Write-Host "3. 运行 'npm run build' 构建子图"
Write-Host "4. 使用 'docker-compose up -d' 启动本地 Graph Node"
Write-Host "5. 运行 'npm run deploy' 部署子图"

