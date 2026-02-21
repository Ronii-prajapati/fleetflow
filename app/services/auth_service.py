from sqlalchemy.orm import Session
from app.models.user import User
from app.core.security import hash_pass,verify_pass,otp,otp_exp
from datetime import datetime

def register(data,db:Session):
    if db.query(User).filter(User.email==data.email).first():
        return None,"Email exists"

    code=otp()
    u=User(email=data.email,password=hash_pass(data.password),otp=code,otp_expiry=otp_exp())
    db.add(u)
    db.commit()
    return u,code

def verify(data,db):
    u=db.query(User).filter(User.email==data.email).first()
    if not u:return False,"User missing"

    if u.otp!=data.otp or datetime.utcnow()>u.otp_expiry:
        return False,"Invalid OTP"

    u.verified=True
    u.otp=None
    db.commit()
    return True,"Verified"

def login(data,db):
    u=db.query(User).filter(User.email==data.email).first()
    if not u or not verify_pass(data.password,u.password):
        return False,"Invalid credentials"

    if not u.verified:
        return False,"Verify first"

    return True,"Login success"

def forgot(email,db):
    u=db.query(User).filter(User.email==email).first()
    if not u:return None

    u.otp=otp()
    u.otp_expiry=otp_exp()
    db.commit()
    return u.otp

def reset(data,db):
    u=db.query(User).filter(User.email==data.email).first()
    if not u:return False

    if u.otp!=data.otp or datetime.utcnow()>u.otp_expiry:
        return False

    u.password=hash_pass(data.newpass)
    u.otp=None
    db.commit()
    return True