import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api_error.dart';
import '../api/events_api.dart';
import '../l10n/format_date.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/event.dart';
import '../state/auth_store.dart';
import '../widgets/language_switcher.dart';
import 'event/event_shell_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  late Future<List<EventItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<EventsApi>().list();
  }

  Future<void> _refresh() async {
    final next = context.read<EventsApi>().list();
    setState(() => _future = next);
    await next;
  }

  Future<void> _createEvent() async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.eventsCreateDialogTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.eventsNameFieldLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(nameController.text.trim()),
            child: Text(l10n.eventsCreateButton),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (!mounted) return;
    try {
      await context.read<EventsApi>().create(name: name);
      if (!mounted) return;
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeApiError(context, e))));
    }
  }

  Future<void> _logout() async {
    await context.read<AuthStore>().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthStore>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text(user != null
            ? l10n.eventsTitleWithUser(user.name)
            : l10n.eventsTitle),
        actions: [
          const LanguageSwitcher(),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.commonServerSettingsTooltip,
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.commonLogout,
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<EventItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text(describeApiError(context, snapshot.error!))),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton(
                      onPressed: _refresh,
                      child: Text(l10n.commonRetry),
                    ),
                  ),
                ],
              );
            }
            final events = snapshot.data ?? const [];
            if (events.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text(l10n.eventsEmptyState)),
                ],
              );
            }
            return ListView.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: event.eventDate != null
                      ? Text(formatDate(context, event.eventDate!))
                      : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventShellScreen(eventId: event.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEvent,
        tooltip: l10n.eventsCreateTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
