-- 11_procedure_calls.sql

-- Демонстрация работы procedure
	-- вызовы через DO
	-- проверки ДО/ПОСЛЕ

-- ПРОВЕРКА ПРОЦЕДУРЫ issue_book

-- 1.1. Состояние экземпляра ДО выдачи
SELECT
    copy_id,
    inventory_number,
    status
FROM copies
WHERE inventory_number = 'INV-005';


-- 1.2. Выдача книги через процедуру
DO $$
DECLARE
    v_copy_id INT;
    v_reader_id INT;
BEGIN
    SELECT copy_id
    INTO v_copy_id
    FROM copies
    WHERE inventory_number = 'INV-005';

    SELECT reader_id
    INTO v_reader_id
    FROM readers
    WHERE email = 'sidorov@example.com';

    IF v_copy_id IS NULL THEN
        RAISE EXCEPTION 'Не найден экземпляр INV-002';
    END IF;

    IF v_reader_id IS NULL THEN
        RAISE EXCEPTION 'Не найден читатель ivanov@example.com';
    END IF;

    CALL issue_book(v_copy_id, v_reader_id, CURRENT_DATE + 14);
END;
$$;


-- 1.3. Состояние экземпляра ПОСЛЕ выдачи
SELECT
    copy_id,
    inventory_number,
    status
FROM copies
WHERE inventory_number = 'INV-005';


-- 1.4. Последняя выдача для этого экземпляра
SELECT
    l.loan_id,
    l.copy_id,
    l.reader_id,
    l.issue_date,
    l.due_date,
    l.return_date,
    l.status
FROM loans l
JOIN copies c
    ON l.copy_id = c.copy_id
WHERE c.inventory_number = 'INV-002'
ORDER BY l.loan_id DESC
LIMIT 1;


-- 2. ПРОВЕРКА ПРОЦЕДУРЫ return_book

-- 2.1. Активные выдачи ДО возврата
SELECT
    loan_id,
    copy_id,
    reader_id,
    issue_date,
    due_date,
    return_date,
    status
FROM loans
WHERE status = 'active'
ORDER BY loan_id DESC;

-- 2.2. Возврат последней активной выдачи через процедуру
DO $$
DECLARE
    v_loan_id INT;
BEGIN
    SELECT loan_id
    INTO v_loan_id
    FROM loans
    WHERE status = 'active'
    ORDER BY loan_id DESC
    LIMIT 1;

    IF v_loan_id IS NULL THEN
        RAISE NOTICE 'Нет активных выдач для возврата';
    ELSE
        CALL return_book(v_loan_id);
    END IF;
END;
$$;

-- 2.3. Таблица выдачей ПОСЛЕ возврата
SELECT
    loan_id,
    copy_id,
    reader_id,
    issue_date,
    due_date,
    return_date,
    status
FROM loans
ORDER BY loan_id DESC;

-- 2.4. Проверка статуса экземпляра после возврата
SELECT
    copy_id,
    inventory_number,
    status
FROM copies
WHERE inventory_number = 'INV-005';


-- 3. ПРОВЕРКА ПРОЦЕДУРЫ add_edition

-- 3.1. Проверка, что такого ISBN ещё нет
SELECT
    edition_id,
    isbn,
    publication_year
FROM editions
WHERE isbn = '978-0-141-39000-9';

-- 3.2. Добавление нового издания через процедуру
DO $$
DECLARE
    v_work_id INT;
    v_publisher_id INT;
BEGIN
    SELECT work_id
    INTO v_work_id
    FROM works
    WHERE title = 'Гамлет';

    SELECT publisher_id
    INTO v_publisher_id
    FROM publishers
    WHERE publisher_name = 'Penguin Books';

    IF v_work_id IS NULL THEN
        RAISE EXCEPTION 'Не найдено произведение "Гамлет"';
    END IF;

    IF v_publisher_id IS NULL THEN
        RAISE EXCEPTION 'Не найдено издательство "Penguin Books"';
    END IF;

    CALL add_edition(
        v_work_id,
        v_publisher_id,
        2024,
        '978-0-141-39000-9',
        'en',
        350,
        2000,
        'Modern Classics'
    );
END;
$$;

-- 3.3. Проверка, что издание добавилось
SELECT
    e.edition_id,
    w.title,
    p.publisher_name,
    e.publication_year,
    e.isbn,
    e.language_code,
    e.page_count,
    e.circulation,
    e.series_name
FROM editions e
JOIN works w
    ON e.work_id = w.work_id
JOIN publishers p
    ON e.publisher_id = p.publisher_id
WHERE e.isbn = '978-0-141-39000-9';

SELECT current_database(), current_user, current_schema();
SELECT current_database(), current_user, current_schema();
SELECT COUNT(*) FROM public.works;