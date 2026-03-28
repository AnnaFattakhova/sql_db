-- 02_constraints_indexes.sql
-- Предполагается, что таблицы уже созданы в 01_create_tables.sql

-- Добавление ограничений и индексов

-- ОГРАНИЧЕНИЯ

-- 1. Проверка корректности дат жизни автора:
-- дата смерти не может быть раньше даты рождения (если обе указаны)
ALTER TABLE authors
    ADD CONSTRAINT chk_authors_birth_death
    CHECK (death_date IS NULL OR birth_date IS NULL OR death_date >= birth_date);

-- 2. Проверка года основания издательства:
-- допустимы значения от 1400 года до текущего
ALTER TABLE publishers
    ADD CONSTRAINT chk_publishers_founded_year
    CHECK (founded_year IS NULL OR founded_year BETWEEN 1400 AND EXTRACT(YEAR FROM CURRENT_DATE)::INT);

-- 3. Ограничения для таблицы editions
ALTER TABLE editions
    -- Уникальность ISBN: одно издание не может иметь дубликатов
    ADD CONSTRAINT uq_editions_isbn UNIQUE (isbn),
    -- Проверка года публикации
    ADD CONSTRAINT chk_editions_publication_year
        CHECK (publication_year BETWEEN 1400 AND EXTRACT(YEAR FROM CURRENT_DATE)::INT),
    -- Проверка количества страниц: должно быть положительным числом
    ADD CONSTRAINT chk_editions_page_count
        CHECK (page_count IS NULL OR page_count > 0),
    -- Проверка тиража: должен быть положительным числом
    ADD CONSTRAINT chk_editions_circulation
        CHECK (circulation IS NULL OR circulation > 0),
    -- Проверка кода языка: длина от 2 до 5 символов
    ADD CONSTRAINT chk_editions_language_code
        CHECK (char_length(language_code) BETWEEN 2 AND 5);

-- 4. Проверка формата email читателя: допускается NULL/строка, соответствующая шаблону email
ALTER TABLE readers
    ADD CONSTRAINT chk_readers_email_format
        CHECK (email IS NULL OR email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$');

-- ИНДЕКСЫ

-- 1. Поиск произведений по названию
CREATE INDEX idx_works_title
    ON works(title);

-- 2. Поиск авторов по фамилии
CREATE INDEX idx_authors_last_name
    ON authors(last_name);

-- 3. Переход от произведения к его изданиям
CREATE INDEX idx_editions_work_id
    ON editions(work_id);

-- 4. Переход от издательства к его изданиям
CREATE INDEX idx_editions_publisher_id
    ON editions(publisher_id);

-- 5. Переход от издания к экземплярам
CREATE INDEX idx_copies_edition_id
    ON copies(edition_id);

-- 6. Поиск экземпляров по статусу
CREATE INDEX idx_copies_status
    ON copies(status);

-- 7. Поиск выдач по читателю
CREATE INDEX idx_loans_reader_id
    ON loans(reader_id);

-- 8. Поиск выдач по экземпляру
CREATE INDEX idx_loans_copy_id
    ON loans(copy_id);

-- 9. Поиск выдач по дате выдачи
CREATE INDEX idx_loans_issue_date
    ON loans(issue_date);

-- 10. Поиск выдач по статусу (чтобы найти активные/просроченные)
CREATE INDEX idx_loans_status
    ON loans(status);

-- 11. Поиск читателей по email
CREATE INDEX idx_readers_email
    ON readers(email);

-- 12. Поиск переводчиков по фамилии
CREATE INDEX idx_translators_last_name
    ON translators(last_name);


-- КОММЕНТАРИИ
-- чтобы их увидеть, можно навести курсор на поле/таблицу
-- или так:
-- SELECT obj_description('works'::regclass);

COMMENT ON TABLE authors IS 'Авторы произведений';
COMMENT ON TABLE work_types IS 'Типы произведений: роман, рассказ, статья и т.д.';
COMMENT ON TABLE works IS 'Произведения';
COMMENT ON TABLE author_work IS 'Связь many-to-many между авторами и произведениями';
COMMENT ON TABLE publishers IS 'Издательства';
COMMENT ON TABLE editions IS 'Конкретные издания произведений';
COMMENT ON TABLE translators IS 'Переводчики';
COMMENT ON TABLE edition_translator IS 'Связь many-to-many между изданиями и переводчиками';
COMMENT ON TABLE copies IS 'Физические экземпляры изданий';
COMMENT ON TABLE readers IS 'Читатели библиотеки';
COMMENT ON TABLE loans IS 'Выдачи экземпляров читателям';
COMMENT ON COLUMN copies.status IS 'Статус экземпляра: available, issued, lost, repair';
COMMENT ON COLUMN loans.status IS 'Статус выдачи: active, returned, overdue';
COMMENT ON COLUMN works.source_work_id IS 'Ссылка на исходное произведение, если текущее произведение является переработкой/адаптацией';
COMMENT ON COLUMN editions.language_code IS 'Код языка издания, например ru, en, fr';
COMMENT ON COLUMN copies.inventory_number IS 'Уникальный инвентарный номер библиотечного экземпляра';