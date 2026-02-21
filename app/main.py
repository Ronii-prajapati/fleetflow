from fastapi import FastAPI
from app.core.config import settings
app = FastAPI(title="FleetFlow API")
@app.get("/")
def root():
    return {"message": "FleetFlow API running"}

# @app.get("/")
# def health():
#     return {"status": "running"}

@app.get("/config-test")
def config_test():
    return {
        "db": settings.DB_NAME,
        "host": settings.DB_HOST
    }

from fastapi import FastAPI
from app.core.database import get_db

app = FastAPI()

@app.get("/db-test")
def test_db():
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.close()
        conn.close()
        return {"status": "DB Connected"}
    except Exception as e:
        return {"error": str(e)}    
    
    