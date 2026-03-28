-- 04_crud_examples.sql

-- Рекомендуется запускать после:
-- 01_create_tables.sql
-- 02_constraints_indexes.sql
-- 03_insert_demo_data_extended.sql

-- В этом файле используется отдельный CRUD-сценарий (для сreate), чтобы он не пересекался с основной демонстрационной базой.
	-- CRUD-операции
	-- CREATE (INSERT)
	-- READ (SELECT)
	-- UPDATE
	-- DELETE


-- C = CREATE

-- 1. Новый автор
INSERT INTO authors (
    last_name,
    first_name,
    middle_name,
    birth_date,
    death_date,
    country,
    notes
)
SELECT
    'Чехов', 'Антон', 'Павлович', '1860-01-29', '1904-07-15', 'Россия', 'Русский писатель, драматург'
WHERE NOT EXISTS (
    SELECT 1
    FROM authors
    WHERE last_name = 'Чехов'
      AND first_name = 'Антон'
      AND middle_name = 'Павлович'
);


-- 2. Новое произведение
INSERT INTO works (
    title,
    type_id,
    writing_start_date,
    writing_end_date,
    publication_date,
    source_work_id,
    description
)
SELECT
    'Вишнёвый сад',
    (SELECT type_id FROM work_types WHERE type_name = 'пьеса'),
    '1901-01-01',
    '1903-01-01',
    '1904-01-17',
    NULL,
    'Пьеса Антона Павловича Чехова'
WHERE NOT EXISTS (
    SELECT 1
    FROM works
    WHERE title = 'Вишнёвый сад'
);


-- 3. Связь автора и произведения
INSERT INTO author_work (
    author_id,
    work_id,
    role
)
SELECT
    a.author_id,
    w.work_id,
    'автор'
FROM authors a
CROSS JOIN works w
WHERE a.last_name = 'Чехов'
  AND a.first_name = 'Антон'
  AND a.middle_name = 'Павлович'
  AND w.title = 'Вишнёвый сад'
  AND NOT EXISTS (
      SELECT 1
      FROM author_work aw
      WHERE aw.author_id = a.author_id
        AND aw.work_id = w.work_id
        AND aw.role = 'автор'
  );


-- 4. Новое издательство
INSERT INTO publishers (
    publisher_name,
    city,
    country,
    founded_year
)
SELECT
    'МИФ', 'Москва', 'Россия', 2005
WHERE NOT EXISTS (
    SELECT 1
    FROM publishers
    WHERE publisher_name = 'МИФ'
);


-- 5. Новое издание
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
SELECT
    (SELECT work_id FROM works WHERE title = 'Вишнёвый сад'),
    (SELECT publisher_id FROM publishers WHERE publisher_name = 'МИФ'),
    2020,
    '978-5-389-00004-4',
    'ru',
    192,
    5000,
    'Русская классика'
WHERE NOT EXISTS (
    SELECT 1
    FROM editions
    WHERE isbn = '978-5-389-00004-4'
);


-- 6. Новый экземпляр книги
INSERT INTO copies (
    edition_id,
    inventory_number,
    shelf_code,
    status
)
SELECT
    e.edition_id,
    'INV-CRUD-006',
    'D2',
    'available'
FROM editions e
WHERE e.isbn = '978-5-389-00004-4'
  AND NOT EXISTS (
      SELECT 1
      FROM copies c
      WHERE c.inventory_number = 'INV-CRUD-006'
  );


-- 7. Регистрация нового читателя
INSERT INTO readers (
    last_name,
    first_name,
    email,
    phone
)
SELECT
    'Мариева',
    'Мария',
    'marieva@example.com',
    '+79990763804'
WHERE NOT EXISTS (
    SELECT 1
    FROM readers
    WHERE email = 'marieva@example.com'
);


-- 8. Новая выдача
INSERT INTO loans (
    copy_id,
    reader_id,
    issue_date,
    due_date,
    return_date,
    status
)
SELECT
    c.copy_id,
    r.reader_id,
    CURRENT_DATE,
    CURRENT_DATE + 14,
    NULL,
    'active'
FROM copies c
CROSS JOIN readers r
WHERE c.inventory_number = 'INV-CRUD-006'
  AND r.email = 'marieva@example.com'
  AND NOT EXISTS (
      SELECT 1
      FROM loans l
      WHERE l.copy_id = c.copy_id
        AND l.reader_id = r.reader_id
        AND l.status = 'active'
  );


-- R = READ

-- 1. Показать всех авторов
SELECT * FROM authors ORDER BY author_id;

-- 2. Показать все произведения
SELECT * FROM works ORDER BY work_id;

-- 3. Показать произведения с авторами
SELECT
    w.work_id,
    w.title,
    a.last_name,
    a.first_name,
    aw.role
FROM works w
JOIN author_work aw
    ON w.work_id = aw.work_id
JOIN authors a
    ON aw.author_id = a.author_id
ORDER BY w.work_id, a.last_name;

-- 4. Показать все издания с издательствами
SELECT
    e.edition_id,
    w.title,
    p.publisher_name,
    e.publication_year,
    e.isbn
FROM editions e
JOIN works w
    ON e.work_id = w.work_id
JOIN publishers p
    ON e.publisher_id = p.publisher_id
ORDER BY e.edition_id;

-- 5. Показать доступные экземпляры
SELECT
    c.copy_id,
    c.inventory_number,
    c.shelf_code,
    c.status,
    w.title
FROM copies c
JOIN editions e
    ON c.edition_id = e.edition_id
JOIN works w
    ON e.work_id = w.work_id
WHERE c.status = 'available'
ORDER BY c.copy_id;

-- 6. Показать активные выдачи
SELECT
    l.loan_id,
    r.last_name,
    r.first_name,
    w.title,
    l.issue_date,
    l.due_date,
    l.status
FROM loans l
JOIN readers r
    ON l.reader_id = r.reader_id
JOIN copies c
    ON l.copy_id = c.copy_id
JOIN editions e
    ON c.edition_id = e.edition_id
JOIN works w
    ON e.work_id = w.work_id
WHERE l.status = 'active'
ORDER BY l.loan_id;


-- U = UPDATE

-- 1. Обновить email читателя
UPDATE readers
SET email = 'update_marieva@example.com'
WHERE email = 'marieva@example.com';

-- 2. Обновить статус экземпляра
UPDATE copies
SET status = 'issued'
WHERE inventory_number = 'INV-CRUD-006';

-- 3. Продлить срок возврата книги
UPDATE loans
SET due_date = due_date + 7
WHERE copy_id = (SELECT copy_id FROM copies WHERE inventory_number = 'INV-CRUD-006')
  AND status = 'active';

-- 4. Обновить примечание об авторе
UPDATE authors
SET notes = 'Русский писатель, драматург, мастер чеховских ружей'
WHERE last_name = 'Чехов'
  AND first_name = 'Антон'
  AND middle_name = 'Павлович';


-- D = DELETE (выполняется в порядке зависимостей)

-- 1. Удалить выдачу
DELETE FROM loans
WHERE copy_id = (SELECT copy_id FROM copies WHERE inventory_number = 'INV-CRUD-006')
  AND reader_id = (
      SELECT reader_id
      FROM readers
      WHERE email = 'update_marieva@example.com'
  );

-- 2. Удалить экземпляр
DELETE FROM copies
WHERE inventory_number = 'INV-CRUD-006';

-- 3. Удалить издание
DELETE FROM editions
WHERE isbn = '978-5-389-00004-4';

-- 4. Удалить связь автора и произведения
DELETE FROM author_work
WHERE author_id = (
        SELECT author_id
        FROM authors
        WHERE last_name = 'Чехов'
          AND first_name = 'Антон'
          AND middle_name = 'Павлович'
      )
  AND work_id = (
        SELECT work_id
        FROM works
        WHERE title = 'Вишнёвый сад'
      )
  AND role = 'автор';

-- 5. Удалить произведение
DELETE FROM works
WHERE title = 'Вишнёвый сад';

-- 6. Удалить автора
DELETE FROM authors
WHERE last_name = 'Чехов'
  AND first_name = 'Антон'
  AND middle_name = 'Павлович';

-- 7. Удалить читателя
DELETE FROM readers WHERE email = 'update_marieva@example.com';

-- 8. Удалить издательство
DELETE FROM publishers WHERE publisher_name = 'МИФ';


-- Для проверки
SELECT * FROM readers ORDER BY reader_id;;
SELECT * FROM publishers ORDER BY publisher_id;
