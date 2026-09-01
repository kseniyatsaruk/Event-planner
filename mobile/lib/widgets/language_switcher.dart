import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/settings_store.dart';

/// A compact EN/RU toggle for the app bar, mirroring the web app's language
/// switcher. Shows the language currently in effect (the user's explicit
/// choice, or the device's language when none has been made) and persists
/// an explicit choice via [SettingsStore].
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    return PopupMenuButton<String>(
      tooltip: l10n.commonLanguage,
      initialValue: current,
      onSelected: (code) => context.read<SettingsStore>().setLanguage(code),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'en', child: Text(l10n.settingsLanguageEnglish)),
        PopupMenuItem(value: 'ru', child: Text(l10n.settingsLanguageRussian)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
