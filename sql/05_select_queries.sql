-- 05_select_queries.sql

-- SELECT-запросы
-- JOIN
-- LEFT JOIN
-- запрос через WHERE без JOIN


-- Все читатели и их выдачи (JOIN)
SELECT
    r.reader_id,
    r.last_name,
    r.first_name,
    w.title,
    l.issue_date,
    l.due_date,
    l.return_date,
    l.status
FROM readers r
JOIN loans l
    ON r.reader_id = l.reader_id
JOIN copies c
    ON l.copy_id = c.copy_id
JOIN editions e
    ON c.edition_id = e.edition_id
JOIN works w
    ON e.work_id = w.work_id
ORDER BY r.reader_id, l.issue_date;


-- Только активные выдачи (JOIN)
SELECT
    l.loan_id,
    r.last_name,
    r.first_name,
    w.title,
    l.issue_date,
    l.due_date
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
ORDER BY l.due_date;


-- Произведения, опубликованные после 1850 года (JOIN)
SELECT
    work_id,
    title,
    publication_date
FROM works
WHERE publication_date >= DATE '1850-01-01'
ORDER BY publication_date;


-- Все произведения, даже если у них нет изданий (LEFT JOIN)
-- Выводит все произведения, даже если для них нет записей в editions (в этом случае edition_id будет NULL)
SELECT
    w.work_id,
    w.title,
    e.edition_id,
    e.publication_year
FROM works w
LEFT JOIN editions e
    ON w.work_id = e.work_id
ORDER BY w.work_id, e.publication_year;

-- Все издания, даже если у них нет переводчиков (LEFT JOIN)
-- Сначала связываем издания с произведениями (INNER JOIN), затем через LEFT JOIN добавляем переводчиков (могут отсутствовать)
SELECT
    e.edition_id,
    w.title,
    t.last_name AS translator_last_name,
    t.first_name AS translator_first_name
FROM editions e
JOIN works w
    ON e.work_id = w.work_id
LEFT JOIN edition_translator et
    ON e.edition_id = et.edition_id
LEFT JOIN translators t
    ON et.translator_id = t.translator_id
ORDER BY e.edition_id;

-- Читатели, у которых есть возвращённые книги (пример WHERE без JOIN)
-- DISTINCT нужен, чтобы один читатель не повторялся несколько раз (если у него несколько возвратов)
SELECT DISTINCT
    r.reader_id,
    r.last_name,
    r.first_name
FROM readers r
JOIN loans l
    ON r.reader_id = l.reader_id
WHERE l.status = 'returned'
ORDER BY r.reader_id;

-- Объединение нескольких таблиц: произведения российских авторов, у которых есть издания после 2000 года 
-- Перечисляем таблицы в FROM, задаем связи в WHERE (без JOIN)
-- Используется 4 таблицы: works, author_work, authors, editions
SELECT
    w.title,
    a.last_name,
    e.publication_year
FROM works w, author_work aw, authors a, editions e
WHERE w.work_id = aw.work_id
  AND aw.author_id = a.author_id
  AND w.work_id = e.work_id
  AND a.country = 'Россия'
  AND e.publication_year > 2000
ORDER BY w.title, e.publication_year;