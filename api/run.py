from app import app
from db import db

db.init_app(app)

@app.before_first_request
def create_tables():
    db.create_all()



@app.after_request
def apply_caching(response):
    response.headers.add("Access-Control-Allow-Origin", "*")
    response.headers.add('Access-Control-Allow-Headers', "*")
    response.headers.add('Access-Control-Allow-Methods', "*")
    return response