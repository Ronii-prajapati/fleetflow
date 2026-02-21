from sqlalchemy import Column,Integer,String,Boolean,DateTime
from app.core.database import Base

class User(Base):
    __tablename__="users"

    id=Column(Integer,primary_key=True,index=True)
    email=Column(String,unique=True,index=True)
    password=Column(String)
    otp=Column(String,nullable=True)
    otp_expiry=Column(DateTime,nullable=True)
    verified=Column(Boolean,default=False)