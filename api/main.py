from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
import boto3
from dotenv import load_dotenv
import os
from typing import Optional

# Load environment variables from .env file
load_dotenv()

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # React app's URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize AWS DynamoDB client
aws_access_key = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_region = os.getenv("AWS_REGION")

if not aws_access_key or not aws_secret_key or not aws_region:
    raise ValueError("AWS credentials and region must be set in the .env file")

dynamodb = boto3.resource(
    "dynamodb",
    aws_access_key_id=aws_access_key,
    aws_secret_access_key=aws_secret_key,
    region_name=aws_region
)

# Get a reference to the DynamoDB table
table_name = "Movies"
table = dynamodb.Table(table_name)

@app.get("/")
async def root():
    return {"message": "Welcome to the TV Shows API!"}

@app.get("/api/shows")
async def get_tv_shows():
    """
    Fetch all TV shows from the DynamoDB table.
    """
    try:
        response = table.scan(ProjectionExpression="id, title")
        return response.get("Items", [])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error accessing DynamoDB: {str(e)}")

@app.get("/api/seasons")
async def get_seasons(show_id: Optional[str] = Query(None, title="Show ID")):
    """
    Fetch seasons for a specific TV show by show_id.
    """
    if not show_id:
        raise HTTPException(
            status_code=400,
            detail="Please provide a show_id query parameter. If unaware of the showId, check out the /api/shows endpoint."
        )

    try:
        response = table.get_item(Key={"id": show_id})
        item = response.get("Item")

        if not item or "seasons" not in item:
            return {"message": "No seasons found for the given show ID"}

        return {"seasons": item["seasons"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error querying DynamoDB: {str(e)}")
