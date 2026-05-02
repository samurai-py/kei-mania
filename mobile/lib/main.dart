import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/converter/converter_screen.dart';
import 'features/settings/settings_screen.dart';

void main() {
  runApp(const KeyTranscriptorApp());
}

class KeyTranscriptorApp extends StatelessWidget {
  const KeyTranscriptorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'key_transcriptor',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const ConverterScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
