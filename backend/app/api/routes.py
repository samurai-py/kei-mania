from pathlib import Path
from typing import Literal
import shutil
import uuid

from fastapi import APIRouter, HTTPException, Query, UploadFile
from pydantic import BaseModel

from app.adapters.basic_pitch import BasicPitchAdapter
from app.adapters.omnizart import OmnizartAdapter
from app.adapters.youtube import YoutubeDownloader
from app.core.midi_parser import midi_to_json

router = APIRouter()

TEMP_DIR = Path("temp")
TEMP_DIR.mkdir(exist_ok=True)

_adapters = {
    "basic_pitch": BasicPitchAdapter(),
    "omnizart": OmnizartAdapter(),
}

_youtube = YoutubeDownloader()


class UrlRequest(BaseModel):
    url: str


@router.get("/health")
def health():
    return {"status": "ok"}


@router.post("/convert")
async def convert(
    file: UploadFile,
    converter: Literal["basic_pitch", "omnizart"] = Query(default="basic_pitch"),
):
    suffix = Path(file.filename).suffix
    job_id = uuid.uuid4().hex
    audio_path = TEMP_DIR / f"{job_id}{suffix}"
    midi_path: Path | None = None

    try:
        with audio_path.open("wb") as f:
            shutil.copyfileobj(file.file, f)

        midi_path = _adapters[converter].convert(audio_path)
        return midi_to_json(midi_path)

    except FileNotFoundError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if audio_path.exists():
            audio_path.unlink()
        if midi_path and midi_path.exists():
            midi_path.unlink()


@router.post("/convert-url")
async def convert_url(
    body: UrlRequest,
    converter: Literal["basic_pitch", "omnizart"] = Query(default="basic_pitch"),
):
    audio_path: Path | None = None
    midi_path: Path | None = None

    try:
        audio_path = _youtube.download(body.url, TEMP_DIR)
        midi_path = _adapters[converter].convert(audio_path)
        return midi_to_json(midi_path)

    except FileNotFoundError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if audio_path and audio_path.exists():
            audio_path.unlink()
        if midi_path and midi_path.exists():
            midi_path.unlink()
