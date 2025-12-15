-- 自定义数据库初始化脚本
-- 
-- 重要说明：
-- 1. 这个脚本只会在数据库首次创建时执行（数据目录为空时）
-- 2. 如果数据目录已存在，即使重启容器也不会重新执行
-- 3. 要重新执行此脚本，需要删除数据卷：
--    docker-compose down -v  # 删除所有数据卷
--    docker-compose up -d    # 重新创建并执行初始化脚本
-- 
-- 4. 如果只想重新执行 SQL 而不删除数据，可以手动执行：
--    docker exec -i allia-graph-postgres-custom-1 psql -U custom_user -d custom_db < scripts/init-custom-db.sql

-- 创建一个示例自定义表
CREATE TABLE IF NOT EXISTS custom_config (
    id SERIAL PRIMARY KEY,
    key VARCHAR(255) UNIQUE NOT NULL,
    value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_custom_config_key ON custom_config(key);

-- 插入示例数据（可选）
-- INSERT INTO custom_config (key, value) VALUES ('version', '1.0.0')
-- ON CONFLICT (key) DO NOTHING;

-- 你可以在这里添加更多自定义表
-- CREATE TABLE IF NOT EXISTS your_custom_table (
--     id SERIAL PRIMARY KEY,
--     ...
-- );

