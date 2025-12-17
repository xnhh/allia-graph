# Starknet 数据库使用说明

## 概述

项目现在包含两个独立的 PostgreSQL 数据库：

1. **postgres-graph** (端口 5432) - Graph Node 专用数据库
2. **postgres-starknet** (端口 5433) - Starknet 合约管理数据库

## 连接信息

### Starknet 数据库 (postgres-starknet)

- **主机**: `localhost` (或 `postgres-starknet` 在 Docker 网络内)
- **端口**: `5433`
- **数据库名**: `starknet`
- **用户名**: `starknet_user`
- **密码**: `starknet_password`

### Graph Node 数据库 (postgres-graph)

- **主机**: `localhost` (或 `postgres-graph` 在 Docker 网络内)
- **端口**: `5432`
- **数据库名**: `graph-node`
- **用户名**: `graph-node`
- **密码**: `let-me-in`

## 连接方式

### 使用 psql 命令行工具

```bash
# 连接 Starknet 数据库
psql -h localhost -p 5433 -U starknet_user -d starknet

# 连接 Graph Node 数据库
psql -h localhost -p 5432 -U graph-node -d graph-node
```

### 使用连接字符串

```
# Starknet 数据库
postgresql://starknet_user:starknet_password@localhost:5433/starknet

# Graph Node 数据库
postgresql://graph-node:let-me-in@localhost:5432/graph-node
```

### 使用 Docker 连接

```bash
# 连接 Starknet 数据库
docker exec -it allia-graph-postgres-starknet-1 psql -U starknet_user -d starknet

# 连接 Graph Node 数据库
docker exec -it allia-graph-postgres-graph-1 psql -U graph-node -d graph-node
```

## 初始化自定义表

### 自动初始化

数据库**首次启动时**会自动执行 `scripts/init-custom-db.sql` 脚本，创建示例表。

**重要**：初始化脚本只会在数据库首次创建时执行一次。如果数据目录已存在，即使重启容器也不会重新执行。

### 重新执行初始化脚本

如果需要重新执行初始化脚本，有以下几种方式：

#### 方式 1: 删除数据卷重新创建（会丢失所有数据）

```bash
# 停止并删除所有数据卷
docker-compose down -v

# 重新启动（会执行初始化脚本）
docker-compose up -d
```

#### 方式 2: 手动执行 SQL 脚本（保留现有数据）

```bash
# Linux/Mac
./scripts/apply-init-sql.sh

# Windows PowerShell
.\scripts\apply-init-sql.ps1

# 或直接使用 docker exec
docker exec -i allia-graph-postgres-custom-1 psql -U custom_user -d custom_db < scripts/init-custom-db.sql
```

#### 方式 3: 直接连接数据库执行

```bash
docker exec -it allia-graph-postgres-custom-1 psql -U custom_user -d custom_db
```

然后在 psql 中执行 SQL 命令。

### 手动创建表

你可以通过以下方式添加自定义表：

1. **直接连接数据库执行 SQL**:
```sql
CREATE TABLE your_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

2. **修改初始化脚本** (`scripts/init-custom-db.sql`):
   - 添加你的表定义
   - 删除数据卷重新启动: `docker-compose down -v && docker-compose up -d`

3. **使用迁移工具** (如 Flyway, Liquibase):
   - 将迁移脚本放在 `scripts/migrations/` 目录
   - 在应用启动时执行

## 在应用中使用

### Node.js 示例

```javascript
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5433,
  database: 'starknet',
  user: 'starknet_user',
  password: 'starknet_password',
});

// 查询示例
async function getContracts() {
  const result = await pool.query(
    'SELECT * FROM contracts ORDER BY created_at DESC'
  );
  return result.rows;
}
```

### Python 示例

```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5433,
    database="starknet",
    user="starknet_user",
    password="starknet_password"
)

cursor = conn.cursor()
cursor.execute("SELECT * FROM contracts")
rows = cursor.fetchall()
```

## 注意事项

1. **数据持久化**: 数据存储在 `./data/postgres-starknet/` 目录中
2. **备份**: 定期备份 `./data/postgres-starknet/` 目录
3. **端口冲突**: 如果 5433 端口被占用，可以在 `docker-compose.yml` 中修改
4. **安全性**: 生产环境请修改默认密码
5. **独立运行**: 可以只启动 Starknet 数据库: `docker-compose up -d postgres-starknet`

## 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 只启动 Starknet 数据库
docker-compose up -d postgres-starknet

# 查看日志
docker-compose logs -f postgres-starknet
```

