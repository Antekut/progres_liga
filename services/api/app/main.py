from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from supabase import create_client

from app.config import settings

app = FastAPI(title="progres-liga-api")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/tagline")
def tagline() -> dict[str, str]:
    return {"message": "ProgresLiga — Twój ranking progresu na tle innych"}


@app.get("/api/leaderboard")
def leaderboard_from_db() -> dict[str, list[dict]]:
    if not settings.supabase_url or not settings.supabase_secret_key:
        raise HTTPException(
            status_code=503,
            detail="Supabase is not configured (SUPABASE_URL, SUPABASE_SECRET_KEY)",
        )
    client = create_client(settings.supabase_url, settings.supabase_secret_key)
    result = (
        client.table("athletes")
        .select("id, name, score, weekly_gain_pct, is_you")
        .order("score", desc=True)
        .execute()
    )
    rows = result.data or []
    if not rows:
        raise HTTPException(status_code=404, detail="No athletes in leaderboard")
    return {"athletes": rows}
