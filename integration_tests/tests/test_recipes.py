import os
import pytest
import httpx
import asyncio
from typing import Generator
import pytest_asyncio

API_BASE_URL = os.getenv("API_BASE_URL", "http://web:8000")

@pytest_asyncio.fixture
async def client():
    async with httpx.AsyncClient(base_url=API_BASE_URL) as client:
        yield client

@pytest.mark.asyncio
async def test_create_and_get_recipe(client):
    # Create a recipe
    recipe_data = {
        "title": "Integration Test Recipe",
        "description": "A test recipe for integration testing",
        "ingredients": "Test ingredients",
        "instructions": "Test instructions"
    }
    
    response = await client.post("/recipes/", json=recipe_data)
    assert response.status_code == 200
    created_recipe = response.json()
    
    # Verify the recipe was created
    response = await client.get(f"/recipes/{created_recipe['id']}")
    assert response.status_code == 200
    retrieved_recipe = response.json()
    assert retrieved_recipe["title"] == recipe_data["title"]

@pytest.mark.asyncio
async def test_list_recipes(client):
    # Create multiple recipes
    recipes = [
        {
            "title": f"Integration Test Recipe {i}",
            "description": f"Test recipe {i}",
            "ingredients": f"Ingredients {i}",
            "instructions": f"Instructions {i}"
        }
        for i in range(3)
    ]
    
    created_recipes = []
    for recipe_data in recipes:
        response = await client.post("/recipes/", json=recipe_data)
        assert response.status_code == 200
        created_recipes.append(response.json())
    
    # Get all recipes
    response = await client.get("/recipes/")
    assert response.status_code == 200
    retrieved_recipes = response.json()
    
    # Verify all created recipes are in the list
    created_ids = {recipe["id"] for recipe in created_recipes}
    retrieved_ids = {recipe["id"] for recipe in retrieved_recipes}
    assert created_ids.issubset(retrieved_ids)

@pytest.mark.asyncio
async def test_update_recipe(client):
    # Create a recipe
    initial_recipe = {
        "title": "Initial Recipe",
        "description": "Initial description",
        "ingredients": "Initial ingredients",
        "instructions": "Initial instructions"
    }
    
    response = await client.post("/recipes/", json=initial_recipe)
    assert response.status_code == 200
    created_recipe = response.json()
    
    # Update the recipe
    updated_data = {
        "title": "Updated Recipe",
        "description": "Updated description",
        "ingredients": "Updated ingredients",
        "instructions": "Updated instructions"
    }
    
    response = await client.put(f"/recipes/{created_recipe['id']}", json=updated_data)
    assert response.status_code == 200
    updated_recipe = response.json()
    assert updated_recipe["title"] == updated_data["title"]
    
    # Verify the update
    response = await client.get(f"/recipes/{created_recipe['id']}")
    assert response.status_code == 200
    retrieved_recipe = response.json()
    assert retrieved_recipe["title"] == updated_data["title"]

@pytest.mark.asyncio
async def test_delete_recipe(client):
    # Create a recipe
    recipe_data = {
        "title": "Recipe to Delete",
        "description": "This recipe will be deleted",
        "ingredients": "Test ingredients",
        "instructions": "Test instructions"
    }
    
    response = await client.post("/recipes/", json=recipe_data)
    assert response.status_code == 200
    created_recipe = response.json()
    
    # Delete the recipe
    response = await client.delete(f"/recipes/{created_recipe['id']}")
    assert response.status_code == 200
    
    # Verify the recipe is gone
    response = await client.get(f"/recipes/{created_recipe['id']}")
    assert response.status_code == 404
