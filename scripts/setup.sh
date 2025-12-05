#!/bin/bash

# 设置脚本
# 用于初始化 The Graph 子图项目

echo "🚀 初始化 Allia Graph 子图项目..."

# 检查 Node.js 是否安装
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到 Node.js，请先安装 Node.js"
    exit 1
fi

# 检查 Docker 是否安装（可选）
if ! command -v docker &> /dev/null; then
    echo "⚠️  警告: 未找到 Docker，将无法使用 Docker Compose 启动本地 Graph Node"
fi

# 安装依赖
echo "📦 安装依赖..."
npm install

# 检查是否配置了 API Key
if [ -z "$ALCHEMY_API_KEY" ]; then
    echo "⚠️  警告: 未设置 ALCHEMY_API_KEY 环境变量"
    echo "   请设置: export ALCHEMY_API_KEY=your-api-key-here"
fi

# 检查是否配置了 WBTC 合约地址
if grep -q "0x\.\.\." subgraph.yaml; then
    echo "⚠️  警告: subgraph.yaml 中的 WBTC 合约地址需要更新"
    echo "   请编辑 subgraph.yaml 并替换合约地址"
fi

echo "✅ 设置完成！"
echo ""
echo "下一步："
echo "1. 更新 subgraph.yaml 中的 WBTC 合约地址"
echo "2. 运行 'npm run codegen' 生成类型定义"
echo "3. 运行 'npm run build' 构建子图"
echo "4. 使用 'docker-compose up -d' 启动本地 Graph Node"
echo "5. 运行 'npm run deploy' 部署子图"

