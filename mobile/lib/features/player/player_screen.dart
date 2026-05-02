import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../converter/models/song_data.dart';
import 'piano_game.dart';

class PlayerScreen extends StatelessWidget {
  final SongData song;

  const PlayerScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          GameWidget(game: PianoGame(song: song)),
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: neonGreen),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    '${song.notes.length} notes  ${song.bpm} bpm',
                    style: const TextStyle(color: neonCyan, fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
