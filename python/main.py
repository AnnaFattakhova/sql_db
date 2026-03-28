import logging
import psycopg2
from datetime import date, timedelta


# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.FileHandler("app.log", encoding="utf-8"),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


# Подключение к БД
def get_connection():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        database="postgres",
        user="postgres",
        password="postgres"
    )


# Проверка, подготовлена ли база
def check_database_ready():
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT EXISTS (
                SELECT 1
                FROM information_schema.tables
                WHERE table_schema = 'public'
                  AND table_name = 'works'
            )
        """)
        works_exists = cur.fetchone()[0]

        cur.execute("""
            SELECT EXISTS (
                SELECT 1
                FROM information_schema.routines
                WHERE routine_schema = 'public'
                  AND routine_name = 'issue_book'
            )
        """)
        issue_book_exists = cur.fetchone()[0]

        cur.execute("""
            SELECT EXISTS (
                SELECT 1
                FROM information_schema.routines
                WHERE routine_schema = 'public'
                  AND routine_name = 'return_book'
            )
        """)
        return_book_exists = cur.fetchone()[0]

        return works_exists and issue_book_exists and return_book_exists

    except Exception as e:
        conn.rollback()
        logger.error("Ошибка при проверке структуры базы: %s", e)
        return False

    finally:
        cur.close()
        conn.close()


# ПОИСК
# 1. Найти доступные книги
def find_available_books(title):
    conn = get_connection()
    cur = conn.cursor()

    try:
        logger.info("Поиск доступных книг по названию: %s", title)

        query = """
        SELECT c.copy_id, c.inventory_number, w.title
        FROM copies c
        JOIN editions e ON c.edition_id = e.edition_id
        JOIN works w ON e.work_id = w.work_id
        WHERE c.status = 'available'
          AND w.title ILIKE %s
        """
        cur.execute(query, (f"%{title}%",))
        rows = cur.fetchall()

        logger.info("Найдено экземпляров: %s", len(rows))
        return rows

    except Exception as e:
        conn.rollback()
        logger.error("Ошибка при поиске книг: %s", e)
        return []

    finally:
        cur.close()
        conn.close()


# 2. Выдать книгу
def issue_book(copy_id, reader_id):
    conn = get_connection()
    cur = conn.cursor()

    try:
        due_date = date.today() + timedelta(days=14)
        logger.info(
            "Выдача книги: copy_id=%s, reader_id=%s, due_date=%s",
            copy_id, reader_id, due_date
        )

        query = "CALL issue_book(%s, %s, %s)"
        cur.execute(query, (copy_id, reader_id, due_date))

        conn.commit()
        logger.info("Книга успешно выдана")

    except Exception as e:
        conn.rollback()
        logger.error("Ошибка при выдаче книги: %s", e)

    finally:
        cur.close()
        conn.close()


# 3. Показать выдачи читателя
def show_reader_loans(reader_id):
    conn = get_connection()
    cur = conn.cursor()

    try:
        logger.info("Получение списка выдач для reader_id=%s", reader_id)

        query = """
        SELECT l.loan_id, w.title, l.issue_date, l.due_date, l.status
        FROM loans l
        JOIN copies c ON l.copy_id = c.copy_id
        JOIN editions e ON c.edition_id = e.edition_id
        JOIN works w ON e.work_id = w.work_id
        WHERE l.reader_id = %s
        ORDER BY l.issue_date DESC, l.loan_id DESC
        """
        cur.execute(query, (reader_id,))
        rows = cur.fetchall()

        logger.info("Получено выдач: %s", len(rows))
        return rows

    except Exception as e:
        conn.rollback()
        logger.error("Ошибка при получении выдач: %s", e)
        return []

    finally:
        cur.close()
        conn.close()


# 4. Вернуть книгу
def return_book(loan_id):
    conn = get_connection()
    cur = conn.cursor()

    try:
        logger.info("Возврат книги: loan_id=%s", loan_id)

        query = "CALL return_book(%s)"
        cur.execute(query, (loan_id,))

        conn.commit()
        logger.info("Книга возвращена")

    except Exception as e:
        conn.rollback()
        logger.error("Ошибка при возврате книги: %s", e)

    finally:
        cur.close()
        conn.close()



# MAIN — связанный сценарий
if __name__ == "__main__":
    logger.info("Запуск Python-скрипта для работы с БД")

    if not check_database_ready():
        logger.error(
            "База данных не подготовлена. "
            "Сначала выполните SQL-файлы: "
            "01_create_tables.sql, 02_constraints_indexes.sql, "
            "03_insert_demo_data.sql, 09_triggers.sql, 10_procedures.sql"
        )
        raise SystemExit(1)

    logger.info("База данных подготовлена, запускаем сценарий")

    books = find_available_books("Гамлет")

    if not books:
        logger.warning("Нет доступных экземпляров для сценария")
        raise SystemExit(0)

    print("Найденные экземпляры")
    for b in books:
        print(f"copy_id={b[0]}, inv={b[1]}, title={b[2]}")

    copy_id = books[0][0]
    reader_id = 1

    print("\nВыдача книги")
    issue_book(copy_id, reader_id)

    print("\nВыдачи читателя")
    loans = show_reader_loans(reader_id)

    if not loans:
        logger.warning("После выдачи не найдено ни одной выдачи у читателя")
        raise SystemExit(0)

    for l in loans:
        print(l)

    last_loan_id = loans[0][0]

    print("\nВозврат книги")
    return_book(last_loan_id)

    print("\nПосле возврата")
    loans = show_reader_loans(reader_id)

    for l in loans:
        print(l)

    logger.info("Сценарий успешно завершён")
