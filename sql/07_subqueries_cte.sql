-- 07_subqueries_cte.sql

-- Подзапросы + CTE
	-- вложенные SELECT
	-- EXISTS, NOT EXISTS
	-- сложные подзапросы
	-- WITH

-- Вложенный Select
-- Читатели, у которых есть хотя бы одна активная выдача
SELECT
    r.reader_id,
    r.last_name,
    r.first_name
FROM readers r
WHERE EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.reader_id = r.reader_id
      AND l.status = 'active'
)
ORDER BY r.reader_id;


-- Вложенный Select, несколько подзапросов
-- Произведения, у которых число изданий выше среднего
SELECT
    w.work_id,
    w.title
FROM works w
WHERE w.work_id IN (
	-- Выбираем только те произведения, у которых число изданий больше среднего значения
    SELECT e.work_id
    FROM editions e
    GROUP BY e.work_id
    HAVING COUNT(e.edition_id) > (
	-- Считаем среднее:
        SELECT AVG(edition_count)
        FROM (
			-- Считаем, сколько изданий есть у каждого произведения:
            SELECT COUNT(*) AS edition_count
            FROM editions
            GROUP BY work_id
        ) AS avg_table
    )
)
ORDER BY w.work_id;


-- Читатели, у которых число выдач равно максимальному
SELECT
    r.reader_id,
    r.last_name,
    r.first_name
FROM readers r
-- Оставляем только тех читателей, чьи reader_id входят в список, который вернёт подзапрос:
WHERE r.reader_id IN (
    -- Получаем reader_id и количество выдач для каждого читателя:
    SELECT loan_stats.reader_id
    FROM (
        SELECT
            reader_id,
            COUNT(*) AS loan_count
        FROM loans
        GROUP BY reader_id
    ) AS loan_stats
    -- Из loan_stats выбираем только тех, у кого число выдач равно максимальному:
    WHERE loan_stats.loan_count = (
        -- Находим максимальное количество выдач среди всех читателей:
        SELECT MAX(inner_stats.loan_count)
        FROM (
            -- Считаем, сколько выдач было у каждого читателя:
            SELECT
                reader_id,
                COUNT(*) AS loan_count
            FROM loans
            GROUP BY reader_id
        ) AS inner_stats
    )
)
ORDER BY r.reader_id;


-- NOT EXISTS

-- Произведения, которые ни разу не выдавались
SELECT
    w.work_id,
    w.title
FROM works w
-- Оставляем только те произведения, для которых НЕ существует ни одной записи о выдаче:
WHERE NOT EXISTS (
    -- Проверяем, есть ли хотя бы одна выдача для данного произведения (editions → copies → loans):
    SELECT 1
    FROM editions e
    JOIN copies c
        ON e.edition_id = c.edition_id
    JOIN loans l
        ON c.copy_id = l.copy_id
    WHERE e.work_id = w.work_id
)
ORDER BY w.work_id;

-- Авторы, у которых нет ни одного произведения типа "пьеса"
SELECT
    a.author_id,
    a.last_name,
    a.first_name
FROM authors a
-- Оставляем только тех авторов, для которых НЕ существует произведений типа "пьеса":
WHERE NOT EXISTS (
    SELECT 1
    FROM author_work aw
    JOIN works w
        ON aw.work_id = w.work_id
    JOIN work_types wt
        ON w.type_id = wt.type_id
    WHERE aw.author_id = a.author_id
      AND wt.type_name = 'пьеса'
)
ORDER BY a.author_id;


-- Нельяза переписать без вложенного запроса
-- Читатели, которые брали все произведения Чехова (двойной NOT EXISTS)
-- (это равно “Нет ни одного произведения Чехова, которое читатель не брал”)
-- ! работает только если выполнить create из crud (04) и потом не удалять Чехова
SELECT
    r.reader_id,
    r.last_name,
    r.first_name
FROM readers r
-- Проверяем, что не существует произведения Чехова, которое читатель не брал
WHERE NOT EXISTS (
    -- Перебираем произведения Чехова
	SELECT 1
    FROM works w
    JOIN author_work aw
        ON w.work_id = aw.work_id
    JOIN authors a
        ON aw.author_id = a.author_id
	-- Берем только Чехова
    WHERE a.last_name = 'Чехов'
      AND a.first_name = 'Антон'
      -- Для текущего произведения проверяем: (не) существует ли выдача этого произведения у текущего читателя
	  AND NOT EXISTS (
          SELECT 1
          FROM loans l
          JOIN copies c
              ON l.copy_id = c.copy_id
          JOIN editions e
              ON c.edition_id = e.edition_id
          WHERE l.reader_id = r.reader_id
            AND e.work_id = w.work_id
      )
)
ORDER BY r.reader_id;

-- WITH

-- Количество выдач по произведениям
WITH work_loan_stats AS ( -- WITH создаёт временную таблицу (CTE) с агрегированными данными по выдачам:
    SELECT
        e.work_id,
        COUNT(l.loan_id) AS loan_count
    FROM editions e
    JOIN copies c
        ON e.edition_id = c.edition_id
    LEFT JOIN loans l
        ON c.copy_id = l.copy_id
    GROUP BY e.work_id
)
-- выводим название произведения и количество его выдач:
SELECT
    w.title,
    ws.loan_count
FROM work_loan_stats ws
-- соединяем агрегированные данные с таблицей works, чтобы получить название произведения:
JOIN works w
    ON ws.work_id = w.work_id
ORDER BY ws.loan_count DESC, w.title;


-- Количество экземпляров по произведениям
-- Считаем, сколько физических экземпляров есть у каждого произведения:
WITH work_copy_stats AS (
    SELECT
        e.work_id,
        COUNT(c.copy_id) AS copy_count
    FROM editions e
    LEFT JOIN copies c
        ON e.edition_id = c.edition_id
    GROUP BY e.work_id
)
-- Выводим название произведения и число его экземпляров:
SELECT
    w.title,
    ws.copy_count
FROM work_copy_stats ws
JOIN works w
    ON ws.work_id = w.work_id
ORDER BY ws.copy_count DESC, w.title;


-- Читатели и число их активных выдач
-- Считаем количество активных выдач по каждому читателю:
WITH active_reader_loans AS (
    SELECT
        reader_id,
        COUNT(*) AS active_loan_count
    FROM loans
    WHERE status = 'active'
    GROUP BY reader_id
)
-- Выводим читателей и количество их текущих выдач:
SELECT
    r.reader_id,
    r.last_name,
    r.first_name,
    arl.active_loan_count
FROM active_reader_loans arl
JOIN readers r
    ON arl.reader_id = r.reader_id
ORDER BY arl.active_loan_count DESC, r.reader_id;