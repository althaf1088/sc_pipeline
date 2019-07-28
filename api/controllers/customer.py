import logging

from flask import request, jsonify
from flask_restplus import Namespace, Resource, fields
from sqlalchemy.exc import IntegrityError

from models.customer_model import CustomerModel as CustomerModel

ns = Namespace("Customer", description="Customer API", path="/")

address_model = ns.model('address', {
    'type': fields.String(required=True,
                          description='Type'),
    'addr_line1': fields.String(required=True,
                                description='Address line 1'),
    'addr_line2': fields.String(required=False,
                                description='Address line 2'),
    'addr_line3': fields.String(required=False,
                                description='Address line 3'),
    'addr_line4': fields.String(required=False,
                                description='Address line 4'),
    'zipcode': fields.String(required=False,
                             description='Address line 4'),
    'state': fields.String(required=False,
                           description='State'),
    'city': fields.String(required=False,
                          description='City'),

})

customer_model = ns.model('customer', {
    'first_name': fields.String(required=True),
    'middle_name': fields.String(required=False,
                                 description='Middle Name'),
    'last_name': fields.String(required=True,
                               description='Last Name'),
    'date_of_birth': fields.String(required=False,
                                   description='Date of Birth'),
    'mobile_number': fields.String(required=False,
                                   description='Mobile Number'),
    'gender': fields.String(required=False, description='Gender'),
    'cust_no': fields.String(required=True, description='Customer Number'),
    'country_of_birth': fields.String(required=False, description='Country of Birth'),
    'country_of_residence': fields.String(required=False, description='Country of '
                                                                      'Residence'),
    'customer_segment': fields.String(required=False, description='Customer Segment'),
    'addresses': fields.List(cls_or_instance=fields.Nested(address_model), required=False,
                             description='Address')
})

parser = ns.parser()
parser.add_argument("cust_no", type=str, required=True, help='cust_no',
                    location='form')


@ns.route("/customer")
class Customer(Resource):
    @ns.expect(customer_model, validate=True)
    def post(self, **kwargs):
        data_json = request.get_json()
        customer = CustomerModel(**data_json)
        try:
            customer.save_to_db()
        except IntegrityError as err:
            logging.warning("Customer number already exists {} ".format(data_json[
                                                                            'cust_no']))
            return 409
        except Exception as e:
            logging.error("Error occured while saving {} ".format(data_json[
                                                                      'cust_no']))
            return 500
        return 200

    @ns.expect(customer_model, validate=True)
    def put(self, **kwargs):
        data_json = request.get_json()
        customermodel = CustomerModel.find_by_customer_number(data_json['cust_no'])
        if customermodel is None:
            return 404
        else:
            customermodel.first_name = data_json['first_name']
            customermodel.save_to_db()
        return 200

    @ns.doc(parser=parser)
    def delete(self, **kwargs):
        args = parser.parse_args()
        try:
            customermodel = CustomerModel.find_by_customer_number(args['cust_no'])
            if customermodel is None:
                logging.warning("Customer number not present {}".format(args['cust_no']))
                return 404
            customermodel.delete_from_db()
        except Exception as e:
            logging.error("Error occured while saving {} ".format(args[
                                                                      'cust_no']))
            return 500

        return 200


@ns.route("/customers")
class CustomerList(Resource):
    def get(self, **kwargs):
        response = jsonify({'customers': list(map(lambda x: x.json(),
                                                  CustomerModel.query.all()))})
        return response, 200


@ns.route("/customer/<string:cust_no>")
class Customer(Resource):

    def get(self, cust_no, **kwargs):
        try:
            customermodel = CustomerModel.find_by_customer_number(cust_no)
            if customermodel is None:
                logging.warning("Customer number not present {}".format(cust_no))
                return 404
        except Exception as e:
            logging.error("Error occured while saving {} ".format(cust_no))
            return 500
        return customermodel.json(), 200
