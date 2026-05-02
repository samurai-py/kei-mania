from pathlib import Path
import subprocess


class OmnizartAdapter:
    def convert(self, audio_path: Path) -> Path:
        output_dir = audio_path.parent
        subprocess.run(
            ["omnizart", "chord", "transcribe", str(audio_path), "-o", str(output_dir)],
            check=True,
        )
        midi_path = output_dir / f"{audio_path.stem}.mid"
        if not midi_path.exists():
            raise FileNotFoundError(f"omnizart did not produce: {midi_path}")
        return midi_path
