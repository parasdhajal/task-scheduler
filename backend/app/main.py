from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from app.routers import tasks
from app.database import init_db

app = FastAPI(
    title="Task Scheduler API",
    description="A simple task management API with auto-classification",
    version="1.0.0",
    docs_url=None,          # disable auto docs
    redoc_url=None,
    openapi_url="/openapi.json"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(tasks.router, prefix="/api/tasks", tags=["tasks"])

# Startup
@app.on_event("startup")
async def startup_event():
    init_db()

# Root
@app.get("/")
async def root():
    return {
        "message": "Task Scheduler API is running",
        "version": "1.0.0",
        "docs": "/docs"
    }

# Health check
@app.get("/health")
async def health():
    return {"status": "healthy"}

# 🔥 MANUAL SWAGGER UI (GUARANTEED TO WORK)
@app.get("/docs", include_in_schema=False)
async def swagger_ui():
    return HTMLResponse("""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Task Scheduler API Docs</title>
        <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist/swagger-ui.css">
    </head>
    <body>
        <div id="swagger-ui"></div>
        <script src="https://unpkg.com/swagger-ui-dist/swagger-ui-bundle.js"></script>
        <script>
            SwaggerUIBundle({
                url: "/openapi.json",
                dom_id: "#swagger-ui"
            });
        </script>
    </body>
    </html>
    """)
