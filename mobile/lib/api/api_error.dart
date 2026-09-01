import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

/// Maps a backend error code (or a network-level Dio failure) to a
/// human-readable, localized message. The backend intentionally returns
/// language-agnostic codes like {"error": "invalid_credentials"}, never
/// prose, so all display text is decided on the client.
String describeApiError(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  if (error is DioException) {
    final data = error.response?.data;
    String? code;
    if (data is Map && data['error'] is String) {
      code = data['error'] as String;
    }
    switch (code) {
      case 'invalid_credentials':
        return l10n.errorInvalidCredentials;
      case 'email_taken':
        return l10n.errorEmailTaken;
      case 'invalid_email':
        return l10n.errorInvalidEmail;
      case 'invalid_password':
        return l10n.errorInvalidPassword;
      case 'invalid_name':
        return l10n.errorInvalidName;
      case 'invalid_title':
        return l10n.errorInvalidTitle;
      case 'invalid_date':
        return l10n.errorInvalidDate;
      case 'invalid_status':
        return l10n.errorInvalidStatus;
      case 'invalid_rsvp_status':
        return l10n.errorInvalidRsvpStatus;
      case 'invalid_label':
        return l10n.errorInvalidLabel;
      case 'invalid_shape':
        return l10n.errorInvalidShape;
      case 'invalid_table':
        return l10n.errorInvalidTable;
      case 'invalid_seat':
        return l10n.errorInvalidSeat;
      case 'seat_taken':
        return l10n.errorSeatTaken;
      case 'plus_one_no_room':
        return l10n.errorPlusOneNoRoom;
      case 'invalid_body':
        return l10n.errorInvalidBody;
      case 'unauthorized':
        return l10n.errorUnauthorized;
      case 'not_found':
        return l10n.errorNotFound;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return l10n.errorConnectionTimeout;
      case DioExceptionType.connectionError:
        return l10n.errorConnectionError;
      default:
        return l10n.commonErrorUnknown;
    }
  }
  return l10n.commonErrorUnknown;
}
