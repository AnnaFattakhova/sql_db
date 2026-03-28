-- 03_insert_demo_data.sql
-- Необходимо запускать после 01_create_tables.sql и 02_constraints_indexes.sql

-- Заполняет таблицы базы данных демонстрационными данными 
--(! данные для примера, могут встречаться исторически недостоверные факты)


-- 1. Типы произведений
INSERT INTO work_types (type_name) VALUES
('роман'),
('рассказ'),
('поэма'),
('пьеса'),
('повесть'),
('сборник'),
('эссе'),
('статья')
ON CONFLICT (type_name) DO NOTHING;


-- 2. Авторы
INSERT INTO authors (
    last_name,
    first_name,
    middle_name,
    birth_date,
    death_date,
    country,
    notes
)
VALUES
('Толстой', 'Лев', 'Николаевич', '1828-09-09', '1910-11-20', 'Россия', 'Русский писатель'),
('Достоевский', 'Фёдор', 'Михайлович', '1821-11-11', '1881-02-09', 'Россия', 'Русский писатель'),
('Пушкин', 'Александр', 'Сергеевич', '1799-06-06', '1837-02-10', 'Россия', 'Русский поэт и писатель'),
('Гоголь', 'Николай', 'Васильевич', '1809-04-01', '1852-03-04', 'Россия', 'Русский писатель'),
('Лермонтов', 'Михаил', 'Юрьевич', '1814-10-15', '1841-07-27', 'Россия', 'Русский поэт и писатель'),
('Тургенев', 'Иван', 'Сергеевич', '1818-11-09', '1883-09-03', 'Россия', 'Русский писатель'),
('Булгаков', 'Михаил', 'Афанасьевич', '1891-05-15', '1940-03-10', 'Россия', 'Русский писатель'),
('Шекспир', 'Уильям', NULL, '1564-04-26', '1616-04-23', 'Англия', 'Английский драматург'),
('Оруэлл', 'Джордж', NULL, '1903-06-25', '1950-01-21', 'Великобритания', 'Английский драматург и эссеист'),
('Диккенс', 'Чарльз', NULL, '1812-02-07', '1870-06-09', 'Англия', 'Английский новелист'),
('Хемингуэй', 'Эрнест', NULL, '1899-07-21', '1961-07-02', 'США', 'Американский писатель'),
('Уайльд', 'Оскар', NULL, '1854-10-16', '1900-11-30', 'Ирландия', 'Ирландский писатель и драматург');


-- 3. Произведения (35)
INSERT INTO works (
    title,
    type_id,
    writing_start_date,
    writing_end_date,
    publication_date,
    source_work_id,
    description
)
VALUES
('Война и мир', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1863-01-01', '1869-01-01', '1869-01-01', NULL, 'Роман-эпопея Л. Н. Толстого'),
('Анна Каренина', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1873-01-01', '1877-01-01', '1877-01-01', NULL, 'Роман Л. Н. Толстого'),
('Смерть Ивана Ильича', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1884-01-01', '1886-01-01', '1886-01-01', NULL, 'Повесть Л. Н. Толстого'),
('Преступление и наказание', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1865-01-01', '1866-01-01', '1866-01-01', NULL, 'Роман Ф. М. Достоевского'),
('Идиот', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1867-01-01', '1869-01-01', '1869-01-01', NULL, 'Роман Ф. М. Достоевского'),
('Братья Карамазовы', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1878-01-01', '1880-01-01', '1880-01-01', NULL, 'Роман Ф. М. Достоевского'),
('Евгений Онегин', (SELECT type_id FROM work_types WHERE type_name = 'поэма'), '1823-01-01', '1831-01-01', '1833-01-01', NULL, 'Роман в стихах А. С. Пушкина'),
('Капитанская дочка', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1835-01-01', '1836-01-01', '1836-01-01', NULL, 'Повесть А. С. Пушкина'),
('Пиковая дама', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1833-01-01', '1834-01-01', '1834-01-01', NULL, 'Повесть А. С. Пушкина'),
('Повести Белкина', (SELECT type_id FROM work_types WHERE type_name = 'сборник'), '1830-01-01', '1831-01-01', '1831-01-01', NULL, 'Сборник повестей А. С. Пушкина'),
('Гамлет', (SELECT type_id FROM work_types WHERE type_name = 'пьеса'), '1599-01-01', '1601-01-01', '1603-01-01', NULL, 'Трагедия Уильяма Шекспира'),
('Ромео и Джульетта', (SELECT type_id FROM work_types WHERE type_name = 'пьеса'), '1594-01-01', '1595-01-01', '1597-01-01', NULL, 'Трагедия Уильяма Шекспира'),
('Макбет', (SELECT type_id FROM work_types WHERE type_name = 'пьеса'), '1605-01-01', '1606-01-01', '1623-01-01', NULL, 'Трагедия Уильяма Шекспира'),
('Гамлет (адаптация для школьников)', (SELECT type_id FROM work_types WHERE type_name = 'пьеса'), '2015-01-01', '2016-01-01', '2016-01-01', (SELECT work_id FROM works WHERE title = 'Гамлет'), 'Адаптированная версия трагедии'),
('Мёртвые души', (SELECT type_id FROM work_types WHERE type_name = 'поэма'), '1835-01-01', '1842-01-01', '1842-01-01', NULL, 'Поэма Н. В. Гоголя'),
('Ревизор', (SELECT type_id FROM work_types WHERE type_name = 'пьеса'), '1835-01-01', '1836-01-01', '1836-01-01', NULL, 'Комедия Н. В. Гоголя'),
('Шинель', (SELECT type_id FROM work_types WHERE type_name = 'рассказ'), '1841-01-01', '1842-01-01', '1842-01-01', NULL, 'Повесть Н. В. Гоголя'),
('Герой нашего времени', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1838-01-01', '1840-01-01', '1840-01-01', NULL, 'Роман М. Ю. Лермонтова'),
('Мцыри', (SELECT type_id FROM work_types WHERE type_name = 'поэма'), '1838-01-01', '1839-01-01', '1840-01-01', NULL, 'Поэма М. Ю. Лермонтова'),
('Бородино', (SELECT type_id FROM work_types WHERE type_name = 'поэма'), '1837-01-01', '1837-01-01', '1837-01-01', NULL, 'Стихотворение М. Ю. Лермонтова'),
('Отцы и дети', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1860-01-01', '1862-01-01', '1862-01-01', NULL, 'Роман И. С. Тургенева'),
('Муму', (SELECT type_id FROM work_types WHERE type_name = 'рассказ'), '1852-01-01', '1852-01-01', '1854-01-01', NULL, 'Рассказ И. С. Тургенева'),
('Ася', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1857-01-01', '1858-01-01', '1858-01-01', NULL, 'Повесть И. С. Тургенева'),
('Мастер и Маргарита', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1928-01-01', '1940-01-01', '1967-01-01', NULL, 'Роман М. А. Булгакова'),
('Собачье сердце', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1925-01-01', '1925-01-01', '1987-01-01', NULL, 'Повесть М. А. Булгакова'),
('Белая гвардия', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1923-01-01', '1925-01-01', '1925-01-01', NULL, 'Роман М. А. Булгакова'),
('1984', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1947-01-01', '1949-01-01', '1949-01-01', NULL, 'Роман Джорджа Оруэлла'),
('Скотный двор', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1943-01-01', '1945-01-01', '1945-01-01', NULL, 'Аллегорическая повесть Джорджа Оруэлла'),
('Памяти Каталонии', (SELECT type_id FROM work_types WHERE type_name = 'эссе'), '1937-01-01', '1938-01-01', '1938-01-01', NULL, 'Книга-эссе Джорджа Оруэлла'),
('Большие надежды', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1860-01-01', '1861-01-01', '1861-01-01', NULL, 'Роман Чарльза Диккенса'),
('Оливер Твист', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1837-01-01', '1839-01-01', '1839-01-01', NULL, 'Роман Чарльза Диккенса'),
('Рождественская песнь', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1843-01-01', '1843-01-01', '1843-01-01', NULL, 'Повесть Чарльза Диккенса'),
('Старик и море', (SELECT type_id FROM work_types WHERE type_name = 'повесть'), '1951-01-01', '1952-01-01', '1952-01-01', NULL, 'Повесть Эрнеста Хемингуэя'),
('Прощай, оружие!', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1928-01-01', '1929-01-01', '1929-01-01', NULL, 'Роман Эрнеста Хемингуэя'),
('Портрет Дориана Грея', (SELECT type_id FROM work_types WHERE type_name = 'роман'), '1890-01-01', '1891-01-01', '1891-01-01', NULL, 'Роман Оскара Уайльда');


-- 4. Связь авторов и произведений
INSERT INTO author_work (author_id, work_id, role)
SELECT a.author_id, w.work_id, 'автор'
FROM authors a
JOIN works w ON (
    (a.last_name = 'Толстой' AND w.title IN ('Война и мир', 'Анна Каренина', 'Смерть Ивана Ильича')) OR
    (a.last_name = 'Достоевский' AND w.title IN ('Преступление и наказание', 'Идиот', 'Братья Карамазовы')) OR
    (a.last_name = 'Пушкин' AND w.title IN ('Евгений Онегин', 'Капитанская дочка', 'Пиковая дама', 'Повести Белкина')) OR
    (a.last_name = 'Шекспир' AND w.title IN ('Гамлет', 'Ромео и Джульетта', 'Макбет', 'Гамлет (адаптация для школьников)')) OR
    (a.last_name = 'Гоголь' AND w.title IN ('Мёртвые души', 'Ревизор', 'Шинель')) OR
    (a.last_name = 'Лермонтов' AND w.title IN ('Герой нашего времени', 'Мцыри', 'Бородино')) OR
    (a.last_name = 'Тургенев' AND w.title IN ('Отцы и дети', 'Муму', 'Ася')) OR
    (a.last_name = 'Булгаков' AND w.title IN ('Мастер и Маргарита', 'Собачье сердце', 'Белая гвардия')) OR
    (a.last_name = 'Оруэлл' AND w.title IN ('1984', 'Скотный двор', 'Памяти Каталонии')) OR
    (a.last_name = 'Диккенс' AND w.title IN ('Большие надежды', 'Оливер Твист', 'Рождественская песнь')) OR
    (a.last_name = 'Хемингуэй' AND w.title IN ('Старик и море', 'Прощай, оружие!')) OR
    (a.last_name = 'Уайльд' AND w.title IN ('Портрет Дориана Грея'))
);


-- 5. Издательства
INSERT INTO publishers (
    publisher_name,
    city,
    country,
    founded_year
)
VALUES
('Эксмо', 'Москва', 'Россия', 1991),
('АСТ', 'Москва', 'Россия', 1990),
('Penguin Books', 'Лондон', 'Великобритания', 1935),
('Oxford University Press', 'Оксфорд', 'Великобритания', 1586),
('HarperCollins', 'Нью-Йорк', 'США', 1989),
('Vintage', 'Лондон', 'Великобритания', 1954);


-- 6. Издания (27)
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
VALUES
((SELECT work_id FROM works WHERE title = 'Война и мир'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2010, '978-5-699-10001-1', 'ru', 1225, 7000, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Война и мир'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2018, '978-5-170-10002-2', 'ru', 1296, 5000, 'Школьная библиотека'),
((SELECT work_id FROM works WHERE title = 'Анна Каренина'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2012, '978-5-699-10003-3', 'ru', 864, 6000, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Смерть Ивана Ильича'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2019, '978-5-170-10004-4', 'ru', 192, 3000, 'Малая проза'),
((SELECT work_id FROM works WHERE title = 'Преступление и наказание'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2015, '978-5-170-10005-5', 'ru', 671, 8000, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Преступление и наказание'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Penguin Books'), 2014, '978-0-141-39000-1', 'en', 560, 4000, 'Penguin Classics'),
((SELECT work_id FROM works WHERE title = 'Идиот'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2021, '978-5-699-10006-6', 'ru', 704, 4500, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Братья Карамазовы'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Penguin Books'), 2013, '978-0-141-39000-2', 'en', 960, 3500, 'Penguin Classics'),
((SELECT work_id FROM works WHERE title = 'Евгений Онегин'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2005, '978-5-699-10007-7', 'ru', 224, 6000, 'Золотая серия поэзии'),
((SELECT work_id FROM works WHERE title = 'Евгений Онегин'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Oxford University Press'), 2011, '978-0-190-10008-8', 'en', 320, 2500, 'Oxford World Classics'),
((SELECT work_id FROM works WHERE title = 'Капитанская дочка'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2017, '978-5-170-10009-9', 'ru', 192, 5000, 'Школьная библиотека'),
((SELECT work_id FROM works WHERE title = 'Повести Белкина'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2020, '978-5-699-10010-0', 'ru', 256, 3500, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Гамлет'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Penguin Books'), 2012, '978-0-141-39000-3', 'en', 320, 4000, 'Penguin Classics'),
((SELECT work_id FROM works WHERE title = 'Гамлет'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2022, '978-5-170-10011-1', 'ru', 256, 4200, 'Зарубежная классика'),
((SELECT work_id FROM works WHERE title = 'Ромео и Джульетта'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Oxford University Press'), 2010, '978-0-190-10012-2', 'en', 288, 2800, 'Oxford School Shakespeare'),
((SELECT work_id FROM works WHERE title = 'Макбет'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Penguin Books'), 2016, '978-0-141-39000-4', 'en', 240, 3000, 'Penguin Classics'),
((SELECT work_id FROM works WHERE title = 'Мёртвые души'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2011, '978-5-699-10013-3', 'ru', 448, 5500, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Ревизор'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2019, '978-5-170-10014-4', 'ru', 160, 3000, 'Школьная библиотека'),
((SELECT work_id FROM works WHERE title = 'Герой нашего времени'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2014, '978-5-699-10015-5', 'ru', 256, 5000, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Мцыри'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2018, '978-5-170-10016-6', 'ru', 96, 2500, 'Поэзия в школе'),
((SELECT work_id FROM works WHERE title = 'Отцы и дети'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2016, '978-5-699-10017-7', 'ru', 288, 5200, 'Русская классика'),
((SELECT work_id FROM works WHERE title = 'Муму'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2021, '978-5-170-10018-8', 'ru', 96, 4000, 'Школьная библиотека'),
((SELECT work_id FROM works WHERE title = 'Мастер и Маргарита'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2013, '978-5-170-10019-9', 'ru', 512, 9000, 'Русская классика XX века'),
((SELECT work_id FROM works WHERE title = 'Собачье сердце'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Эксмо'), 2022, '978-5-699-10020-0', 'ru', 192, 4500, 'Русская классика XX века'),
((SELECT work_id FROM works WHERE title = '1984'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Penguin Books'), 2017, '978-0-141-39000-5', 'en', 352, 6500, 'Modern Classics'),
((SELECT work_id FROM works WHERE title = '1984'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'АСТ'), 2023, '978-5-170-10021-1', 'ru', 352, 7000, 'Зарубежная классика'),
((SELECT work_id FROM works WHERE title = 'Скотный двор'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'HarperCollins'), 2015, '978-0-008-10022-2', 'en', 144, 5000, 'Essential Fiction'),
((SELECT work_id FROM works WHERE title = 'Большие надежды'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Vintage'), 2011, '978-0-099-10023-3', 'en', 544, 3200, 'Vintage Classics'),
((SELECT work_id FROM works WHERE title = 'Оливер Твист'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Penguin Books'), 2018, '978-0-141-39000-6', 'en', 608, 3100, 'Penguin Classics'),
((SELECT work_id FROM works WHERE title = 'Старик и море'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'HarperCollins'), 2014, '978-0-008-10024-4', 'en', 160, 4800, 'Modern Prose'),
((SELECT work_id FROM works WHERE title = 'Портрет Дориана Грея'), (SELECT publisher_id FROM publishers WHERE publisher_name = 'Oxford University Press'), 2019, '978-0-190-10025-5', 'en', 304, 2600, 'Oxford World Classics');


-- 7. Переводчики
INSERT INTO translators (
    last_name,
    first_name,
    middle_name,
    country
)
VALUES
('Пастернак', 'Борис', 'Леонидович', 'Россия'),
('Лозинский', 'Михаил', 'Леонидович', 'Россия'),
('Маршак', 'Самуил', 'Яковлевич', 'Россия'),
('Галь', 'Нора', NULL, 'Россия'),
('Смит', 'Джон', NULL, 'США');


-- 8. Связь изданий и переводчиков
INSERT INTO edition_translator (edition_id, translator_id)
VALUES
(
    (SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-1'),
    (SELECT translator_id FROM translators WHERE last_name = 'Смит' AND first_name = 'Джон')
),
(
    (SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-2'),
    (SELECT translator_id FROM translators WHERE last_name = 'Смит' AND first_name = 'Джон')
),
(
    (SELECT edition_id FROM editions WHERE isbn = '978-0-190-10008-8'),
    (SELECT translator_id FROM translators WHERE last_name = 'Смит' AND first_name = 'Джон')
),
(
    (SELECT edition_id FROM editions WHERE isbn = '978-5-170-10011-1'),
    (SELECT translator_id FROM translators WHERE last_name = 'Пастернак' AND first_name = 'Борис')
),
(
    (SELECT edition_id FROM editions WHERE isbn = '978-5-170-10011-1'),
    (SELECT translator_id FROM translators WHERE last_name = 'Лозинский' AND first_name = 'Михаил')
),
(
    (SELECT edition_id FROM editions WHERE isbn = '978-5-170-10021-1'),
    (SELECT translator_id FROM translators WHERE last_name = 'Галь' AND first_name = 'Нора')
);



-- 9. Экземпляры (40) - физические копии книг
INSERT INTO copies (edition_id, inventory_number, shelf_code, status) VALUES
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10001-1'), 'INV-001', 'A1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10001-1'), 'INV-002', 'A1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10002-2'), 'INV-003', 'A2', 'issued'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10003-3'), 'INV-004', 'A3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10003-3'), 'INV-005', 'A3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10004-4'), 'INV-006', 'A4', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10005-5'), 'INV-007', 'B1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10005-5'), 'INV-008', 'B1', 'issued'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-1'), 'INV-009', 'B2', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10006-6'), 'INV-010', 'B3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-2'), 'INV-011', 'B4', 'lost'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10007-7'), 'INV-012', 'C1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-190-10008-8'), 'INV-013', 'C2', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10009-9'), 'INV-014', 'C3', 'issued'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10010-0'), 'INV-015', 'C4', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-3'), 'INV-016', 'D1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10011-1'), 'INV-017', 'D2', 'issued'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-190-10012-2'), 'INV-018', 'D3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-4'), 'INV-019', 'D4', 'repair'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10013-3'), 'INV-020', 'E1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10013-3'), 'INV-021', 'E1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10014-4'), 'INV-022', 'E2', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10015-5'), 'INV-023', 'E3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10016-6'), 'INV-024', 'E4', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10017-7'), 'INV-025', 'F1', 'issued'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10017-7'), 'INV-026', 'F1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10018-8'), 'INV-027', 'F2', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10019-9'), 'INV-028', 'F3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10019-9'), 'INV-029', 'F3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10020-0'), 'INV-030', 'F4', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-5'), 'INV-031', 'G1', 'issued'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10021-1'), 'INV-032', 'G2', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-008-10022-2'), 'INV-033', 'G3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-099-10023-3'), 'INV-034', 'G4', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-141-39000-6'), 'INV-035', 'G5', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-008-10024-4'), 'INV-036', 'H1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-008-10024-4'), 'INV-037', 'H1', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-0-190-10025-5'), 'INV-038', 'H2', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-699-10015-5'), 'INV-039', 'E3', 'available'),
((SELECT edition_id FROM editions WHERE isbn = '978-5-170-10005-5'), 'INV-040', 'B1', 'available');


-- 10. Читатели
INSERT INTO readers (
    last_name,
    first_name,
    email,
    phone
)
VALUES
('Иванов', 'Иван', 'ivanov@example.com', '+79210035801'),
('Петров', 'Пётр', 'petrov@example.com', '+79212345002'),
('Сидоров', 'Сидр', 'sidorov@example.com', '+79280153403'),
('Еленина', 'Елена', 'elenina@example.com', '+79540459004'),
('Алексеев', 'Алексей', 'alekseev@example.com', '+79210000985'),
('Ольгова', 'Ольга', 'olgova@example.com', '+79210274906'),
('Дмитриев', 'Дмитрий', 'dmitriev@example.com', '+79210000007'),
('Фаттахова', 'Анна', 'fattakhova@example.com', '+79215930008');


-- 11. Выдачи (14)
INSERT INTO loans (
    copy_id,
    reader_id,
    issue_date,
    due_date,
    return_date,
    status
)
VALUES
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-003'), (SELECT reader_id FROM readers WHERE email = 'ivanov@example.com'), CURRENT_DATE - 9,  CURRENT_DATE + 5,  NULL,              'active'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-008'), (SELECT reader_id FROM readers WHERE email = 'petrov@example.com'), CURRENT_DATE - 20, CURRENT_DATE - 5,  NULL,              'overdue'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-014'), (SELECT reader_id FROM readers WHERE email = 'sidorov@example.com'), CURRENT_DATE - 7,  CURRENT_DATE + 7,  NULL,              'active'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-017'), (SELECT reader_id FROM readers WHERE email = 'elenina@example.com'), CURRENT_DATE - 4,  CURRENT_DATE + 10, NULL,              'active'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-025'), (SELECT reader_id FROM readers WHERE email = 'dmitriev@example.com'), CURRENT_DATE - 15, CURRENT_DATE - 1,  NULL,              'overdue'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-031'), (SELECT reader_id FROM readers WHERE email = 'olgova@example.com'), CURRENT_DATE - 2,  CURRENT_DATE + 12, NULL,              'active'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-001'), (SELECT reader_id FROM readers WHERE email = 'ivanov@example.com'), CURRENT_DATE - 35, CURRENT_DATE - 21, CURRENT_DATE - 20, 'returned'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-007'), (SELECT reader_id FROM readers WHERE email = 'petrov@example.com'), CURRENT_DATE - 50, CURRENT_DATE - 36, CURRENT_DATE - 34, 'returned'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-009'), (SELECT reader_id FROM readers WHERE email = 'fattakhova@example.com'), CURRENT_DATE - 28, CURRENT_DATE - 14, CURRENT_DATE - 12, 'returned'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-012'), (SELECT reader_id FROM readers WHERE email = 'alekseev@example.com'), CURRENT_DATE - 40, CURRENT_DATE - 26, CURRENT_DATE - 25, 'returned'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-020'), (SELECT reader_id FROM readers WHERE email = 'olgova@example.com'), CURRENT_DATE - 60, CURRENT_DATE - 46, CURRENT_DATE - 44, 'returned'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-023'), (SELECT reader_id FROM readers WHERE email = 'dmitriev@example.com'), CURRENT_DATE - 18, CURRENT_DATE - 4,  CURRENT_DATE - 2,  'returned'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-028'), (SELECT reader_id FROM readers WHERE email = 'olgova@example.com'), CURRENT_DATE - 22, CURRENT_DATE - 8,  CURRENT_DATE - 7,  'returned'),
((SELECT copy_id FROM copies WHERE inventory_number = 'INV-036'), (SELECT reader_id FROM readers WHERE email = 'fattakhova@example.com'), CURRENT_DATE - 11, CURRENT_DATE + 3,  NULL, 'active');


-- Проверяем

-- Смотрим на таблицы
SELECT * FROM authors ORDER BY last_name, first_name;
SELECT * FROM work_types ORDER BY type_name;
SELECT * FROM works ORDER BY title;
SELECT * FROM author_work ORDER BY author_id, work_id, role;
SELECT * FROM publishers ORDER BY publisher_name;
SELECT * FROM editions ORDER BY publication_year, edition_id;
SELECT * FROM translators ORDER BY last_name, first_name;
SELECT * FROM edition_translator ORDER BY edition_id, translator_id;
SELECT * FROM copies ORDER BY status, inventory_number;
SELECT * FROM readers ORDER BY last_name, first_name;
SELECT * FROM loans ORDER BY issue_date DESC, loan_id;

-- Количество произведений (35)
SELECT COUNT(*) AS work_total FROM works;

-- Количество экземпляров (40)
SELECT COUNT(*) AS total_copies FROM copies;

-- Произведения без изданий
SELECT w.title
FROM works w
LEFT JOIN editions e ON w.work_id = e.work_id
WHERE e.edition_id IS NULL
ORDER BY w.title;

-- Распределение выдач по статусам
SELECT status, COUNT(*) AS cnt
FROM loans
GROUP BY status
ORDER BY cnt DESC;