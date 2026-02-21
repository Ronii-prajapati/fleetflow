from pydantic import BaseModel

class Register(BaseModel):
    email:str
    password:str

class Login(BaseModel):
    email:str
    password:str

class OTPVerify(BaseModel):
    email:str
    otp:str

class Reset(BaseModel):
    email:str
    otp:str
    newpass:str