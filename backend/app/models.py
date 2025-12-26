from pydantic import BaseModel, Field
from typing import Optional, Dict, List

class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1)
    due_date: Optional[str] = None
    assigned_to: Optional[str] = Field(None, max_length=100)

class TaskUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, min_length=1)
    due_date: Optional[str] = None
    assigned_to: Optional[str] = Field(None, max_length=100)
    category: Optional[str] = None
    priority: Optional[str] = None
    status: Optional[str] = None

class ExtractedEntity(BaseModel):
    dates: List[str] = Field(default_factory=list)
    people: List[str] = Field(default_factory=list)

class TaskResponse(BaseModel):
    id: int
    title: str
    description: str
    category: str
    priority: str
    status: str
    due_date: Optional[str] = None
    assigned_to: Optional[str] = None
    extracted_entities: Dict = Field(default_factory=dict)
    suggested_actions: List[str] = Field(default_factory=list)
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True

class TaskListResponse(BaseModel):
    tasks: List[TaskResponse]
    total: int
    page: int
    page_size: int
    total_pages: int
