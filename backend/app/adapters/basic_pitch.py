from pathlib import Path
import subprocess
import sys


class BasicPitchAdapter:
    def convert(self, audio_path: Path) -> Path:
        output_dir = audio_path.parent
        subprocess.run(
            [sys.executable, "-m", "basic_pitch", str(output_dir), str(audio_path)],
            check=True,
        )
        midi_path = output_dir / f"{audio_path.stem}_basic_pitch.mid"
        if not midi_path.exists():
            raise FileNotFoundError(f"basic-pitch did not produce: {midi_path}")
        return midi_path
