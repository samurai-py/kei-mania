from pathlib import Path
import uuid
import yt_dlp


class YoutubeDownloader:
    def download(self, url: str, output_dir: Path) -> Path:
        job_id = uuid.uuid4().hex
        output_template = str(output_dir / f"{job_id}.%(ext)s")

        ydl_opts = {
            "format": "bestaudio[ext=m4a]/bestaudio[ext=webm]/bestaudio",
            "outtmpl": output_template,
            "quiet": True,
            "no_warnings": True,
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            ext = info.get("ext", "m4a")

        audio_path = output_dir / f"{job_id}.{ext}"
        if not audio_path.exists():
            raise FileNotFoundError(f"yt-dlp did not produce: {audio_path}")
        return audio_path
