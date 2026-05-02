class NoteEvent {
  final int pitch;
  final double start;
  final double end;
  final int velocity;

  const NoteEvent({
    required this.pitch,
    required this.start,
    required this.end,
    required this.velocity,
  });

  factory NoteEvent.fromJson(Map<String, dynamic> json) => NoteEvent(
        pitch: json['pitch'] as int,
        start: (json['start'] as num).toDouble(),
        end: (json['end'] as num).toDouble(),
        velocity: json['velocity'] as int,
      );

  double get duration => end - start;
}

class SongData {
  final double bpm;
  final List<NoteEvent> notes;

  const SongData({required this.bpm, required this.notes});

  factory SongData.fromJson(Map<String, dynamic> json) => SongData(
        bpm: (json['bpm'] as num).toDouble(),
        notes: (json['notes'] as List).map((e) => NoteEvent.fromJson(e as Map<String, dynamic>)).toList(),
      );
}
