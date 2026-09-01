import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/auth_api.dart';
import '../state/auth_store.dart';
import '../state/settings_store.dart';

/// Loads persisted settings/session before deciding whether to land on
/// Settings (no server configured yet), Login, or the events list.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final settings = context.read<SettingsStore>();
    final auth = context.read<AuthStore>();
    final authApi = context.read<AuthApi>();

    await settings.init();
    await auth.init();

    if (settings.baseUrl.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/settings');
      return;
    }

    if (auth.token != null) {
      try {
        final user = await authApi.me();
        auth.setUser(user);
      } catch (_) {
        await auth.logout();
      }
    }

    if (!mounted) return;
    Navigator.of(context)
        .pushReplacementNamed(auth.token != null ? '/events' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
