import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'models/song_data.dart';
import '../player/player_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _status = 'ready.';
  bool _loading = false;
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<(String, String)> _prefs() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      prefs.getString(kPrefBackendUrl) ?? kDefaultBackendUrl,
      prefs.getString(kPrefConverter) ?? kDefaultConverter,
    );
  }

  Future<void> _handleResponse(http.Response response) async {
    if (response.statusCode != 200) {
      setState(() {
        _status = 'error: ${response.statusCode}\n${response.body}';
        _loading = false;
      });
      return;
    }

    final songData = SongData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    setState(() {
      _status = 'done. ${songData.notes.length} notes @ ${songData.bpm} bpm';
      _loading = false;
    });

    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(song: songData)));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'flac', 'ogg', 'm4a'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() { _loading = true; _status = 'uploading...'; });

    try {
      final (backendUrl, converter) = await _prefs();
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      setState(() => _status = 'converting via $converter...');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/convert?converter=$converter'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath, filename: fileName));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      await _handleResponse(response);
    } catch (e) {
      setState(() { _status = 'error: $e'; _loading = false; });
    }
  }

  Future<void> _convertUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() { _loading = true; _status = 'downloading from youtube...'; });

    try {
      final (backendUrl, converter) = await _prefs();
      setState(() => _status = 'converting via $converter...');

      final response = await http.post(
        Uri.parse('$backendUrl/convert-url?converter=$converter'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );
      await _handleResponse(response);
    } catch (e) {
      setState(() { _status = 'error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('> key_transcriptor'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: neonGreen,
          unselectedLabelColor: dimGray,
          indicatorColor: neonGreen,
          labelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          tabs: const [
            Tab(text: 'file'),
            Tab(text: 'youtube'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: neonCyan),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: dimGray),
                color: const Color(0xFF111111),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  color: _status.startsWith('error') ? neonPink : neonGreen,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _FileTab(loading: _loading, onPick: _pickFile),
                _YoutubeTab(loading: _loading, controller: _urlController, onConvert: _convertUrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileTab extends StatelessWidget {
  final bool loading;
  final VoidCallback onPick;

  const _FileTab({required this.loading, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('mp3 / wav / flac / ogg / m4a', style: TextStyle(color: dimGray, fontFamily: 'monospace', fontSize: 11)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: loading ? null : onPick,
              child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: neonGreen, strokeWidth: 2))
                  : const Text('> select audio file'),
            ),
          ),
        ],
      ),
    );
  }
}

class _YoutubeTab extends StatelessWidget {
  final bool loading;
  final TextEditingController controller;
  final VoidCallback onConvert;

  const _YoutubeTab({required this.loading, required this.controller, required this.onConvert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('youtube url', style: TextStyle(color: neonCyan, fontFamily: 'monospace', fontSize: 11)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: neonGreen, fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(hintText: 'https://youtube.com/watch?v=...'),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: loading ? null : onConvert,
              child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: neonGreen, strokeWidth: 2))
                  : const Text('> download + convert'),
            ),
          ),
        ],
      ),
    );
  }
}
