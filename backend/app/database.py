import os
from pathlib import Path
from supabase import create_client, Client
from dotenv import load_dotenv

env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

supabase: Client = None

def init_db():
    global supabase
    
    supabase_url = os.getenv("SUPABASE_URL")
    supabase_key = os.getenv("SUPABASE_KEY")
    
    if not supabase_url or not supabase_key:
        error_msg = "Missing Supabase credentials.\n\n"
        error_msg += "Please create a `.env` file in the `backend/` directory with:\n"
        error_msg += "SUPABASE_URL=https://your-project.supabase.co\n"
        error_msg += "SUPABASE_KEY=your-anon-key-here\n\n"
        error_msg += "Get your credentials from: https://supabase.com/dashboard/project/_/settings/api\n"
        if not supabase_url:
            error_msg += "\nSUPABASE_URL is not set"
        if not supabase_key:
            error_msg += "\nSUPABASE_KEY is not set"
        raise ValueError(error_msg)
    
    if not supabase_url.startswith("https://"):
        raise ValueError(
            f"Invalid SUPABASE_URL format. Expected https://..., got: {supabase_url[:20]}..."
        )
    
    if len(supabase_key.strip()) < 10:
        raise ValueError(
            "SUPABASE_KEY appears to be invalid (too short). "
            "Please check your .env file and ensure you're using the 'anon' key from Supabase."
        )
    
    try:
        supabase = create_client(supabase_url, supabase_key)
        print("Database connection initialized")
    except Exception as e:
        error_msg = f"Failed to connect to Supabase: {str(e)}\n\n"
        error_msg += "Please verify:\n"
        error_msg += "1. Your SUPABASE_URL is correct (from Settings > API)\n"
        error_msg += "2. Your SUPABASE_KEY is the 'anon' key (not service_role key)\n"
        error_msg += "3. Your Supabase project is active (not paused)\n"
        error_msg += f"4. URL format: {supabase_url[:30]}... (should start with https://)\n"
        raise ValueError(error_msg) from e

def get_db():
    if supabase is None:
        init_db()
    return supabase
