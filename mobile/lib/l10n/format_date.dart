import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formats [date] as a long localized date (e.g. "August 20, 2026" or
/// "20 августа 2026"), matching the web app's date formatting — the same
/// stored date renders differently depending on the current UI language.
String formatDate(BuildContext context, DateTime date) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return DateFormat.yMMMMd(languageCode).format(date);
}
