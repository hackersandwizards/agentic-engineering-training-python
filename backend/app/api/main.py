from fastapi import APIRouter

from app.api.routes import contacts, login, users

api_router = APIRouter()
api_router.include_router(login.router)
api_router.include_router(users.router)
api_router.include_router(contacts.router)
