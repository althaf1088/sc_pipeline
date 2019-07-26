from db import db
import json


class CustomerModel(db.Model):
    __tablename__ = 'customer'

    cust_no = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(80))
    last_name = db.Column(db.String(80))
    middle_name = db.Column(db.String(80))
    address = db.Column(db.String(800))
    date_of_birth = db.Column(db.String(80))
    mobile_number = db.Column(db.String(80))
    gender = db.Column(db.String(80))
    country_of_birth= db.Column(db.String(80))
    country_of_residence= db.Column(db.String(80))
    customer_segment=db.Column(db.String(80))




    def __init__(self, cust_no, first_name, last_name, addresses=None,
            middle_name=None, date_of_birth=None,mobile_number=None, gender=None,
            country_of_birth=None, country_of_residence=None, customer_segment=None):
        self.cust_no = cust_no
        self.first_name = first_name
        self.last_name = last_name
        self.middle_name= middle_name
        self.date_of_birth=date_of_birth
        self.mobile_number=mobile_number
        self.gender=gender
        self.country_of_birth=country_of_birth
        self.country_of_residence=country_of_residence
        self.customer_segment=customer_segment
        self.address = json.dumps(addresses)

    def json(self):
        return {'cust_no':self.cust_no,'first_name': self.first_name, 'address':
            json.loads(self.address),'last_name':self.last_name,
                'date_of_birth': self.date_of_birth, 'mobile_number':
                    self.mobile_number,'gender':self.gender, 'country_of_birth':
                    self.country_of_birth,'customer_segment':self.customer_segment
                }

    def save_to_db(self):
        db.session.add(self)
        db.session.commit()

    def update_to_db(self):
        db.session.update(self)
        db.session.commit()

    def delete_from_db(self):
        db.session.delete(self)
        db.session.commit()

    @classmethod
    def find_by_customer_number(cls, cust_no):
        return cls.query.filter_by(cust_no=cust_no).first()

