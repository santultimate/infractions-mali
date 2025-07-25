import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('language'), style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<Locale>(
                  value: Locale('fr'),
                  groupValue: context.locale,
                  onChanged: (val) {
                    if (val != null) context.setLocale(val);
                  },
                ),
                Text('Français'),
                Radio<Locale>(
                  value: Locale('en'),
                  groupValue: context.locale,
                  onChanged: (val) {
                    if (val != null) context.setLocale(val);
                  },
                ),
                Text('English'),
              ],
            ),
            SizedBox(height: 24),
            Text(tr('theme'), style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: (val) {
                    if (val != null) setState(() => _themeMode = val);
                  },
                ),
                Text(tr('system')),
                Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: (val) {
                    if (val != null) setState(() => _themeMode = val);
                  },
                ),
                Text(tr('light')),
                Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: (val) {
                    if (val != null) setState(() => _themeMode = val);
                  },
                ),
                Text(tr('dark')),
              ],
            ),
            SizedBox(height: 24),
            Text(tr('settings_note'), style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
