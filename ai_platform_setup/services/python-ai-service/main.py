
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Python AI Service")

class TextInput(BaseModel):
    input_text: str

class TextResponse(BaseModel):
    output_text: str

@app.post("/process_text", response_model=TextResponse)
async def process_text(data: TextInput):
    processed_text = data.input_text.upper()  # Placeholder for processing
    return TextResponse(output_text=processed_text)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
