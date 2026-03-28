-- 01_create_tables.sql
-- Проект: информационная система библиографии и библиотечного фонда
-- СУБД: PostgreSQL

-- Создание всех табиц:
	-- work_types
	-- authors
	-- works
	-- author_work
	-- publishers
	-- editions
	-- translators
	-- edition_translator
	-- copies
	-- readers
	-- loans


-- Для перезапуска
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;
-- На случай повторного запуска удаляем таблицы в порядке зависимостей
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS copies CASCADE;
DROP TABLE IF EXISTS edition_translator CASCADE;
DROP TABLE IF EXISTS translators CASCADE;
DROP TABLE IF EXISTS editions CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;
DROP TABLE IF EXISTS author_work CASCADE;
DROP TABLE IF EXISTS works CASCADE;
DROP TABLE IF EXISTS work_types CASCADE;
DROP TABLE IF EXISTS readers CASCADE;
DROP TABLE IF EXISTS authors CASCADE;

-- Создаем таблицы
-- 1. Авторы
CREATE TABLE authors (
    author_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- поле с идентификатором автора, целочисленный тип, первичный ключ (уникальный + NOT NULL), значение генерируется автоматически СУБД (ALWAYS - нельзя вручную)
    last_name VARCHAR(100) NOT NULL, -- ограничение по количеству символов (100), не может быть нулевого значения
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    birth_date DATE,
    death_date DATE,
    country VARCHAR(100),
    notes TEXT
);


-- 2. Типы произведений
CREATE TABLE work_types (
    type_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    type_name VARCHAR(100) NOT NULL UNIQUE -- уникальные значения
);


-- 3. Произведения
CREATE TABLE works (
    work_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- уникальный иденификатор произведения
    title VARCHAR(255) NOT NULL,
    type_id INT NOT NULL, -- внешний ключ на тип произведения
    writing_start_date DATE,
    writing_end_date DATE,
    publication_date DATE,
    source_work_id INT, -- ссылка на исходное произведение
    description TEXT,
	-- внешний ключ: каждое произведение должно иметь тип
    CONSTRAINT fk_works_type
        FOREIGN KEY (type_id) REFERENCES work_types(type_id),
    -- внешний ключ: текущее произведение может ссылаться на другое произведение как на источник
	CONSTRAINT fk_works_source
        FOREIGN KEY (source_work_id) REFERENCES works(work_id)
);


-- 4. Связь авторов и произведений (many-to-many)
CREATE TABLE author_work (
    author_id INT NOT NULL,
    work_id INT NOT NULL,
    role VARCHAR(100) NOT NULL DEFAULT 'автор', -- автор, если не указана иная роль
    -- внутренний ключ: один автор может участвовать в нескольких произведениях + одно произведение может иметь нескольких авторов + один и тот же автор может иметь разные роли
	PRIMARY KEY (author_id, work_id, role),
    -- внешний ключ: нельзя добавить запись, если такого автора нет
	CONSTRAINT fk_author_work_author
        FOREIGN KEY (author_id) REFERENCES authors(author_id),
    -- внешний ключ: нельзя связать автора с несуществующим произведением
	CONSTRAINT fk_author_work_work
        FOREIGN KEY (work_id) REFERENCES works(work_id)
);


-- 5. Издательства
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    publisher_name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    founded_year INT
);


-- 6. Издания (связь one-to-many)
CREATE TABLE editions (
    edition_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    work_id INT NOT NULL,
    publisher_id INT NOT NULL,
    publication_year INT NOT NULL,
    isbn VARCHAR(20),
    language_code VARCHAR(10) NOT NULL,
    page_count INT,
    circulation INT, -- сколько экземпляров было напечатано издательством
    series_name VARCHAR(255),
	-- внешний ключ: издание относится к произведению (одно произведение — много изданий)
    CONSTRAINT fk_editions_work
        FOREIGN KEY (work_id) REFERENCES works(work_id),
	-- внешний ключ: издание связано с издательством (одно издательство — много изданий)
    CONSTRAINT fk_editions_publisher
        FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);


-- 7. Переводчики
CREATE TABLE translators (
    translator_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    country VARCHAR(100)
);


-- 8. Связь изданий и переводчиков (many-to-many)
CREATE TABLE edition_translator (
    edition_id INT NOT NULL,
    translator_id INT NOT NULL,
	-- внутренний ключ: запрещает дублировать связи между изданиями и переводчиками
    PRIMARY KEY (edition_id, translator_id),
	-- внешний ключ: связь переводчиков с таблицей изданий (нельзя добавить, если нет издания)
    CONSTRAINT fk_edition_translator_edition
        FOREIGN KEY (edition_id) REFERENCES editions(edition_id),
	-- внешний ключ: нельзя добавить связь с переводчиком, которого нет в таблице
    CONSTRAINT fk_edition_translator_translator
        FOREIGN KEY (translator_id) REFERENCES translators(translator_id)
);


-- 9. Экземпляры изданий
CREATE TABLE copies (
    -- первичный ключ: уникальный идентификатор экземпляра
    copy_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    edition_id INT NOT NULL,
    inventory_number VARCHAR(50) NOT NULL UNIQUE,
    shelf_code VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'available', -- текущий статус книги (по умолчанию книга считается доступной)
    -- внешний ключ: связь экземпляра с таблицей изданий (одно издание может иметь много экземпляров)
	CONSTRAINT fk_copies_edition
        FOREIGN KEY (edition_id) REFERENCES editions(edition_id),
    -- ограничение: разрешены только допустимые статусы экземпляра
	CONSTRAINT chk_copies_status
        CHECK (status IN ('available', 'issued', 'lost', 'repair'))
);


-- 10. Читатели
CREATE TABLE readers (
    reader_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(30),
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 11. Выдачи
CREATE TABLE loans (
    -- первичный ключ: уникальный идентификатор записи о выдаче
    loan_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    copy_id INT NOT NULL, -- какой именно экземпляр книги выдан
    reader_id INT NOT NULL,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,-- дата выдачи: по умолчанию подставляется текущая
    due_date DATE NOT NULL, -- дата возврата (de juro)
    return_date DATE, -- дата возврата (de facto); NULL, если книга ещё не возвращена
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- cтатус выдачи (по умолчанию книга доступна для выдачи)
    -- внешний ключ: связь выдачи с конкретным экземпляром книги
    CONSTRAINT fk_loans_copy
        FOREIGN KEY (copy_id) REFERENCES copies(copy_id),
    -- внешний ключ: связь выдачи с читателем
    CONSTRAINT fk_loans_reader
        FOREIGN KEY (reader_id) REFERENCES readers(reader_id),
    -- ограничение: разрешены только допустимые статусы выдачи
    CONSTRAINT chk_loans_status
        CHECK (status IN ('active', 'returned', 'overdue')),
    -- ограничение: дата возврата не может быть раньше даты выдачи
    CONSTRAINT chk_loans_dates
        CHECK (return_date IS NULL OR return_date >= issue_date),
    -- ограничение: срок возврата не может быть раньше даты выдачи
    CONSTRAINT chk_loans_due_date
        CHECK (due_date >= issue_date)
);
