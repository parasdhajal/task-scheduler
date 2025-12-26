from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from app.models import TaskCreate, TaskUpdate, TaskResponse, TaskListResponse
from app.database import get_db
from app.classification import classify_task
from app.entity_extraction import extract_entities
from datetime import datetime

router = APIRouter()

@router.post("", response_model=TaskResponse, status_code=201)
async def create_task(task: TaskCreate):
    db = get_db()
    
    classification = classify_task(task.title, task.description)
    entities = extract_entities(task.title, task.description)
    
    if task.assigned_to:
        if task.assigned_to not in entities["people"]:
            entities["people"].append(task.assigned_to)
    
    task_data = {
        "title": task.title,
        "description": task.description,
        "category": classification["category"],
        "priority": classification["priority"],
        "status": "pending",
        "due_date": task.due_date,
        "assigned_to": task.assigned_to,
        "extracted_entities": entities,
        "suggested_actions": classification["suggested_actions"],
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat()
    }
    
    try:
        result = db.table("tasks").insert(task_data).execute()
        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to create task")
        
        created_task = result.data[0]
        
        history_data = {
            "task_id": created_task["id"],
            "action": "created",
            "changed_by": "system",
            "changes": {"status": "created"},
            "created_at": datetime.utcnow().isoformat()
        }
        db.table("task_history").insert(history_data).execute()
        
        return TaskResponse(**created_task)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating task: {str(e)}")

@router.get("", response_model=TaskListResponse)
async def get_tasks(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    category: Optional[str] = None,
    priority: Optional[str] = None,
    status: Optional[str] = None,
    search: Optional[str] = None
):
    db = get_db()
    
    try:
        query = db.table("tasks").select("*")
        
        if category:
            query = query.eq("category", category)
        if priority:
            query = query.eq("priority", priority)
        if status:
            query = query.eq("status", status)
        
        all_tasks = query.execute().data
        
        if search:
            search_lower = search.lower()
            all_tasks = [
                task for task in all_tasks
                if search_lower in task.get("title", "").lower() or
                   search_lower in task.get("description", "").lower()
            ]
        
        total = len(all_tasks)
        total_pages = (total + page_size - 1) // page_size
        start = (page - 1) * page_size
        end = start + page_size
        
        paginated_tasks = all_tasks[start:end]
        task_responses = [TaskResponse(**task) for task in paginated_tasks]
        
        return TaskListResponse(
            tasks=task_responses,
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching tasks: {str(e)}")

@router.get("/{task_id}", response_model=TaskResponse)
async def get_task(task_id: int):
    db = get_db()
    
    try:
        result = db.table("tasks").select("*").eq("id", task_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail=f"Task with id {task_id} not found")
        
        return TaskResponse(**result.data[0])
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching task: {str(e)}")

@router.patch("/{task_id}", response_model=TaskResponse)
async def update_task(task_id: int, task_update: TaskUpdate):
    db = get_db()
    
    existing = db.table("tasks").select("*").eq("id", task_id).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail=f"Task with id {task_id} not found")
    
    update_data = {
        "updated_at": datetime.utcnow().isoformat()
    }
    
    changes = {}
    
    if task_update.title is not None:
        update_data["title"] = task_update.title
        changes["title"] = task_update.title
    
    if task_update.description is not None:
        update_data["description"] = task_update.description
        changes["description"] = task_update.description
    
    if task_update.due_date is not None:
        update_data["due_date"] = task_update.due_date
        changes["due_date"] = task_update.due_date
    
    if task_update.assigned_to is not None:
        update_data["assigned_to"] = task_update.assigned_to
        changes["assigned_to"] = task_update.assigned_to
    
    if task_update.category is not None:
        update_data["category"] = task_update.category
        changes["category"] = task_update.category
    
    if task_update.priority is not None:
        update_data["priority"] = task_update.priority
        changes["priority"] = task_update.priority
    
    if task_update.status is not None:
        update_data["status"] = task_update.status
        changes["status"] = task_update.status
    
    try:
        result = db.table("tasks").update(update_data).eq("id", task_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=500, detail="Failed to update task")
        
        if changes:
            history_data = {
                "task_id": task_id,
                "action": "updated",
                "changed_by": "system",
                "changes": changes,
                "created_at": datetime.utcnow().isoformat()
            }
            db.table("task_history").insert(history_data).execute()
        
        return TaskResponse(**result.data[0])
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating task: {str(e)}")

@router.delete("/{task_id}", status_code=204)
async def delete_task(task_id: int):
    db = get_db()
    
    existing = db.table("tasks").select("*").eq("id", task_id).execute()
    if not existing.data:
        raise HTTPException(status_code=404, detail=f"Task with id {task_id} not found")
    
    try:
        db.table("task_history").delete().eq("task_id", task_id).execute()
        db.table("tasks").delete().eq("id", task_id).execute()
        
        return None
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting task: {str(e)}")
