import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../converter/models/song_data.dart';

const _laneCount = 12; // one octave visible
const _hitLineY = 0.85; // fraction from top
const _scrollSpeed = 200.0; // pixels per second
const _noteHeight = 12.0;

class PianoGame extends FlameGame {
  final SongData song;
  double _elapsed = 0;

  static const _laneColors = [
    Color(0xFF00FF88),
    Color(0xFF00FFFF),
    Color(0xFFFF0066),
    Color(0xFFFFFF00),
    Color(0xFF88FF00),
    Color(0xFF0088FF),
    Color(0xFFFF8800),
    Color(0xFFFF00FF),
    Color(0xFF00FF88),
    Color(0xFF00FFFF),
    Color(0xFFFF0066),
    Color(0xFFFFFF00),
  ];

  PianoGame({required this.song});

  @override
  Color backgroundColor() => const Color(0xFF0A0A0A);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;
    final laneW = w / _laneCount;
    final hitY = h * _hitLineY;

    // lane dividers
    final divPaint = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 1;
    for (int i = 0; i <= _laneCount; i++) {
      canvas.drawLine(Offset(i * laneW, 0), Offset(i * laneW, h), divPaint);
    }

    // hit line
    final hitPaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, hitY), Offset(w, hitY), hitPaint);

    // notes
    final minPitch = song.notes.map((n) => n.pitch).reduce((a, b) => a < b ? a : b);

    for (final note in song.notes) {
      final lane = (note.pitch - minPitch) % _laneCount;
      final color = _laneColors[lane];
      final notePaint = Paint()..color = color;
      final borderPaint = Paint()
        ..color = color.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // position: note.start seconds ahead of current time
      final secondsUntilHit = note.start - _elapsed;
      final noteTopY = hitY - secondsUntilHit * _scrollSpeed;
      final noteDurationPx = note.duration * _scrollSpeed;
      final noteBottomY = noteTopY + noteDurationPx.clamp(_noteHeight, double.infinity);

      if (noteTopY > h || noteBottomY < 0) continue;

      final rect = Rect.fromLTRB(
        lane * laneW + 2,
        noteTopY,
        (lane + 1) * laneW - 2,
        noteBottomY,
      );
      canvas.drawRect(rect, notePaint);
      canvas.drawRect(rect, borderPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
  }
}
