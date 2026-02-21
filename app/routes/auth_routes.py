from fastapi import APIRouter,Depends
from sqlalchemy.orm import Session
from app.schemas.user_schema import *
from app.core.database import get_db
from app.services.auth_service import *

router=APIRouter(prefix="/auth")

@router.post("/register")
def reg(data:Register,db:Session=Depends(get_db)):
    u,code=register(data,db)
    if not u:return {"error":code}
    return {"msg":"OTP sent","otp":code}

@router.post("/verify")
def verify_otp(data:OTPVerify,db:Session=Depends(get_db)):
    ok,msg=verify(data,db)
    return {"msg":msg,"ok":ok}

@router.post("/login")
def log(data:Login,db:Session=Depends(get_db)):
    ok,msg=login(data,db)
    return {"msg":msg,"ok":ok}

@router.post("/forgot")
def f(email:str,db:Session=Depends(get_db)):
    code=forgot(email,db)
    return {"otp":code}

@router.post("/reset")
def r(data:Reset,db:Session=Depends(get_db)):
    ok=reset(data,db)
    return {"success":ok}