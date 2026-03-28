-- 08_window_functions.sql

-- Оконные функции (позволяют выполнять агрегатные вычисления по группе строк без их агрегации)
	-- ROW_NUMBER (даёт уникальный номер строки)
	-- RANK (ранжирует с пропусками, когда, например, одинаковые значения), DENSE_RANK (ранжирует без пропусков)
	-- LAG (берёт значение из предыдущей строки), LEAD (берёт значение из следующей строки)
	-- SUM OVER (считает накопительную сумму — по окну)
	-- AVG OVER (считает среднее значение по группе, но проставляет в каждой строке)


-- Нумерация произведений по дате публикации
SELECT
    work_id,
    title,
    publication_date,
    ROW_NUMBER() OVER (ORDER BY publication_date) AS row_num
FROM works
ORDER BY publication_date;


-- Нумерация изданий внутри каждого произведения
SELECT
    w.title,
    e.edition_id,
    e.publication_year,
    ROW_NUMBER() OVER (
        PARTITION BY w.work_id -- Разбиваем на группы (по произведениям)
        ORDER BY e.publication_year -- Задаем порядок (по году публикации)
    ) AS edition_number
FROM works w
JOIN editions e
    ON w.work_id = e.work_id
ORDER BY w.title, edition_number;


-- Ранг произведений по количеству изданий (с пропусками)
SELECT
    title,
    edition_count,
    RANK() OVER (ORDER BY edition_count DESC) AS work_rank
FROM (
    SELECT
        w.title,
        COUNT(e.edition_id) AS edition_count
    FROM works w
    LEFT JOIN editions e
        ON w.work_id = e.work_id
    GROUP BY w.work_id, w.title
) AS t
ORDER BY work_rank, title;


-- Ранг произведений по количеству экземпляров (без пропусков)
SELECT
    title,
    copy_count,
    DENSE_RANK() OVER (ORDER BY copy_count DESC) AS dense_rank_num
FROM (
    SELECT
        w.title,
        COUNT(c.copy_id) AS copy_count
    FROM works w
    LEFT JOIN editions e
        ON w.work_id = e.work_id
    LEFT JOIN copies c
        ON e.edition_id = c.edition_id
    GROUP BY w.work_id, w.title
) AS t
ORDER BY dense_rank_num, title;


-- Ранжирование читателей по количеству выдач (без пропусков)
SELECT
    last_name,
    first_name,
    loan_count,
    DENSE_RANK() OVER (ORDER BY loan_count DESC) AS reader_rank
FROM (
    SELECT
        r.last_name,
        r.first_name,
        COUNT(l.loan_id) AS loan_count
    FROM readers r
    LEFT JOIN loans l
        ON r.reader_id = l.reader_id
    GROUP BY r.reader_id, r.last_name, r.first_name
) AS t
ORDER BY reader_rank, last_name;


-- Среднее число страниц по издательству для каждого издания
SELECT
    p.publisher_name,
    w.title,
    e.publication_year,
    e.page_count,
    AVG(e.page_count) OVER (
        PARTITION BY p.publisher_id
    ) AS avg_pages_by_publisher
FROM editions e
JOIN works w
    ON e.work_id = w.work_id
JOIN publishers p
    ON e.publisher_id = p.publisher_id
ORDER BY p.publisher_name, e.publication_year;


-- Год предыдущего издания для каждого произведения
SELECT
    w.title,
    e.edition_id,
    e.publication_year,
    LAG(e.publication_year) OVER (
        PARTITION BY w.work_id
        ORDER BY e.publication_year
    ) AS previous_edition_year
FROM works w
JOIN editions e
    ON w.work_id = e.work_id
ORDER BY w.title, e.publication_year;


-- Год следующего издания для каждого произведения
SELECT
    w.title,
    e.edition_id,
    e.publication_year,
    LEAD(e.publication_year) OVER (
        PARTITION BY w.work_id
        ORDER BY e.publication_year
    ) AS next_edition_year
FROM works w
JOIN editions e
    ON w.work_id = e.work_id
ORDER BY w.title, e.publication_year;


-- Количество выдач по датам (= сколько выдач было по дням и как это число накапливается со временем)
SELECT
    issue_date,
    daily_loans,
    SUM(daily_loans) OVER (
        ORDER BY issue_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT row -- Считаем сумму от самого начала до текущей строки
    ) AS cumulative_loans
FROM (
	-- Сколько выдач было в каждый день
    SELECT
        issue_date,
        COUNT(*) AS daily_loans
    FROM loans
    GROUP BY issue_date
) AS t
ORDER BY issue_date;


-- Доля каждой книги в общем числе выдач
SELECT
    title,
    loan_count,
    ROUND(
        100.0 * loan_count / SUM(loan_count) OVER (), 2
    ) AS percent_of_total_loans
FROM (
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
) AS t
ORDER BY loan_count DESC, title;