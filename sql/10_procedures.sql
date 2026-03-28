-- 10_procedures.sql

-- Хранимые процедуры (SQL-код, который хранится внутри базы и выполняется по вызову (CALL))
	-- issue_book — выдать книгу (оформление выдачы книги читателю)
	-- return_book — вернуть книгу (оформление возврата книги)
	-- add_edition — добавить издание


-- 1. Удаление старых процедур
DROP PROCEDURE IF EXISTS issue_book(INT, INT, DATE);
DROP PROCEDURE IF EXISTS return_book(INT);
DROP PROCEDURE IF EXISTS add_edition(INT, INT, INT, VARCHAR, VARCHAR, INT, INT, VARCHAR);

-- 2. Процедура выдачи книги
CREATE OR REPLACE PROCEDURE issue_book(
    p_copy_id INT,
    p_reader_id INT,
    p_due_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_copy_status VARCHAR(20);
    v_reader_exists INT;
BEGIN
    -- Проверка существования читателя
    SELECT COUNT(*)
    INTO v_reader_exists
    FROM readers
    WHERE reader_id = p_reader_id;

    IF v_reader_exists = 0 THEN
        RAISE EXCEPTION 'Читатель с reader_id = % не найден', p_reader_id;
    END IF;

    -- Проверка существования и статуса экземпляра
    SELECT status
    INTO v_copy_status
    FROM copies
    WHERE copy_id = p_copy_id;

    IF v_copy_status IS NULL THEN
        RAISE EXCEPTION 'Экземпляр с copy_id = % не найден', p_copy_id;
    END IF;

    IF v_copy_status <> 'available' THEN
        RAISE EXCEPTION 'Экземпляр с copy_id = % недоступен для выдачи. Текущий статус: %',
            p_copy_id, v_copy_status;
    END IF;

    IF p_due_date < CURRENT_DATE THEN
        RAISE EXCEPTION 'Дата возврата не может быть раньше текущей даты';
    END IF;

    -- Создание новой выдачи
    INSERT INTO loans (
        copy_id,
        reader_id,
        issue_date,
        due_date,
        return_date,
        status
    )
    VALUES (
        p_copy_id,
        p_reader_id,
        CURRENT_DATE,
        p_due_date,
        NULL,
        'active'
    );
END;
$$;


-- 3. Процедура возврата книги
CREATE OR REPLACE PROCEDURE return_book(
    p_loan_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_loan_exists INT;
    v_loan_status VARCHAR(20);
BEGIN
    -- Проверка существования выдачи
    SELECT COUNT(*)
    INTO v_loan_exists
    FROM loans
    WHERE loan_id = p_loan_id;

    IF v_loan_exists = 0 THEN
        RAISE EXCEPTION 'Выдача с loan_id = % не найдена', p_loan_id;
    END IF;

    -- Проверка текущего статуса выдачи
    SELECT status
    INTO v_loan_status
    FROM loans
    WHERE loan_id = p_loan_id;

    IF v_loan_status <> 'active' THEN
        RAISE EXCEPTION 'Нельзя вернуть выдачу с loan_id = %. Текущий статус: %',
            p_loan_id, v_loan_status;
    END IF;

    -- Возврат книги
    UPDATE loans
    SET status = 'returned',
        return_date = CURRENT_DATE
    WHERE loan_id = p_loan_id;
END;
$$;


-- 4. Процедура добавления нового издания
CREATE OR REPLACE PROCEDURE add_edition(
    p_work_id INT,
    p_publisher_id INT,
    p_publication_year INT,
    p_isbn VARCHAR,
    p_language_code VARCHAR,
    p_page_count INT,
    p_circulation INT,
    p_series_name VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_work_exists INT;
    v_publisher_exists INT;
    v_isbn_exists INT;
BEGIN
    -- Проверка произведения
    SELECT COUNT(*)
    INTO v_work_exists
    FROM works
    WHERE work_id = p_work_id;

    IF v_work_exists = 0 THEN
        RAISE EXCEPTION 'Произведение с work_id = % не найдено', p_work_id;
    END IF;

    -- Проверка издательства
    SELECT COUNT(*)
    INTO v_publisher_exists
    FROM publishers
    WHERE publisher_id = p_publisher_id;

    IF v_publisher_exists = 0 THEN
        RAISE EXCEPTION 'Издательство с publisher_id = % не найдено', p_publisher_id;
    END IF;

    -- Проверка ISBN
    SELECT COUNT(*)
    INTO v_isbn_exists
    FROM editions
    WHERE isbn = p_isbn;

    IF v_isbn_exists > 0 THEN
        RAISE EXCEPTION 'Издание с ISBN = % уже существует', p_isbn;
    END IF;

    -- Добавление издания
    INSERT INTO editions (
        work_id,
        publisher_id,
        publication_year,
        isbn,
        language_code,
        page_count,
        circulation,
        series_name
    )
    VALUES (
        p_work_id,
        p_publisher_id,
        p_publication_year,
        p_isbn,
        p_language_code,
        p_page_count,
        p_circulation,
        p_series_name
    );
END;
$$;