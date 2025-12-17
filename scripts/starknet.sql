-- Starknet 数据库初始化脚本
-- 
-- 重要说明：
-- 1. 这个脚本只会在数据库首次创建时执行（数据目录为空时）
-- 2. 如果数据目录已存在，即使重启容器也不会重新执行
-- 3. 要重新执行此脚本，需要删除数据卷：
--    docker-compose down -v  # 删除所有数据卷
--    docker-compose up -d    # 重新创建并执行初始化脚本
-- 
-- 4. 如果只想重新执行 SQL 而不删除数据，可以手动执行：
--    docker exec -i allia-graph-postgres-starknet-1 psql -U starknet_user -d starknet < scripts/starknet.sql

-- ============================================================================
-- 合约管理表
-- ============================================================================

-- 合约类定义表（存储 Sierra/Casm 文件和 class_hash）
CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,                          -- 合约名称
    description TEXT,                                     -- 合约描述
    network VARCHAR(50) NOT NULL DEFAULT 'sepolia',      -- 网络（mainnet/sepolia）
    sierra_json JSONB,                                   -- Sierra 文件内容
    casm_json JSONB,                                     -- Casm 文件内容
    class_hash VARCHAR(66),                              -- 声明后的 class_hash
    compiled_class_hash VARCHAR(66),                     -- 编译后的 class_hash
    status VARCHAR(50) NOT NULL DEFAULT 'draft',         -- 状态：draft/declared/deployed
    owner_address VARCHAR(66),                           -- 创建者钱包地址
    declare_tx_hash VARCHAR(66),                         -- 声明交易哈希
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 合约实例表（存储已部署的合约实例）
CREATE TABLE IF NOT EXISTS contract_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    instance_address VARCHAR(66) NOT NULL,               -- 合约实例地址
    constructor_calldata JSONB,                          -- 构造函数参数
    deploy_tx_hash VARCHAR(66),                          -- 部署交易哈希
    deployer_address VARCHAR(66),                        -- 部署者地址
    salt VARCHAR(66),                                    -- 部署时使用的 salt
    status VARCHAR(50) NOT NULL DEFAULT 'pending',       -- 状态：pending/deployed/failed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts(status);
CREATE INDEX IF NOT EXISTS idx_contracts_network ON contracts(network);
CREATE INDEX IF NOT EXISTS idx_contracts_owner ON contracts(owner_address);
CREATE INDEX IF NOT EXISTS idx_contracts_class_hash ON contracts(class_hash);
CREATE INDEX IF NOT EXISTS idx_contract_instances_contract_id ON contract_instances(contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_instances_address ON contract_instances(instance_address);
CREATE INDEX IF NOT EXISTS idx_contract_instances_deployer ON contract_instances(deployer_address);

-- 更新时间戳触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为 contracts 表添加更新触发器
DROP TRIGGER IF EXISTS update_contracts_updated_at ON contracts;
CREATE TRIGGER update_contracts_updated_at
    BEFORE UPDATE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 为 contract_instances 表添加更新触发器
DROP TRIGGER IF EXISTS update_contract_instances_updated_at ON contract_instances;
CREATE TRIGGER update_contract_instances_updated_at
    BEFORE UPDATE ON contract_instances
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

