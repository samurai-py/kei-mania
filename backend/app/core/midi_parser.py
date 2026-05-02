from pathlib import Path
import mido


def midi_to_json(midi_path: Path) -> dict:
    mid = mido.MidiFile(str(midi_path))
    tempo = 500000  # default 120 BPM

    for track in mid.tracks:
        for msg in track:
            if msg.type == "set_tempo":
                tempo = msg.tempo
                break

    bpm = round(60_000_000 / tempo, 2)
    ticks_per_beat = mid.ticks_per_beat
    active: dict[int, dict] = {}
    notes: list[dict] = []
    current_tick = 0

    for msg in mido.merge_tracks(mid.tracks):
        current_tick += msg.time
        current_sec = mido.tick2second(current_tick, ticks_per_beat, tempo)

        if msg.type == "set_tempo":
            tempo = msg.tempo

        if msg.type == "note_on" and msg.velocity > 0:
            active[msg.note] = {"start": current_sec, "velocity": msg.velocity}

        elif msg.type == "note_off" or (msg.type == "note_on" and msg.velocity == 0):
            if msg.note in active:
                onset = active.pop(msg.note)
                notes.append({
                    "pitch": msg.note,
                    "start": round(onset["start"], 4),
                    "end": round(current_sec, 4),
                    "velocity": onset["velocity"],
                })

    notes.sort(key=lambda n: n["start"])
    return {"bpm": bpm, "notes": notes}
