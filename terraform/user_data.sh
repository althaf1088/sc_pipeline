#!/bin/bash
sudo yum update
cd /home/ec2-user/
source flask/bin/activate
cd /home/ec2-user/api
export DATABASE_URL="postgresql://postgres:123nextstar@terraform-20190728053629924800000001.cxhwmrxzgirv.us-east-1.rds.amazonaws.com:5432/postgres"
gunicorn -b "0.0.0.0:8000" run:app --daemon