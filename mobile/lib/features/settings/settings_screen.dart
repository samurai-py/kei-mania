import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  String _converter = kDefaultConverter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = prefs.getString(kPrefBackendUrl) ?? kDefaultBackendUrl;
      _converter = prefs.getString(kPrefConverter) ?? kDefaultConverter;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefBackendUrl, _urlController.text.trim());
    await prefs.setString(kPrefConverter, _converter);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('saved', style: TextStyle(fontFamily: 'monospace'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('> settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('backend url', style: TextStyle(color: neonCyan, fontFamily: 'monospace')),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: neonGreen, fontFamily: 'monospace'),
              decoration: const InputDecoration(hintText: kDefaultBackendUrl),
            ),
            const SizedBox(height: 24),
            const Text('converter', style: TextStyle(color: neonCyan, fontFamily: 'monospace')),
            const SizedBox(height: 8),
            _ConverterTile(
              value: 'basic_pitch',
              label: 'basic_pitch  [spotify / piano focus]',
              groupValue: _converter,
              onChanged: (v) => setState(() => _converter = v),
            ),
            _ConverterTile(
              value: 'omnizart',
              label: 'omnizart     [chords / experimental]',
              groupValue: _converter,
              onChanged: (v) => setState(() => _converter = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('> save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConverterTile extends StatelessWidget {
  final String value;
  final String label;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _ConverterTile({
    required this.value,
    required this.label,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? neonGreen : dimGray),
          color: selected ? const Color(0xFF001a0d) : const Color(0xFF111111),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? neonGreen : dimGray,
              size: 16,
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: selected ? neonGreen : dimGray, fontFamily: 'monospace', fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
