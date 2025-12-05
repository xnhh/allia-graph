# Allia Graph - Starknet WBTC Balance Subgraph

这是一个基于 The Graph 的子图服务，用于查询 Starknet Sepolia 网络上账户的 WBTC 余额。

## 功能特性

- 📊 跟踪账户的 WBTC 余额
- 🔄 监听 WBTC Transfer 事件
- 📈 记录所有转账历史
- 🔍 提供 GraphQL API 查询接口

## 项目结构

```
allia-graph/
├── abis/                 # 合约 ABI 文件
│   └── WBTC.json
├── src/                  # 映射文件
│   └── mapping.ts
├── schema.graphql        # GraphQL schema 定义
├── subgraph.yaml         # 子图清单文件
├── package.json
├── tsconfig.json
└── README.md
```

## 安装依赖

```bash
npm install
```

## 使用 Docker Compose 运行本地 Graph Node

项目包含 `docker-compose.yml` 文件，可以快速启动本地 Graph Node 环境：

```bash
# 启动所有服务（Graph Node, IPFS, PostgreSQL）
docker-compose up -d

# 查看日志
docker-compose logs -f graph-node

# 停止服务
docker-compose down
```

**重要**: 在启动前，需要设置环境变量 `ALCHEMY_API_KEY`：

```bash
# Windows PowerShell
$env:ALCHEMY_API_KEY="your-api-key-here"
docker-compose up -d

# Linux/Mac
export ALCHEMY_API_KEY="your-api-key-here"
docker-compose up -d
```

或者创建 `.env` 文件（参考 `.env.example`）：
```
ALCHEMY_API_KEY=your-api-key-here
```

## 配置说明

### 1. 更新 subgraph.yaml

在 `subgraph.yaml` 中需要配置以下信息：

- **WBTC 合约地址**: 将 `address: "0x..."` 替换为 Starknet Sepolia 上实际的 WBTC 合约地址
- **开始区块**: 设置 `startBlock` 为开始监听的区块号
- **API Key**: 确保你的 Alchemy API Key 已配置

### 2. 配置 Alchemy RPC

子图将通过以下 URL 连接到 Starknet Sepolia：
```
https://starknet-sepolia.g.alchemy.com/v2/<api-key>
```

确保将 `<api-key>` 替换为你的实际 API Key。

**获取 Alchemy API Key**:
1. 访问 [Alchemy](https://www.alchemy.com/)
2. 创建账户并登录
3. 创建新的 Starknet Sepolia 应用
4. 复制 API Key

### 3. 更新 ABI 文件

确保 `abis/WBTC.json` 包含正确的 WBTC 合约 ABI。对于 Starknet，ABI 格式可能与以太坊不同：
- Starknet 使用 `felt252` 类型而不是 `address`
- 事件签名可能需要调整

如果使用 Cairo 合约，可能需要使用 Starknet 特定的 ABI 格式。

## 开发流程

### 1. 生成代码

```bash
npm run codegen
```

这将根据 `schema.graphql` 和 `subgraph.yaml` 生成 TypeScript 类型定义。

### 2. 构建子图

```bash
npm run build
```

### 3. 部署到本地 Graph Node

首先确保本地运行了 Graph Node（使用 Docker Compose 或手动启动）：

```bash
# 创建本地子图
npm run create-local

# 部署子图
npm run deploy
```

部署成功后，GraphQL API 将在以下地址可用：
- HTTP: http://localhost:8000/subgraphs/name/allia-graph
- WebSocket: ws://localhost:8001/subgraphs/name/allia-graph

### 4. 部署到 The Graph 托管服务

如果你要部署到 The Graph 的托管服务：

```bash
graph deploy --studio <subgraph-name>
```

## GraphQL 查询示例

部署后，你可以通过 GraphQL API 查询数据：

### 查询账户的 WBTC 余额

```graphql
query GetAccountBalance($accountId: ID!) {
  account(id: $accountId) {
    id
    address
    wbtcBalance
    lastUpdated
  }
}
```

变量：
```json
{
  "accountId": "0x1234..."
}
```

### 查询所有账户

```graphql
query GetAllAccounts {
  accounts {
    id
    address
    wbtcBalance
    lastUpdated
  }
}
```

### 查询转账记录

```graphql
query GetTransfers {
  transfers(orderBy: timestamp, orderDirection: desc, first: 10) {
    id
    from {
      address
    }
    to {
      address
    }
    amount
    timestamp
    blockNumber
    transactionHash
  }
}
```

### 查询特定账户的所有转账

```graphql
query GetAccountTransfers($accountId: ID!) {
  transfers(where: { from: $accountId }) {
    id
    to {
      address
    }
    amount
    timestamp
  }
}
```

## 注意事项

1. **Starknet 兼容性**: 请注意 The Graph 对 Starknet 的支持可能有限。如果遇到兼容性问题，可能需要：
   - 使用 Starknet 特定的 ABI 格式
   - 调整事件处理逻辑以适应 Cairo 合约
   - 使用支持 Starknet 的 Graph Node 版本
   - 确保 Graph Node 版本支持 Starknet（检查 `docker-compose.yml` 中的镜像版本）

2. **WBTC 合约地址**: 需要确认 Starknet Sepolia 上 WBTC 的实际合约地址和 ABI
   - 查找 Starknet Sepolia 上的 WBTC 合约地址
   - 更新 `subgraph.yaml` 中的 `address` 字段
   - 更新 `startBlock` 为合约部署的区块号

3. **精度处理**: WBTC 通常使用 8 位小数，查询时需要注意单位转换
   - WBTC 余额以最小单位存储（类似 satoshi）
   - 显示时需要除以 10^8

4. **初始余额**: 如果账户在子图开始监听之前就有余额，需要手动处理或从合约直接查询初始余额

5. **类型错误**: 如果看到 TypeScript 类型错误，先运行 `npm run codegen` 生成类型定义

6. **网络配置**: 确保 `subgraph.yaml` 中的 `network` 字段设置为 `sepolia`（Starknet Sepolia）

## 开发工具

- [The Graph Documentation](https://thegraph.com/docs/)
- [Graph CLI](https://github.com/graphprotocol/graph-cli)
- [AssemblyScript](https://www.assemblyscript.org/)

## 许可证

MIT

