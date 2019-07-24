from db import db
import json


class CustomerModel(db.Model):
    __tablename__ = 'customer'

    cust_no = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(80))
    last_name = db.Column(db.String(80))
    address = db.Column(db.String(800))




    def __init__(self, cust_no, first_name, last_name, addresses=None, middle_name=None):
        self.cust_no = cust_no
        self.first_name = first_name
        self.last_name = last_name
        self.address = json.dumps(addresses)

    def json(self):
        return {'cust_no':self.cust_no,'first_name': self.first_name, 'address':
            json.loads(self.address)}

    @classmethod
    def find_by_customer_number(cls, cust_no):
        return cls.query.filter_by(cust_no=cust_no).first()

    def save_to_db(self):
        db.session.add(self)
        db.session.commit()

    def update_to_db(self):
        db.session.update(self)
        db.session.commit()

    def delete_from_db(self):
        db.session.delete(self)
        db.session.commit()