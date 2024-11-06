import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import sys
import os

# Add the parent directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from recipes.main import app
from recipes.models import Base
from recipes.database import get_db

# Use an in-memory SQLite database for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope="function")
def test_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(test_db):
    with TestClient(app) as c:
        yield c

def test_create_recipe(client):
    response = client.post(
        "/recipes/",
        json={
            "title": "Test Recipe",
            "description": "A test recipe",
            "ingredients": "Test ingredients",
            "instructions": "Test instructions"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Recipe"
    assert "id" in data

def test_get_recipe(client):
    # First create a recipe
    recipe = client.post(
        "/recipes/",
        json={
            "title": "Test Recipe",
            "description": "A test recipe",
            "ingredients": "Test ingredients",
            "instructions": "Test instructions"
        }
    ).json()
    
    # Then retrieve it
    response = client.get(f"/recipes/{recipe['id']}")
    assert response.status_code == 200
    assert response.json() == recipe

def test_list_recipes(client):
    # Create two recipes
    recipe1 = client.post(
        "/recipes/",
        json={
            "title": "Test Recipe 1",
            "description": "A test recipe",
            "ingredients": "Test ingredients",
            "instructions": "Test instructions"
        }
    ).json()
    
    recipe2 = client.post(
        "/recipes/",
        json={
            "title": "Test Recipe 2",
            "description": "Another test recipe",
            "ingredients": "More test ingredients",
            "instructions": "More test instructions"
        }
    ).json()
    
    response = client.get("/recipes/")
    assert response.status_code == 200
    assert len(response.json()) == 2

def test_update_recipe(client):
    # Create a recipe
    recipe = client.post(
        "/recipes/",
        json={
            "title": "Test Recipe",
            "description": "A test recipe",
            "ingredients": "Test ingredients",
            "instructions": "Test instructions"
        }
    ).json()
    
    # Update it
    updated_data = {
        "title": "Updated Recipe",
        "description": "An updated recipe",
        "ingredients": "Updated ingredients",
        "instructions": "Updated instructions"
    }
    response = client.put(f"/recipes/{recipe['id']}", json=updated_data)
    assert response.status_code == 200
    assert response.json()["title"] == "Updated Recipe"

def test_delete_recipe(client):
    # Create a recipe
    recipe = client.post(
        "/recipes/",
        json={
            "title": "Test Recipe",
            "description": "A test recipe",
            "ingredients": "Test ingredients",
            "instructions": "Test instructions"
        }
    ).json()
    
    # Delete it
    response = client.delete(f"/recipes/{recipe['id']}")
    assert response.status_code == 200
    
    # Verify it's gone
    response = client.get(f"/recipes/{recipe['id']}")
    assert response.status_code == 404
