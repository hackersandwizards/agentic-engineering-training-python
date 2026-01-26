from sqlmodel import Session, SQLModel, create_engine, select

from app import crud
from app.core.config import settings
from app.models import Contact, ContactCreate, User, UserCreate

# SQLite requires check_same_thread=False for FastAPI
connect_args = {"check_same_thread": False}
engine = create_engine(settings.DATABASE_URL, connect_args=connect_args)


def create_db_and_tables() -> None:
    SQLModel.metadata.create_all(engine)


def init_db(session: Session) -> None:
    # Create first superuser if it doesn't exist
    user = session.exec(
        select(User).where(User.email == settings.FIRST_SUPERUSER)
    ).first()

    if not user:
        user_in = UserCreate(
            email=settings.FIRST_SUPERUSER,
            password=settings.FIRST_SUPERUSER_PASSWORD,
            is_superuser=True,
        )
        user = crud.create_user(session=session, user_create=user_in)

    # Seed test data
    test_users = [
        {"email": "alice@example.com", "password": "AlicePassword123", "full_name": "Alice Example"},
        {"email": "bob@example.com", "password": "BobPassword123", "full_name": "Bob Example"},
    ]
    for u in test_users:
        if not session.exec(select(User).where(User.email == u["email"])).first():
            user_in = UserCreate(email=u["email"], password=u["password"], full_name=u["full_name"])
            crud.create_user(session=session, user_create=user_in)

    # Create test contacts for the superuser
    superuser = session.exec(select(User).where(User.email == settings.FIRST_SUPERUSER)).first()
    if superuser:
        test_contacts = [
            {
                "organisation": "Anthropic",
                "description": "AI safety company, creators of Claude"
            },
            {
                "organisation": "OpenAI",
                "description": "AI research company, creators of GPT and ChatGPT"
            },
            {
                "organisation": "Google DeepMind",
                "description": "Leading AI research lab combining Google's AI expertise with DeepMind's research"
            },
        ]
        for c in test_contacts:
            existing = session.exec(
                select(Contact)
                .where(Contact.organisation == c["organisation"])
                .where(Contact.owner_id == superuser.id)
            ).first()
            if not existing:
                contact_in = ContactCreate(organisation=c["organisation"], description=c["description"])
                crud.create_contact(session=session, contact_in=contact_in, owner_id=superuser.id)
