import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Planner'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get commonLogout;

  /// No description provided for @commonLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @commonServerSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Server settings'**
  String get commonServerSettingsTooltip;

  /// No description provided for @commonErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonErrorUnknown;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errorEmailTaken;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get errorInvalidPassword;

  /// No description provided for @errorInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get errorInvalidName;

  /// No description provided for @errorInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get errorInvalidTitle;

  /// No description provided for @errorInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid date.'**
  String get errorInvalidDate;

  /// No description provided for @errorInvalidStatus.
  ///
  /// In en, this message translates to:
  /// **'Invalid status.'**
  String get errorInvalidStatus;

  /// No description provided for @errorInvalidRsvpStatus.
  ///
  /// In en, this message translates to:
  /// **'Invalid RSVP status.'**
  String get errorInvalidRsvpStatus;

  /// No description provided for @errorInvalidLabel.
  ///
  /// In en, this message translates to:
  /// **'Please enter a table name.'**
  String get errorInvalidLabel;

  /// No description provided for @errorInvalidShape.
  ///
  /// In en, this message translates to:
  /// **'Invalid table shape.'**
  String get errorInvalidShape;

  /// No description provided for @errorInvalidTable.
  ///
  /// In en, this message translates to:
  /// **'That table no longer exists.'**
  String get errorInvalidTable;

  /// No description provided for @errorInvalidSeat.
  ///
  /// In en, this message translates to:
  /// **'That seat number is not valid for this table.'**
  String get errorInvalidSeat;

  /// No description provided for @errorSeatTaken.
  ///
  /// In en, this message translates to:
  /// **'That seat is already taken.'**
  String get errorSeatTaken;

  /// No description provided for @errorPlusOneNoRoom.
  ///
  /// In en, this message translates to:
  /// **'There\'s no adjacent seat free for a plus one there.'**
  String get errorPlusOneNoRoom;

  /// No description provided for @errorInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong sending your request.'**
  String get errorInvalidBody;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check the address in Settings and make sure your phone is on the same Wi-Fi network as the computer.'**
  String get errorConnectionTimeout;

  /// No description provided for @errorConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Check the address in Settings.'**
  String get errorConnectionError;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authNameLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterButton;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get authNoAccountPrompt;

  /// No description provided for @authEnterEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEnterEmailError;

  /// No description provided for @authEnterPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get authEnterPasswordError;

  /// No description provided for @authEnterNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authEnterNameError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Server settings'**
  String get settingsTitle;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the local network address of the Event Planner backend, for example 192.168.1.23:8080. Find your computer\'s IP with ipconfig (Windows) or ifconfig (Mac/Linux), and make sure your phone is on the same Wi-Fi network.'**
  String get settingsDescription;

  /// No description provided for @settingsAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get settingsAddressLabel;

  /// No description provided for @settingsAddressHint.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.23:8080'**
  String get settingsAddressHint;

  /// No description provided for @settingsTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get settingsTestConnection;

  /// No description provided for @settingsTestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully.'**
  String get settingsTestSuccess;

  /// No description provided for @settingsTestServerError.
  ///
  /// In en, this message translates to:
  /// **'Server responded with status {status}.'**
  String settingsTestServerError(int status);

  /// No description provided for @settingsTestFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server at that address.'**
  String get settingsTestFailure;

  /// No description provided for @settingsEnterAddressFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the server address first.'**
  String get settingsEnterAddressFirst;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Match device'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTitle;

  /// No description provided for @eventsTitleWithUser.
  ///
  /// In en, this message translates to:
  /// **'Events — {name}'**
  String eventsTitleWithUser(String name);

  /// No description provided for @eventsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No events yet. Tap + to create one.'**
  String get eventsEmptyState;

  /// No description provided for @eventsCreateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create event'**
  String get eventsCreateTooltip;

  /// No description provided for @eventsCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get eventsCreateDialogTitle;

  /// No description provided for @eventsNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get eventsNameFieldLabel;

  /// No description provided for @eventsCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get eventsCreateButton;

  /// No description provided for @overviewNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an event name'**
  String get overviewNameRequired;

  /// No description provided for @overviewDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get overviewDateLabel;

  /// No description provided for @overviewDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get overviewDescriptionLabel;

  /// No description provided for @overviewAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get overviewAddressLabel;

  /// No description provided for @overviewLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get overviewLocationLabel;

  /// No description provided for @overviewLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set the event location.'**
  String get overviewLocationHint;

  /// No description provided for @overviewSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Event saved.'**
  String get overviewSavedMessage;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get navChecklist;

  /// No description provided for @navVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get navVendors;

  /// No description provided for @navGuests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get navGuests;

  /// No description provided for @navSeating.
  ///
  /// In en, this message translates to:
  /// **'Seating'**
  String get navSeating;

  /// No description provided for @eventFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventFallbackTitle;

  /// No description provided for @checklistStatusTodo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get checklistStatusTodo;

  /// No description provided for @checklistStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get checklistStatusInProgress;

  /// No description provided for @checklistStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get checklistStatusDone;

  /// No description provided for @checklistSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} item · {done} done} other{{count} items · {done} done}}'**
  String checklistSummary(int count, int done);

  /// No description provided for @checklistAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get checklistAddItem;

  /// No description provided for @checklistAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add checklist item'**
  String get checklistAddDialogTitle;

  /// No description provided for @checklistTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get checklistTitleLabel;

  /// No description provided for @checklistTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get checklistTitleRequired;

  /// No description provided for @checklistCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get checklistCategoryLabel;

  /// No description provided for @checklistDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get checklistDueDateLabel;

  /// No description provided for @checklistEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No checklist items yet — add your first one.'**
  String get checklistEmptyState;

  /// No description provided for @checklistDeleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get checklistDeleteItemTitle;

  /// No description provided for @checklistConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" from the checklist?'**
  String checklistConfirmDelete(String title);

  /// No description provided for @checklistChangeStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get checklistChangeStatusTooltip;

  /// No description provided for @checklistDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String checklistDueLabel(String date);

  /// No description provided for @vendorsStatusContacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get vendorsStatusContacted;

  /// No description provided for @vendorsStatusNegotiating.
  ///
  /// In en, this message translates to:
  /// **'Negotiating'**
  String get vendorsStatusNegotiating;

  /// No description provided for @vendorsStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get vendorsStatusConfirmed;

  /// No description provided for @vendorsStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get vendorsStatusPaid;

  /// No description provided for @vendorsStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get vendorsStatusCancelled;

  /// No description provided for @vendorsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} vendor · {confirmed} confirmed} other{{count} vendors · {confirmed} confirmed}}'**
  String vendorsSummary(int count, int confirmed);

  /// No description provided for @vendorsAddVendor.
  ///
  /// In en, this message translates to:
  /// **'Add vendor'**
  String get vendorsAddVendor;

  /// No description provided for @vendorsAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add vendor'**
  String get vendorsAddDialogTitle;

  /// No description provided for @vendorsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get vendorsNameLabel;

  /// No description provided for @vendorsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get vendorsNameRequired;

  /// No description provided for @vendorsCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get vendorsCategoryLabel;

  /// No description provided for @vendorsContactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get vendorsContactNameLabel;

  /// No description provided for @vendorsPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get vendorsPhoneLabel;

  /// No description provided for @vendorsPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get vendorsPriceLabel;

  /// No description provided for @vendorsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get vendorsStatusLabel;

  /// No description provided for @vendorsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No vendors yet — add your first one.'**
  String get vendorsEmptyState;

  /// No description provided for @vendorsDeleteVendorTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete vendor?'**
  String get vendorsDeleteVendorTitle;

  /// No description provided for @vendorsConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" from vendors?'**
  String vendorsConfirmDelete(String name);

  /// No description provided for @vendorsDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete vendor'**
  String get vendorsDeleteTooltip;

  /// No description provided for @guestsRsvpPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get guestsRsvpPending;

  /// No description provided for @guestsRsvpInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get guestsRsvpInvited;

  /// No description provided for @guestsRsvpConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get guestsRsvpConfirmed;

  /// No description provided for @guestsRsvpDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get guestsRsvpDeclined;

  /// No description provided for @guestsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} guest} other{{count} guests}}'**
  String guestsSummary(int count);

  /// No description provided for @guestsAddGuest.
  ///
  /// In en, this message translates to:
  /// **'Add guest'**
  String get guestsAddGuest;

  /// No description provided for @guestsAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add guest'**
  String get guestsAddDialogTitle;

  /// No description provided for @guestsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get guestsNameLabel;

  /// No description provided for @guestsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get guestsNameRequired;

  /// No description provided for @guestsPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get guestsPhoneLabel;

  /// No description provided for @guestsEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get guestsEmailLabel;

  /// No description provided for @guestsRsvpStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'RSVP status'**
  String get guestsRsvpStatusLabel;

  /// No description provided for @guestsPlusOneLabel.
  ///
  /// In en, this message translates to:
  /// **'Plus one'**
  String get guestsPlusOneLabel;

  /// No description provided for @guestsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No guests yet — add your first one.'**
  String get guestsEmptyState;

  /// No description provided for @guestsDeleteGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete guest?'**
  String get guestsDeleteGuestTitle;

  /// No description provided for @guestsConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" from the guest list?'**
  String guestsConfirmDelete(String name);

  /// No description provided for @guestsDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete guest'**
  String get guestsDeleteTooltip;

  /// No description provided for @guestsPlusOneUnseatedNotice.
  ///
  /// In en, this message translates to:
  /// **'{name} was unseated — their table no longer has room for a plus one.'**
  String guestsPlusOneUnseatedNotice(String name);

  /// No description provided for @seatingSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} table} other{{count} tables}}, {unassigned} unassigned'**
  String seatingSummary(int count, int unassigned);

  /// No description provided for @seatingAddTable.
  ///
  /// In en, this message translates to:
  /// **'Add table'**
  String get seatingAddTable;

  /// No description provided for @seatingAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add table'**
  String get seatingAddDialogTitle;

  /// No description provided for @seatingTableNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get seatingTableNameLabel;

  /// No description provided for @seatingTableNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get seatingTableNameRequired;

  /// No description provided for @seatingCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get seatingCapacityLabel;

  /// No description provided for @seatingCapacityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get seatingCapacityRequired;

  /// No description provided for @seatingShapeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get seatingShapeLabel;

  /// No description provided for @seatingShapeRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get seatingShapeRound;

  /// No description provided for @seatingShapeRectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get seatingShapeRectangle;

  /// No description provided for @seatingSelectedBanner.
  ///
  /// In en, this message translates to:
  /// **'{name} selected — tap a seat.'**
  String seatingSelectedBanner(String name);

  /// No description provided for @seatingNoTablesYet.
  ///
  /// In en, this message translates to:
  /// **'No tables yet. Tap \"Add table\" to create one.'**
  String get seatingNoTablesYet;

  /// No description provided for @seatingSeatedCount.
  ///
  /// In en, this message translates to:
  /// **'{occupied} / {capacity} seated'**
  String seatingSeatedCount(int occupied, int capacity);

  /// No description provided for @seatingWithoutSeatNumberSuffix.
  ///
  /// In en, this message translates to:
  /// **' ({count} without a seat number)'**
  String seatingWithoutSeatNumberSuffix(int count);

  /// No description provided for @seatingDeleteTableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete table'**
  String get seatingDeleteTableTooltip;

  /// No description provided for @seatingDeleteTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete table?'**
  String get seatingDeleteTableTitle;

  /// No description provided for @seatingConfirmDeleteTable.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{label}\"? Any seated guests will become unassigned.'**
  String seatingConfirmDeleteTable(String label);

  /// No description provided for @seatingSeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Seat {seat}'**
  String seatingSeatLabel(int seat);

  /// No description provided for @seatingSeatFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get seatingSeatFree;

  /// No description provided for @seatingSeatReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved ({name}\'s +1)'**
  String seatingSeatReserved(String name);

  /// No description provided for @seatingOccupantDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seated at {table}, seat {seat}.'**
  String seatingOccupantDialogSubtitle(String table, int seat);

  /// No description provided for @seatingReassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get seatingReassign;

  /// No description provided for @seatingUnassign.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get seatingUnassign;

  /// No description provided for @seatingTapGuestFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap a guest first, then tap a seat.'**
  String get seatingTapGuestFirst;

  /// No description provided for @seatingUnassignedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unassigned ({count})'**
  String seatingUnassignedTitle(int count);

  /// No description provided for @seatingEveryoneSeated.
  ///
  /// In en, this message translates to:
  /// **'Everyone has a table.'**
  String get seatingEveryoneSeated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
