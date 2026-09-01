import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_error.dart';
import '../../api/events_api.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/event.dart';
import 'checklist_tab.dart';
import 'event_overview_tab.dart';
import 'guests_tab.dart';
import 'seating_tab.dart';
import 'vendors_tab.dart';

/// Hosts the 5 sections of a single event (Overview/Checklist/Vendors/
/// Guests/Seating) behind a bottom navigation bar, matching the web app's
/// EventSidebar. Fetches the event once here and hands it down, the same
/// way the web app's layout route shares `event` via outlet context.
class EventShellScreen extends StatefulWidget {
  const EventShellScreen({super.key, required this.eventId});

  final int eventId;

  @override
  State<EventShellScreen> createState() => _EventShellScreenState();
}

class _EventShellScreenState extends State<EventShellScreen> {
  late Future<EventItem> _future;
  EventItem? _event;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<EventsApi>().get(widget.eventId);
    _future.then((event) {
      if (mounted) setState(() => _event = event);
    }).catchError((_) {});
  }

  void _onEventSaved(EventItem event) {
    setState(() => _event = event);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_event?.name ?? l10n.eventFallbackTitle)),
      body: _event != null
          ? IndexedStack(
              index: _tabIndex,
              children: [
                EventOverviewTab(event: _event!, onSaved: _onEventSaved),
                ChecklistTab(eventId: widget.eventId),
                VendorsTab(eventId: widget.eventId),
                GuestsTab(eventId: widget.eventId),
                SeatingTab(eventId: widget.eventId),
              ],
            )
          : FutureBuilder<EventItem>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(snapshot.hasError
                          ? describeApiError(context, snapshot.error!)
                          : l10n.commonErrorUnknown),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => setState(_load),
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: _event == null
          ? null
          : NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.info_outline),
                  label: l10n.navOverview,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.checklist),
                  label: l10n.navChecklist,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.storefront_outlined),
                  label: l10n.navVendors,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  label: l10n.navGuests,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.event_seat_outlined),
                  label: l10n.navSeating,
                ),
              ],
            ),
    );
  }
}
