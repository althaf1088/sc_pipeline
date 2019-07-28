#! /bin/bash
sudo yum update
cd /home/ec2-user/api
export DATABASE_URL="postgresql://postgres:123nextstar@database-1.cxwoepvqqboq.us-east-2.rds.amazonaws.com:5432/postgres"
gunicorn -b "0.0.0.0:8000" run:app --daemon