# Налаштування Supabase для збереження профілю

## 📋 Огляд проблеми

Додаток не може зберегти дані профілю (ім'я та аватар) через Supabase. Потрібно:
1. ✅ Додати детальне логування помилок (ГОТОВО в settings_page.dart)
2. ⚙️ Налаштувати RLS політики для таблиці `profile`
3. 🖼️ Налаштувати Storage бакет для аватарів
4. ✔️ Валідувати структуру бази даних

---

## 🔑 Крок 2: Налаштування RLS політик для таблиці `profile`

### Місце розташування в консолі Supabase:
**Database** → **Tables** → **profile** → **RLS Policies** (або **Authentication** → **Policies**)

### Налаштування 1: Дозволити авторизованим користувачам читати свій профіль
1. Натиснути **New Policy** → **Select for query** → **Authenticated users**
2. Назва: `Allow users to read their own profile`
3. Залишити шаблон за замовчуванням або вставити SQL:
```sql
auth.uid() = id
```
4. Натиснути **Review** → **Save Policy**

### Налаштування 2: Дозволити авторизованим користувачам оновлювати свій профіль
1. Натиснути **New Policy** → **Update** → **Authenticated users**
2. Назва: `Allow users to update their own profile`
3. У полі **Using expression**:
```sql
auth.uid() = id
```
4. У полі **With check** (якщо з'явиться):
```sql
auth.uid() = id
```
5. Натиснути **Review** → **Save Policy**

---

## 🖼️ Крок 3: Налаштування Storage для аватарів

### ⚠️ ШВИДКЕ ВИРІШЕННЯ (якщо бакета немає):

**Метод 1: Через Supabase консоль (З UI)**

1. Відкрити https://app.supabase.com/ → обрати свій проект
2. У лівому меню натиснути **Storage** 
3. Натиснути кнопку **Create a new bucket** (червона/рожева кнопка)
4. В діалоговому вікні вписати:
   - **Bucket name**: `avatars`
   - **Public bucket**: ✓ **ОБОВ'ЯЗКОВО** галочку встановити!
5. Натиснути **Create bucket**
6. Перейти в щойно створений бакет → вкладка **Policies** → переконатися що:
   - ✅ `authenticated` може INSERT (завантажувати)
   - ✅ `authenticated` може UPDATE (оновлювати)
   - ✅ `public` або `authenticated` можуть SELECT (читати)

**Метод 2: Через SQL командний рядок (Якщо попередній не спрацював)**

1. Перейти в **SQL Editor** → натиснути **New Query**
2. Скопіювати та виконати цей скрипт:
```sql
-- Вибрати правильну схему
SELECT create_bucket('avatars');

-- Встановити бакет як Public
UPDATE storage.buckets 
SET public = true 
WHERE name = 'avatars';

-- Додати RLS політики для аватарів
CREATE POLICY "Allow authenticated users to upload avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Allow authenticated users to update their avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1])
WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Allow public to view avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');
```
3. Натиснути **Run** ⏵️
4. Якщо побачиш помилку про те, що бакет вже існує — добре, це означає він вже є в системі

### Як налаштувати RLS політики для бакета вручну:

1. Обрати бакет `avatars`
2. Перейти в **Policies**
3. Переконатися, що для ролі `authenticated` дозволені операції:
   - **Insert** ✓ (завантаження нових файлів)
   - **Update** ✓ (заміна існуючих файлів)
   - **Select** ✓ (читання файлів)

4. Якщо яких-то опорацій не має — натиснути **New Policy**, вибрати дозвіл, установити тип операції та роль `authenticated`

### Налаштування шляхом SQL (альтернатива):

Якщо потрібно змінити політики через SQL:
```sql
-- Insert policy for avatars
CREATE POLICY "Allow authenticated users to upload avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

-- Update policy for avatars
CREATE POLICY "Allow authenticated users to update avatars"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');

-- Select policy for avatars
CREATE POLICY "Allow public to view avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

---

## ✔️ Крок 4: Валідація структури бази даних

### Перевірити структуру таблиці `profile`:

1. Перейти в **Database** → **Tables** → **profile**
2. Переконатися, що таблиця містить колонки:
   - `id` (PRIMARY KEY, uuid) — ID користувача з auth.users
   - `username` (text) — ім'я користувача
   - `avatar_url` (text, nullable) — посилання на аватар у Storage

3. Якщо колонки відсутні — додати через **Add Column**:
   - **Column name**: `avatar_url`
   - **Type**: `text`
   - **Nullable**: ✓ Yes

### SQL для створення/зміни таблиці (якщо потрібно):

```sql
-- Створити таблицю profile (якщо її немає)
CREATE TABLE public.profile (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text,
  avatar_url text,
  title text DEFAULT 'User',
  level integer DEFAULT 1,
  bio_sync boolean DEFAULT false,
  dark_immersion boolean DEFAULT false,
  zen_notifications boolean DEFAULT false,
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

-- Додати колонку avatar_url (якщо таблиця вже існує)
ALTER TABLE public.profile
ADD COLUMN avatar_url text;

-- Включити RLS на таблиці profile
ALTER TABLE public.profile ENABLE ROW LEVEL SECURITY;

-- Видалити старі політики (якщо є)
DROP POLICY IF EXISTS "Allow users to read their own profile" ON public.profile;
DROP POLICY IF EXISTS "Allow users to update their own profile" ON public.profile;

-- Створити нові політики
CREATE POLICY "Allow users to read their own profile" ON public.profile
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Allow users to update their own profile" ON public.profile
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

---

## 🧪 Тестування

Після налаштування:

1. **Запустити додаток**
2. **Авторизуватися** (через email або анонімно)
3. Натиснути на іконку редагування профілю
4. Змінити ім'я та натиснути **Зберегти зміни**
5. **Очікуваний результат**: Зелений SnackBar з текстом `"Профіль успішно збережено в хмару!"`
6. Завантажити нове фото з галереї
7. Натиснути **Зберегти зміни**
8. **Очікуваний результат**: Фото з'являється на аватарі, а URL оновлюється в базі даних

### Якщо виникає помилка:
- На екрані з'явиться червоний SnackBar з **деталями помилки** (замість «Перевірте мережу»)
- Дотримуйтесь інструкцій на основі тексту помилки

---

## 📝 Чек-лист налаштування

- [ ] Таблиця `profile` має колонки: `id`, `username`, `avatar_url`
- [ ] RLS увімкнено на таблиці `profile`
- [ ] Політика SELECT для `authenticated` користувачів дозволяє читати свої рядки
- [ ] Політика UPDATE для `authenticated` користувачів дозволяє оновлювати свої рядки
- [ ] Бакет `avatars` створено в Storage
- [ ] Бакет `avatars` позначено як **Public**
- [ ] RLS політики для бакета дозволяють: INSERT, UPDATE, SELECT для `authenticated`
- [ ] Додаток тестовано — ім'я та аватар успішно зберігаються

---

## 🔗 Корисні посилання

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
