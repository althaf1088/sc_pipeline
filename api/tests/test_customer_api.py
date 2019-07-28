import unittest
from app import app
from unittest import mock
import json

class test_customer(unittest.TestCase):

    def setUp(self):
        self.app = app
        self.client = self.app.test_client()
        ctx = self.app.app_context()
        ctx.push()

    def test_get_customers(self):
            res = self.client.get("/customers")
            self.assertEqual(res.status_code, 500)


    def test_post_customers_valid(self):

        valid_data =  {"first_name": "Alex",
            "last_name": "Bob",
            "date_of_birth": "10-09-1988",
            "mobile_number": "924768",
            "gender": "M",
            "cust_no": "1234",
            "country_of_birth": "SG",
            "country_of_residence": "SG",
            "customer_segment": "SG",
            "addresses": [
                {
                    "type": "Home",
                    "addr_line1": "SG",
                    "addr_line2": "SG",
                    "addr_line3": "SG",
                    "addr_line4": "SG",
                    "zipcode": "SG",
                    "state": "SG",
                    "city": "SG"
                }
            ]
        }
        with mock.patch("controllers.customer.CustomerModel.save_to_db",
                           return_value=None):
            res = self.client.post("/customer", data=json.dumps(valid_data),content_type='application/json')
            self.assertEqual(res.status_code, 200)


    def test_post_customers_fail1_no_cust_number(self):

        valid_data =  {"first_name": "Alex",
            "last_name": "Bob",
            "date_of_birth": "10-09-1988",
            "mobile_number": "924768",
            "gender": "M",
            "country_of_birth": "SG",
            "country_of_residence": "SG",
            "customer_segment": "SG",
            "addresses": [
                {
                    "type": "Home",
                    "addr_line1": "SG",
                    "addr_line2": "SG",
                    "addr_line3": "SG",
                    "addr_line4": "SG",
                    "zipcode": "SG",
                    "state": "SG",
                    "city": "SG"
                }
            ]
        }
        with mock.patch("controllers.customer.CustomerModel.save_to_db",
                           return_value=None):
            res = self.client.post("/customer", data=json.dumps(valid_data),content_type='application/json')
            self.assertEqual(res.status_code, 400)

    def test_post_customers_fail2_no_first_name(self):

        valid_data =  {
            "last_name": "Bob",
            "date_of_birth": "10-09-1988",
            "mobile_number": "924768",
            "gender": "M",
            "country_of_birth": "SG",
            "country_of_residence": "SG",
            "customer_segment": "SG",
            "cust_no": "1234",
            "addresses": [
                {
                    "type": "Home",
                    "addr_line1": "SG",
                    "addr_line2": "SG",
                    "addr_line3": "SG",
                    "addr_line4": "SG",
                    "zipcode": "SG",
                    "state": "SG",
                    "city": "SG"
                }
            ]
        }
        with mock.patch("controllers.customer.CustomerModel.save_to_db",
                           return_value=None):
            res = self.client.post("/customer", data=json.dumps(valid_data),content_type='application/json')
            self.assertEqual(res.status_code, 400)

    # def test_put_customers_valid(self):
    #
    #     valid_data =  { "first_name":"Alex",
    #         "last_name": "Bob",
    #         "date_of_birth": "10-09-1988",
    #         "mobile_number": "924768",
    #         "gender": "M",
    #         "country_of_birth": "SG",
    #         "country_of_residence": "SG",
    #         "customer_segment": "SG",
    #         "cust_no": "1234",
    #         "addresses": [
    #             {
    #                 "type": "Home",
    #                 "addr_line1": "SG",
    #                 "addr_line2": "SG",
    #                 "addr_line3": "SG",
    #                 "addr_line4": "SG",
    #                 "zipcode": "SG",
    #                 "state": "SG",
    #                 "city": "SG"
    #             }
    #         ]
    #     }
    #     with mock.patch("controllers.customer.CustomerModel.find_by_customer_number") \
    #             as mock_value:
    #         mock_value.return_value = valid_data
    #         res = self.client.delete("/customer/", data=json.dumps(valid_data),
    #                             content_type='application/json')
    #         self.assertEqual(res.status_code, 404)


