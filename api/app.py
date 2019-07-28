from flask import Flask, Blueprint
from flask_cors import CORS
from flask_restplus import Api

from controllers import customer

app = Flask(__name__)
# app.config['SQLALCHEMY_DATABASE_URI'] = os.environ['DATABASE_URL']
app.config[
    'SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:123nextstar@terraform-20190728053629924800000001.cxhwmrxzgirv.us-east-1.rds.amazonaws.com:5432/postgres"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['PROPAGATE_EXCEPTIONS'] = True
app.secret_key = '123star'
CORS(app, resources={r"*"})

blueprint = Blueprint("api", __name__, )

api = Api(blueprint, version='1.0', title='Customer API',
          description='CustomerCRUD')

api.add_namespace(customer.ns)
app.register_blueprint(blueprint)
