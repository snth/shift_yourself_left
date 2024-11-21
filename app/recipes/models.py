from sqlalchemy import Column, Integer, String, Text, create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

Base = declarative_base()

class Recipe(Base):
    __tablename__ = "recipes"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(100), nullable=False)
    description = Column(Text)
    ingredients = Column(Text, nullable=False)
    instructions = Column(Text, nullable=False)
