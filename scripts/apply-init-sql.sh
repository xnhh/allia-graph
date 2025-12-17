#!/bin/bash
# 手动执行初始化 SQL 脚本
# 这个脚本可以在数据库已存在的情况下重新执行初始化 SQL

echo "正在执行初始化 SQL 脚本..."

# 检查容器是否运行
if ! docker ps | grep -q "allia-graph-postgres-starknet"; then
    echo "错误: postgres-starknet 容器未运行"
    echo "请先运行: docker-compose up -d postgres-starknet"
    exit 1
fi

# 执行 SQL 脚本
docker exec -i allia-graph-postgres-starknet-1 psql -U starknet_user -d starknet < "$(dirname "$0")/starknet.sql"

if [ $? -eq 0 ]; then
    echo "✅ SQL 脚本执行成功"
else
    echo "❌ SQL 脚本执行失败"
    exit 1
fi

