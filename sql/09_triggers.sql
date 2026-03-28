-- 09_triggers.sql

-- Триггеры
-- проверка доступности книги: issued/available/return_date

-- 1. Очистка старых триггеров и функций
DROP TRIGGER IF EXISTS trg_check_copy_before_loan ON loans;
DROP TRIGGER IF EXISTS trg_set_copy_issued_after_insert_loan ON loans;
DROP TRIGGER IF EXISTS trg_set_return_date_before_update_loan ON loans;
DROP TRIGGER IF EXISTS trg_set_copy_available_after_update_loan ON loans;
DROP FUNCTION IF EXISTS check_copy_available_before_loan();
DROP FUNCTION IF EXISTS set_copy_issued_after_insert_loan();
DROP FUNCTION IF EXISTS set_return_date_before_update_loan();
DROP FUNCTION IF EXISTS set_copy_available_after_update_loan();

-- 2. Проверка перед созданием выдачи
-- Создаём или заменяем функцию-триггер
CREATE OR REPLACE FUNCTION check_copy_available_before_loan()
RETURNS TRIGGER
AS $$
DECLARE
    current_status VARCHAR(20); -- переменная для хранения текущего статуса экземпляра
BEGIN
    -- Получаем статус экземпляра книги по его copy_id
    SELECT status
    INTO current_status
    FROM copies
    WHERE copy_id = NEW.copy_id;
    -- Если экземпляр не найден (status = NULL), ошибка
    IF current_status IS NULL THEN
        RAISE EXCEPTION 'Экземпляр с copy_id = % не найден', NEW.copy_id;
    END IF;
    -- Если экземпляр найден, но его статус не "available", запрещаем выдачу
    IF current_status <> 'available' THEN
        RAISE EXCEPTION 'Экземпляр с copy_id = % недоступен для выдачи. Текущий статус: %',
            NEW.copy_id, current_status;
    END IF;
    -- Если все проверки пройдены, разрешаем вставку строки в таблицу loans
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаём триггер, который будет вызывать функцию перед вставкой в loans
CREATE TRIGGER trg_check_copy_before_loan
-- Триггер срабатывает ПЕРЕД добавлением новой записи
BEFORE INSERT ON loans
FOR EACH ROW
WHEN (NEW.status = 'active') -- триггер выполняется только если статус новой выдачи = 'active'
EXECUTE FUNCTION check_copy_available_before_loan();

-- 3. После создания активной выдачи
CREATE OR REPLACE FUNCTION set_copy_issued_after_insert_loan()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.status = 'active' THEN -- проверяем, имеет ли новая выдача статус 'active'
        -- Обновляем статус соответствующего экземпляра книги (= делаем его "выданным")
        UPDATE copies
        SET status = 'issued'
        WHERE copy_id = NEW.copy_id;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_copy_issued_after_insert_loan
AFTER INSERT ON loans -- триггер срабатывает после вставки записи в таблицу loans
FOR EACH ROW
EXECUTE FUNCTION set_copy_issued_after_insert_loan();

-- 4. Перед обновлением выдачи
CREATE OR REPLACE FUNCTION set_return_date_before_update_loan()
RETURNS TRIGGER
AS $$
BEGIN
    -- Если статус выдачи меняется на 'returned' и дата возврата ещё не указана
    IF NEW.status = 'returned' AND NEW.return_date IS NULL THEN
        NEW.return_date := CURRENT_DATE; -- автоматически проставляем текущую дату как дату возврата
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_return_date_before_update_loan
BEFORE UPDATE ON loans -- срабатывает ПЕРЕД обновлением записи в таблице loans
FOR EACH ROW
EXECUTE FUNCTION set_return_date_before_update_loan();

-- 5. После обновления выдачи
-- 5. После обновления выдачи
CREATE OR REPLACE FUNCTION set_copy_available_after_update_loan()
RETURNS TRIGGER
AS $$
BEGIN
    -- Проверяем: если статус выдачи = 'returned' и дата возврата уже заполнена
    IF NEW.status = 'returned' AND NEW.return_date IS NOT NULL THEN
        UPDATE copies -- меняем статус экземпляра обратно на "available"
        SET status = 'available'
        WHERE copy_id = NEW.copy_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_copy_available_after_update_loan
AFTER UPDATE ON loans -- срабатывает ПОСЛЕ обновления записи в таблице loans
FOR EACH ROW
EXECUTE FUNCTION set_copy_available_after_update_loan();

-- ПРОВЕРКА 1

-- Смотрим доступный экземпляр
SELECT copy_id, inventory_number, status FROM copies WHERE status = 'available';

-- Выдаем
INSERT INTO loans (copy_id, reader_id, issue_date, due_date, return_date, status)
VALUES (
    (SELECT copy_id FROM copies WHERE inventory_number = 'INV-002'),
    (SELECT reader_id FROM readers WHERE email = 'ivanov@example.com'),
    CURRENT_DATE,
    CURRENT_DATE + 14,
    NULL,
    'active'
);

-- Проверяем статус - issued
SELECT copy_id, inventory_number, status FROM copies WHERE inventory_number = 'INV-002';

-- ПРОВЕРКА 2 (возвращаем книгу)

-- Находим активные - те, которые выданы
SELECT * FROM loans WHERE status = 'active';

-- Делаем возврат
UPDATE loans SET status = 'returned' WHERE loan_id = (SELECT MAX(loan_id) FROM loans);

-- Проверяем дату возврата
SELECT loan_id, status, return_date FROM loans WHERE loan_id = (SELECT MAX(loan_id) FROM loans);

-- Проверяем статус - available
SELECT copy_id, inventory_number, status FROM copies WHERE inventory_number = 'INV-002';

-- Если выданную книгу попробовать еще раз выдать - возникает ошибка, значит, все работает верно