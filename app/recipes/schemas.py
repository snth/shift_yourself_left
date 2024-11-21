from pydantic import BaseModel, ConfigDict

class RecipeBase(BaseModel):
    title: str
    description: str | None = None
    ingredients: str
    instructions: str

class RecipeCreate(RecipeBase):
    pass

class Recipe(RecipeBase):
    id: int
    
    model_config = ConfigDict(
        from_attributes = True
    )
