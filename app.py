from flask import Flask, Blueprint
from flask_restplus import Api
from controllers import customer
from flask_cors import CORS
import os


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ['DATABASE_URL']
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['PROPAGATE_EXCEPTIONS'] = True
app.secret_key = '123star'
CORS(app)

blueprint = Blueprint("api", __name__, )

api = Api(blueprint, version='1.0', title='Customer API',
              description='CustomerCRUD')

api.add_namespace(customer.ns)
app.register_blueprint(blueprint)
