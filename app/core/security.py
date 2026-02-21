import hashlib,random
from datetime import datetime,timedelta

def hash_pass(p):
    return hashlib.md5(p.encode()).hexdigest()

def verify_pass(p,h):
    return hash_pass(p)==h

def otp():
    return str(random.randint(100000,999999))

def otp_exp():
    return datetime.utcnow()+timedelta(minutes=2)