// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Event Planner';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLogout => 'Log out';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonServerSettingsTooltip => 'Server settings';

  @override
  String get commonErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorEmailTaken => 'An account with this email already exists.';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errorInvalidPassword => 'Please enter a password.';

  @override
  String get errorInvalidName => 'Please enter your name.';

  @override
  String get errorInvalidTitle => 'Please enter a title.';

  @override
  String get errorInvalidDate => 'Please enter a valid date.';

  @override
  String get errorInvalidStatus => 'Invalid status.';

  @override
  String get errorInvalidRsvpStatus => 'Invalid RSVP status.';

  @override
  String get errorInvalidLabel => 'Please enter a table name.';

  @override
  String get errorInvalidShape => 'Invalid table shape.';

  @override
  String get errorInvalidTable => 'That table no longer exists.';

  @override
  String get errorInvalidSeat =>
      'That seat number is not valid for this table.';

  @override
  String get errorSeatTaken => 'That seat is already taken.';

  @override
  String get errorPlusOneNoRoom =>
      'There\'s no adjacent seat free for a plus one there.';

  @override
  String get errorInvalidBody => 'Something went wrong sending your request.';

  @override
  String get errorUnauthorized =>
      'Your session has expired. Please log in again.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorConnectionTimeout =>
      'Could not reach the server. Check the address in Settings and make sure your phone is on the same Wi-Fi network as the computer.';

  @override
  String get errorConnectionError =>
      'Could not connect to the server. Check the address in Settings.';

  @override
  String get authLoginTitle => 'Log in';

  @override
  String get authRegisterTitle => 'Register';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authRegisterButton => 'Register';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account? Register';

  @override
  String get authEnterEmailError => 'Enter your email';

  @override
  String get authEnterPasswordError => 'Enter a password';

  @override
  String get authEnterNameError => 'Enter your name';

  @override
  String get settingsTitle => 'Server settings';

  @override
  String get settingsDescription =>
      'Enter the local network address of the Event Planner backend, for example 192.168.1.23:8080. Find your computer\'s IP with ipconfig (Windows) or ifconfig (Mac/Linux), and make sure your phone is on the same Wi-Fi network.';

  @override
  String get settingsAddressLabel => 'Server address';

  @override
  String get settingsAddressHint => '192.168.1.23:8080';

  @override
  String get settingsTestConnection => 'Test connection';

  @override
  String get settingsTestSuccess => 'Connected successfully.';

  @override
  String settingsTestServerError(int status) {
    return 'Server responded with status $status.';
  }

  @override
  String get settingsTestFailure =>
      'Could not reach the server at that address.';

  @override
  String get settingsEnterAddressFirst => 'Enter the server address first.';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystem => 'Match device';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get eventsTitle => 'Events';

  @override
  String eventsTitleWithUser(String name) {
    return 'Events — $name';
  }

  @override
  String get eventsEmptyState => 'No events yet. Tap + to create one.';

  @override
  String get eventsCreateTooltip => 'Create event';

  @override
  String get eventsCreateDialogTitle => 'New event';

  @override
  String get eventsNameFieldLabel => 'Event name';

  @override
  String get eventsCreateButton => 'Create';

  @override
  String get overviewNameRequired => 'Enter an event name';

  @override
  String get overviewDateLabel => 'Date';

  @override
  String get overviewDescriptionLabel => 'Description';

  @override
  String get overviewAddressLabel => 'Address';

  @override
  String get overviewLocationLabel => 'Location';

  @override
  String get overviewLocationHint => 'Tap the map to set the event location.';

  @override
  String get overviewSavedMessage => 'Event saved.';

  @override
  String get navOverview => 'Overview';

  @override
  String get navChecklist => 'Checklist';

  @override
  String get navVendors => 'Vendors';

  @override
  String get navGuests => 'Guests';

  @override
  String get navSeating => 'Seating';

  @override
  String get eventFallbackTitle => 'Event';

  @override
  String get checklistStatusTodo => 'To do';

  @override
  String get checklistStatusInProgress => 'In progress';

  @override
  String get checklistStatusDone => 'Done';

  @override
  String checklistSummary(int count, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items · $done done',
      one: '$count item · $done done',
    );
    return '$_temp0';
  }

  @override
  String get checklistAddItem => 'Add item';

  @override
  String get checklistAddDialogTitle => 'Add checklist item';

  @override
  String get checklistTitleLabel => 'Title';

  @override
  String get checklistTitleRequired => 'Enter a title';

  @override
  String get checklistCategoryLabel => 'Category';

  @override
  String get checklistDueDateLabel => 'Due date';

  @override
  String get checklistEmptyState =>
      'No checklist items yet — add your first one.';

  @override
  String get checklistDeleteItemTitle => 'Delete item?';

  @override
  String checklistConfirmDelete(String title) {
    return 'Delete \"$title\" from the checklist?';
  }

  @override
  String get checklistChangeStatusTooltip => 'Change status';

  @override
  String checklistDueLabel(String date) {
    return 'Due $date';
  }

  @override
  String get vendorsStatusContacted => 'Contacted';

  @override
  String get vendorsStatusNegotiating => 'Negotiating';

  @override
  String get vendorsStatusConfirmed => 'Confirmed';

  @override
  String get vendorsStatusPaid => 'Paid';

  @override
  String get vendorsStatusCancelled => 'Cancelled';

  @override
  String vendorsSummary(int count, int confirmed) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vendors · $confirmed confirmed',
      one: '$count vendor · $confirmed confirmed',
    );
    return '$_temp0';
  }

  @override
  String get vendorsAddVendor => 'Add vendor';

  @override
  String get vendorsAddDialogTitle => 'Add vendor';

  @override
  String get vendorsNameLabel => 'Name';

  @override
  String get vendorsNameRequired => 'Enter a name';

  @override
  String get vendorsCategoryLabel => 'Category';

  @override
  String get vendorsContactNameLabel => 'Contact name';

  @override
  String get vendorsPhoneLabel => 'Phone';

  @override
  String get vendorsPriceLabel => 'Price';

  @override
  String get vendorsStatusLabel => 'Status';

  @override
  String get vendorsEmptyState => 'No vendors yet — add your first one.';

  @override
  String get vendorsDeleteVendorTitle => 'Delete vendor?';

  @override
  String vendorsConfirmDelete(String name) {
    return 'Delete \"$name\" from vendors?';
  }

  @override
  String get vendorsDeleteTooltip => 'Delete vendor';

  @override
  String get guestsRsvpPending => 'Pending';

  @override
  String get guestsRsvpInvited => 'Invited';

  @override
  String get guestsRsvpConfirmed => 'Confirmed';

  @override
  String get guestsRsvpDeclined => 'Declined';

  @override
  String guestsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '$count guest',
    );
    return '$_temp0';
  }

  @override
  String get guestsAddGuest => 'Add guest';

  @override
  String get guestsAddDialogTitle => 'Add guest';

  @override
  String get guestsNameLabel => 'Name';

  @override
  String get guestsNameRequired => 'Enter a name';

  @override
  String get guestsPhoneLabel => 'Phone';

  @override
  String get guestsEmailLabel => 'Email';

  @override
  String get guestsRsvpStatusLabel => 'RSVP status';

  @override
  String get guestsPlusOneLabel => 'Plus one';

  @override
  String get guestsEmptyState => 'No guests yet — add your first one.';

  @override
  String get guestsDeleteGuestTitle => 'Delete guest?';

  @override
  String guestsConfirmDelete(String name) {
    return 'Delete \"$name\" from the guest list?';
  }

  @override
  String get guestsDeleteTooltip => 'Delete guest';

  @override
  String guestsPlusOneUnseatedNotice(String name) {
    return '$name was unseated — their table no longer has room for a plus one.';
  }

  @override
  String seatingSummary(int count, int unassigned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '$count table',
    );
    return '$_temp0, $unassigned unassigned';
  }

  @override
  String get seatingAddTable => 'Add table';

  @override
  String get seatingAddDialogTitle => 'Add table';

  @override
  String get seatingTableNameLabel => 'Name';

  @override
  String get seatingTableNameRequired => 'Enter a name';

  @override
  String get seatingCapacityLabel => 'Capacity';

  @override
  String get seatingCapacityRequired => 'Enter a positive number';

  @override
  String get seatingShapeLabel => 'Shape';

  @override
  String get seatingShapeRound => 'Round';

  @override
  String get seatingShapeRectangle => 'Rectangle';

  @override
  String seatingSelectedBanner(String name) {
    return '$name selected — tap a seat.';
  }

  @override
  String get seatingNoTablesYet =>
      'No tables yet. Tap \"Add table\" to create one.';

  @override
  String seatingSeatedCount(int occupied, int capacity) {
    return '$occupied / $capacity seated';
  }

  @override
  String seatingWithoutSeatNumberSuffix(int count) {
    return ' ($count without a seat number)';
  }

  @override
  String get seatingDeleteTableTooltip => 'Delete table';

  @override
  String get seatingDeleteTableTitle => 'Delete table?';

  @override
  String seatingConfirmDeleteTable(String label) {
    return 'Delete \"$label\"? Any seated guests will become unassigned.';
  }

  @override
  String seatingSeatLabel(int seat) {
    return 'Seat $seat';
  }

  @override
  String get seatingSeatFree => 'Free';

  @override
  String seatingSeatReserved(String name) {
    return 'Reserved ($name\'s +1)';
  }

  @override
  String seatingOccupantDialogSubtitle(String table, int seat) {
    return 'Seated at $table, seat $seat.';
  }

  @override
  String get seatingReassign => 'Reassign';

  @override
  String get seatingUnassign => 'Unassign';

  @override
  String get seatingTapGuestFirst => 'Tap a guest first, then tap a seat.';

  @override
  String seatingUnassignedTitle(int count) {
    return 'Unassigned ($count)';
  }

  @override
  String get seatingEveryoneSeated => 'Everyone has a table.';
}
