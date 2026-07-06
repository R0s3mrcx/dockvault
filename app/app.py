from flask import Flask, request, jsonify
import psycopg2
import os

app = Flask(__name__)


def get_connection():
    return psycopg2.connect(
        host=os.environ.get("POSTGRES_HOST", "db"),
        port=os.environ.get("POSTGRES_PORT", "5432"),
        user=os.environ.get("POSTGRES_USER"),
        password=os.environ.get("POSTGRES_PASSWORD"),
        dbname=os.environ.get("POSTGRES_DB"),
    )


def init_db():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                CREATE TABLE IF NOT EXISTS items (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100) NOT NULL
                )
                """
            )


@app.route("/")
def health():
    return {"status": "ok"}


@app.route("/items", methods=["GET"])
def get_items():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name FROM items ORDER BY id")
            rows = cur.fetchall()

    items = [{"id": row[0], "name": row[1]} for row in rows]

    return jsonify(items)


@app.route("/items", methods=["POST"])
def add_item():
    data = request.get_json() or {}
    name = data.get("name")

    if not name:
        return {"error": "name is required"}, 400

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO items (name) VALUES (%s)",
                (name,),
            )

    return {"message": "item created"}, 201


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
