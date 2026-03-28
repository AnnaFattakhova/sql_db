-- 06_aggregation_queries.sql

-- Разные варианты аггрегаций
	-- GROUP BY
	-- ORDER BY
	-- COUNT, AVG, MIN, MAX
	-- HAVING

-- GROUP BY, ORDER BY, COUNT

-- Количество произведений по типам
SELECT
    wt.type_name,
    COUNT(w.work_id) AS work_count
FROM work_types wt
LEFT JOIN works w
    ON wt.type_id = w.type_id
GROUP BY wt.type_id, wt.type_name
ORDER BY work_count DESC; -- descending (по убыванию)

-- Количество произведений у каждого автора
SELECT
    a.author_id,
    a.last_name,
    a.first_name,
    COUNT(aw.work_id) AS work_count
FROM authors a
LEFT JOIN author_work aw
    ON a.author_id = aw.author_id
GROUP BY a.author_id, a.last_name, a.first_name
ORDER BY work_count DESC, a.last_name;

-- Количество выдач по читателям
SELECT
    r.reader_id,
    r.last_name,
    r.first_name,
    COUNT(l.loan_id) AS loan_count
FROM readers r
LEFT JOIN loans l
    ON r.reader_id = l.reader_id
GROUP BY r.reader_id, r.last_name, r.first_name
ORDER BY loan_count DESC;

-- Количество выдач по произведениям
SELECT
    w.title,
    COUNT(l.loan_id) AS loan_count
FROM works w
JOIN editions e
    ON w.work_id = e.work_id
JOIN copies c
    ON e.edition_id = c.edition_id
LEFT JOIN loans l
    ON c.copy_id = l.copy_id
GROUP BY w.work_id, w.title
ORDER BY loan_count DESC;


-- COUNT
-- Количество активных выдач
SELECT
    COUNT(*) AS active_loans
FROM loans
WHERE status = 'active';


-- AVG

-- Среднее количество страниц по изданиям
SELECT
    AVG(page_count) AS avg_pages
FROM editions;

-- Среднее количество страниц по издательствам
SELECT
    p.publisher_name,
    AVG(e.page_count) AS avg_pages
FROM publishers p
LEFT JOIN editions e
    ON p.publisher_id = e.publisher_id
GROUP BY p.publisher_id, p.publisher_name
ORDER BY avg_pages DESC;

-- Средний срок выдачи (в днях)
SELECT
    AVG(due_date - issue_date) AS avg_loan_days
FROM loans;


-- MIN/MAX
-- Максимальное и минимальное число страниц
SELECT
    MIN(page_count) AS min_pages,
    MAX(page_count) AS max_pages
FROM editions;


-- HAVING

-- 11. Издательства с более чем 1 изданием
SELECT
    p.publisher_name,
    COUNT(e.edition_id) AS edition_count
FROM publishers p
JOIN editions e
    ON p.publisher_id = e.publisher_id
GROUP BY p.publisher_id, p.publisher_name
HAVING COUNT(e.edition_id) > 1
ORDER BY edition_count DESC;


-- Произведения с более чем 1 изданием
SELECT
    w.title,
    COUNT(e.edition_id) AS edition_count
FROM works w
JOIN editions e
    ON w.work_id = e.work_id
GROUP BY w.work_id, w.title
HAVING COUNT(e.edition_id) > 1
ORDER BY edition_count DESC;