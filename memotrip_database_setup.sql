-- 确保UUID扩展被启用
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 创建用户表
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT NOT NULL UNIQUE,
  phone TEXT UNIQUE,  -- 手机号字段
  password TEXT NOT NULL,  -- 密码字段
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  username TEXT,
  avatar_url TEXT
);

-- 添加行级安全策略
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 创建旅行表
CREATE TABLE public.trips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  destination TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  image_url TEXT,
  budget DECIMAL(10, 2),
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 添加行级安全策略
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

-- 创建行程项表
CREATE TABLE public.schedule_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  location TEXT NOT NULL,
  image_url TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 添加行级安全策略
ALTER TABLE public.schedule_items ENABLE ROW LEVEL SECURITY;

-- 创建支出类别表
CREATE TABLE public.expense_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  icon_name TEXT NOT NULL,
  color_code TEXT NOT NULL
);

-- 预填充支出类别
INSERT INTO public.expense_categories (name, icon_name, color_code) VALUES
('餐饮', 'restaurant', '#3B82F6'),
('住宿', 'hotel', '#A855F7'),
('交通', 'directions_bus', '#22C55E'),
('购物', 'shopping_bag', '#F97316'),
('门票', 'confirmation_number', '#EF4444'),
('其他', 'more_horiz', '#6B7280');

-- 添加行级安全策略
ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

-- 创建支出表
CREATE TABLE public.expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  category_id UUID REFERENCES public.expense_categories(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 添加行级安全策略
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- 创建日志条目表
CREATE TABLE public.journal_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  time TIME NOT NULL,
  content TEXT NOT NULL,
  location TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 添加行级安全策略
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

-- 创建日志图片表
CREATE TABLE public.journal_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  journal_id UUID REFERENCES public.journal_entries(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 添加行级安全策略
ALTER TABLE public.journal_images ENABLE ROW LEVEL SECURITY;

-- 创建行级安全策略 - 用户只能查看和修改自己的数据
CREATE POLICY "用户可以查看自己的数据" ON public.users
  FOR ALL USING (auth.uid() = id);

CREATE POLICY "用户可以查看自己的旅行" ON public.trips
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "用户可以查看自己旅行的行程项" ON public.schedule_items
  FOR ALL USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "用户可以查看支出类别" ON public.expense_categories
  FOR SELECT USING (true);

CREATE POLICY "用户可以查看自己旅行的支出" ON public.expenses
  FOR ALL USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "用户可以查看自己旅行的日志" ON public.journal_entries
  FOR ALL USING (
    trip_id IN (
      SELECT id FROM public.trips WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "用户可以查看自己日志的图片" ON public.journal_images
  FOR ALL USING (
    journal_id IN (
      SELECT id FROM public.journal_entries WHERE trip_id IN (
        SELECT id FROM public.trips WHERE user_id = auth.uid()
      )
    )
  );
