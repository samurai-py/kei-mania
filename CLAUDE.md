# key-transcriptor

POC: áudio → MIDI → gameplay visual estilo osu!mania no Android.

## Objetivo

Transcrever músicas para MIDI focando em teclado/piano, renderizar num app Flutter com layout estilo terminal (fundo preto, alto contraste, fontes mono). Suporte a input de teclado físico MIDI para verificar se o usuário está tocando certo.

Substituto do Melody Scanner e Chordify com diferencial visual de gameplay.

## Arquitetura

```
[PC - Python FastAPI backend]  ←→  [Android Flutter APK]
```

Conversão de áudio roda no backend local (PC). Flutter conecta via rede local.

## Backend (`/backend`)

FastAPI + arquitetura hexagonal.

- **Port:** `app/core/converter.py` — `MidiConverter` Protocol
- **Adapters:** `app/adapters/basic_pitch.py`, `app/adapters/omnizart.py`
- **API:** `app/api/routes.py`

### Endpoints

```
POST /convert?converter=basic_pitch   # áudio → MIDI
POST /convert?converter=omnizart
GET  /health
```

Converter escolhido via query param — stateless, sem estado global.

### Rodar backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Mobile (`/mobile`)

Flutter APK. Build:

```bash
cd mobile
flutter pub get
flutter build apk
```

### Features

| Feature | Path | Responsabilidade |
|---|---|---|
| `converter` | `lib/features/converter/` | upload áudio, chama API, recebe .mid |
| `player` | `lib/features/player/` | parse MIDI, lanes caindo, input teclado |
| `settings` | `lib/features/settings/` | IP backend, converter ativo |

### Pacotes principais

- `dart_midi` — parse arquivos .mid
- `flutter_midi_pro` — playback via soundfont .sf2
- `flutter_midi_command` — input teclado físico MIDI (USB OTG ou BLE)
- `flame` — game loop para animação das notas caindo
- `shared_preferences` — persistir settings locais

## Visual

Terminal aesthetic: fundo preto, cores neon alto contraste, fonte mono.
Lanes verticais, notas caindo de cima pra baixo (estilo osu!mania).

## Stack

| Camada | Tech |
|---|---|
| Transcrição | basic-pitch (Spotify) ou omnizart |
| Backend | Python 3.11+, FastAPI, mido |
| Mobile | Flutter 3.x, Dart |
| Audio parse | librosa (backend) |
| MIDI parse mobile | dart_midi |

## Decisões de design

- Converter é trocável via query param — stateless, sem estado global no backend
- Python não roda no Android (deps pesadas) — backend sempre local no PC
- Foco em transcrição de teclado/piano, não bateria ou outros instrumentos
- APK direto, sem publicação em lojas por enquanto
