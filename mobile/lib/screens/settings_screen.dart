import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/auth_store.dart';
import '../state/settings_store.dart';
import '../widgets/language_switcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _controller;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: context.read<SettingsStore>().baseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalize(String raw) {
    var value = raw.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'http://$value';
    }
    if (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context);
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));
    try {
      final response = await dio.get('${_normalize(raw)}/api/health');
      _testResult = response.statusCode == 200
          ? l10n.settingsTestSuccess
          : l10n.settingsTestServerError(response.statusCode ?? 0);
    } catch (_) {
      _testResult = l10n.settingsTestFailure;
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsEnterAddressFirst)),
      );
      return;
    }
    context.read<SettingsStore>().setBaseUrl(raw);

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    final hasSession = context.read<AuthStore>().token != null;
    navigator.pushReplacementNamed(hasSession ? '/events' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: const [LanguageSwitcher()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settingsDescription),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: l10n.settingsAddressLabel,
                hintText: l10n.settingsAddressHint,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _testing ? null : _testConnection,
              child: _testing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.settingsTestConnection),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Text(_testResult!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
