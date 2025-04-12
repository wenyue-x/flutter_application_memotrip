-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

------------------------------------------------
-- 第一部分：创建存储过程
------------------------------------------------

-- 创建支出按类别统计的存储过程
CREATE OR REPLACE FUNCTION get_expense_by_category(trip_id_param UUID)
RETURNS TABLE (
  category_id UUID,
  category_name TEXT,
  total_amount DECIMAL(10, 2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.category_id,
    ec.name AS category_name,
    SUM(e.amount) AS total_amount
  FROM 
    expenses e
    JOIN expense_categories ec ON e.category_id = ec.id
  WHERE 
    e.trip_id = trip_id_param
  GROUP BY 
    e.category_id, ec.name
  ORDER BY 
    total_amount DESC;
END;
$$ LANGUAGE plpgsql;

-- 创建按日期汇总支出的存储过程
CREATE OR REPLACE FUNCTION get_expense_by_date(trip_id_param UUID)
RETURNS TABLE (
  expense_date DATE,
  total_amount DECIMAL(10, 2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    DATE(e.date) AS expense_date,
    SUM(e.amount) AS total_amount
  FROM 
    expenses e
  WHERE 
    e.trip_id = trip_id_param
  GROUP BY 
    DATE(e.date)
  ORDER BY 
    expense_date;
END;
$$ LANGUAGE plpgsql;

-- 创建用于获取旅行预算信息的存储过程
CREATE OR REPLACE FUNCTION get_trip_budget(trip_id_param UUID)
RETURNS TABLE (
  budget DECIMAL(10, 2),
  total_expense DECIMAL(10, 2),
  remaining DECIMAL(10, 2)
) AS $$
DECLARE
  trip_budget DECIMAL(10, 2);
  trip_expenses DECIMAL(10, 2);
BEGIN
  -- 获取旅行预算
  SELECT COALESCE(t.budget, 0) INTO trip_budget
  FROM trips t
  WHERE t.id = trip_id_param;

  -- 计算总支出
  SELECT COALESCE(SUM(e.amount), 0) INTO trip_expenses
  FROM expenses e
  WHERE e.trip_id = trip_id_param;

  -- 返回结果
  RETURN QUERY
  SELECT 
    trip_budget AS budget,
    trip_expenses AS total_expense,
    (trip_budget - trip_expenses) AS remaining;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------
-- 第二部分：存储桶设置 (仅供参考)
------------------------------------------------

-- 注意：以下存储桶和访问策略内容仅供参考
-- 请在 Supabase 控制台中执行操作：
-- 
-- 1. 创建存储桶：
--    在 Storage 页面点击 "New Bucket" 按钮创建以下三个存储桶：
--    - trip_images：用于存储旅行图片
--    - journal_images：用于存储日志图片 
--    - profile_images：用于存储用户头像
--
-- 2. 配置访问策略：
--    在每个存储桶的 "Policies" 标签页设置：
--    a) 配置读取权限：
--       Policy name: "Allow public read access"
--       Allowed operations: SELECT
--       Definition: true (允许所有人读取)
--
--    b) 配置上传权限：
--       Policy name: "Allow authenticated users to upload"
--       Allowed operations: INSERT
--       Definition: auth.role() = 'authenticated'
--
--    c) 配置删除权限：
--       Policy name: "Allow users to delete own files"
--       Allowed operations: DELETE
--       Definition: auth.uid() = owner
--
-- 重要提示：不要尝试直接在 SQL 编辑器中执行存储桶相关策略命令，
-- 这些操作必须通过 Supabase 控制台完成
