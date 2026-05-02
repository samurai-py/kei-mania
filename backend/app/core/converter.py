from pathlib import Path
from typing import Protocol


class MidiConverter(Protocol):
    def convert(self, audio_path: Path) -> Path: ...
