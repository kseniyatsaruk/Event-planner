// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Планировщик мероприятий';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonLogout => 'Выйти';

  @override
  String get commonLanguage => 'Язык';

  @override
  String get commonNotSet => 'Не указано';

  @override
  String get commonServerSettingsTooltip => 'Настройки сервера';

  @override
  String get commonErrorUnknown => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorInvalidCredentials => 'Неверный email или пароль.';

  @override
  String get errorEmailTaken => 'Аккаунт с таким email уже существует.';

  @override
  String get errorInvalidEmail => 'Введите корректный email.';

  @override
  String get errorInvalidPassword => 'Введите пароль.';

  @override
  String get errorInvalidName => 'Введите имя.';

  @override
  String get errorInvalidTitle => 'Введите название.';

  @override
  String get errorInvalidDate => 'Введите корректную дату.';

  @override
  String get errorInvalidStatus => 'Недопустимый статус.';

  @override
  String get errorInvalidRsvpStatus => 'Недопустимый статус RSVP.';

  @override
  String get errorInvalidLabel => 'Введите название стола.';

  @override
  String get errorInvalidShape => 'Недопустимая форма стола.';

  @override
  String get errorInvalidTable => 'Этот стол больше не существует.';

  @override
  String get errorInvalidSeat => 'Этот номер места недопустим для этого стола.';

  @override
  String get errorSeatTaken => 'Это место уже занято.';

  @override
  String get errorPlusOneNoRoom => 'Рядом нет свободного места для +1.';

  @override
  String get errorInvalidBody => 'Не удалось отправить запрос.';

  @override
  String get errorUnauthorized => 'Сессия истекла. Пожалуйста, войдите снова.';

  @override
  String get errorNotFound => 'Не найдено.';

  @override
  String get errorConnectionTimeout =>
      'Не удалось подключиться к серверу. Проверьте адрес в настройках и убедитесь, что телефон подключён к той же сети Wi-Fi, что и компьютер.';

  @override
  String get errorConnectionError =>
      'Не удалось подключиться к серверу. Проверьте адрес в настройках.';

  @override
  String get authLoginTitle => 'Вход';

  @override
  String get authRegisterTitle => 'Регистрация';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authNameLabel => 'Имя';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authRegisterButton => 'Зарегистрироваться';

  @override
  String get authNoAccountPrompt => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authEnterEmailError => 'Введите email';

  @override
  String get authEnterPasswordError => 'Введите пароль';

  @override
  String get authEnterNameError => 'Введите имя';

  @override
  String get settingsTitle => 'Настройки сервера';

  @override
  String get settingsDescription =>
      'Введите локальный сетевой адрес сервера Event Planner, например 192.168.1.23:8080. Узнайте IP компьютера с помощью ipconfig (Windows) или ifconfig (Mac/Linux) и убедитесь, что телефон подключён к той же сети Wi-Fi.';

  @override
  String get settingsAddressLabel => 'Адрес сервера';

  @override
  String get settingsAddressHint => '192.168.1.23:8080';

  @override
  String get settingsTestConnection => 'Проверить подключение';

  @override
  String get settingsTestSuccess => 'Подключение успешно.';

  @override
  String settingsTestServerError(int status) {
    return 'Сервер ответил со статусом $status.';
  }

  @override
  String get settingsTestFailure =>
      'Не удалось подключиться к серверу по этому адресу.';

  @override
  String get settingsEnterAddressFirst => 'Сначала введите адрес сервера.';

  @override
  String get settingsLanguageLabel => 'Язык';

  @override
  String get settingsLanguageSystem => 'Как на устройстве';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get eventsTitle => 'Мероприятия';

  @override
  String eventsTitleWithUser(String name) {
    return 'Мероприятия — $name';
  }

  @override
  String get eventsEmptyState =>
      'Мероприятий пока нет. Нажмите +, чтобы создать первое.';

  @override
  String get eventsCreateTooltip => 'Создать мероприятие';

  @override
  String get eventsCreateDialogTitle => 'Новое мероприятие';

  @override
  String get eventsNameFieldLabel => 'Название мероприятия';

  @override
  String get eventsCreateButton => 'Создать';

  @override
  String get overviewNameRequired => 'Введите название мероприятия';

  @override
  String get overviewDateLabel => 'Дата';

  @override
  String get overviewDescriptionLabel => 'Описание';

  @override
  String get overviewAddressLabel => 'Адрес';

  @override
  String get overviewLocationLabel => 'Местоположение';

  @override
  String get overviewLocationHint =>
      'Нажмите на карту, чтобы указать местоположение мероприятия.';

  @override
  String get overviewSavedMessage => 'Мероприятие сохранено.';

  @override
  String get navOverview => 'Обзор';

  @override
  String get navChecklist => 'Чек-лист';

  @override
  String get navVendors => 'Подрядчики';

  @override
  String get navGuests => 'Гости';

  @override
  String get navSeating => 'Рассадка';

  @override
  String get eventFallbackTitle => 'Мероприятие';

  @override
  String get checklistStatusTodo => 'Сделать';

  @override
  String get checklistStatusInProgress => 'В процессе';

  @override
  String get checklistStatusDone => 'Готово';

  @override
  String checklistSummary(int count, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count задачи · $done завершено',
      many: '$count задач · $done завершено',
      few: '$count задачи · $done завершено',
      one: '$count задача · $done завершено',
    );
    return '$_temp0';
  }

  @override
  String get checklistAddItem => 'Добавить задачу';

  @override
  String get checklistAddDialogTitle => 'Добавить задачу';

  @override
  String get checklistTitleLabel => 'Название';

  @override
  String get checklistTitleRequired => 'Введите название';

  @override
  String get checklistCategoryLabel => 'Категория';

  @override
  String get checklistDueDateLabel => 'Срок';

  @override
  String get checklistEmptyState => 'Задач пока нет — добавьте первую.';

  @override
  String get checklistDeleteItemTitle => 'Удалить задачу?';

  @override
  String checklistConfirmDelete(String title) {
    return 'Удалить «$title» из чек-листа?';
  }

  @override
  String get checklistChangeStatusTooltip => 'Изменить статус';

  @override
  String checklistDueLabel(String date) {
    return 'Срок: $date';
  }

  @override
  String get vendorsStatusContacted => 'Связались';

  @override
  String get vendorsStatusNegotiating => 'Переговоры';

  @override
  String get vendorsStatusConfirmed => 'Подтверждён';

  @override
  String get vendorsStatusPaid => 'Оплачено';

  @override
  String get vendorsStatusCancelled => 'Отменён';

  @override
  String vendorsSummary(int count, int confirmed) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подрядчика · $confirmed подтверждено',
      many: '$count подрядчиков · $confirmed подтверждено',
      few: '$count подрядчика · $confirmed подтверждено',
      one: '$count подрядчик · $confirmed подтверждён',
    );
    return '$_temp0';
  }

  @override
  String get vendorsAddVendor => 'Добавить подрядчика';

  @override
  String get vendorsAddDialogTitle => 'Добавить подрядчика';

  @override
  String get vendorsNameLabel => 'Название';

  @override
  String get vendorsNameRequired => 'Введите название';

  @override
  String get vendorsCategoryLabel => 'Категория';

  @override
  String get vendorsContactNameLabel => 'Контактное лицо';

  @override
  String get vendorsPhoneLabel => 'Телефон';

  @override
  String get vendorsPriceLabel => 'Цена';

  @override
  String get vendorsStatusLabel => 'Статус';

  @override
  String get vendorsEmptyState => 'Подрядчиков пока нет — добавьте первого.';

  @override
  String get vendorsDeleteVendorTitle => 'Удалить подрядчика?';

  @override
  String vendorsConfirmDelete(String name) {
    return 'Удалить «$name» из списка подрядчиков?';
  }

  @override
  String get vendorsDeleteTooltip => 'Удалить подрядчика';

  @override
  String get guestsRsvpPending => 'В ожидании';

  @override
  String get guestsRsvpInvited => 'Приглашён';

  @override
  String get guestsRsvpConfirmed => 'Подтверждён';

  @override
  String get guestsRsvpDeclined => 'Отклонён';

  @override
  String guestsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гостя',
      many: '$count гостей',
      few: '$count гостя',
      one: '$count гость',
    );
    return '$_temp0';
  }

  @override
  String get guestsAddGuest => 'Добавить гостя';

  @override
  String get guestsAddDialogTitle => 'Добавить гостя';

  @override
  String get guestsNameLabel => 'Имя';

  @override
  String get guestsNameRequired => 'Введите имя';

  @override
  String get guestsPhoneLabel => 'Телефон';

  @override
  String get guestsEmailLabel => 'Email';

  @override
  String get guestsRsvpStatusLabel => 'Статус RSVP';

  @override
  String get guestsPlusOneLabel => 'С сопровождающим';

  @override
  String get guestsEmptyState => 'Гостей пока нет — добавьте первого.';

  @override
  String get guestsDeleteGuestTitle => 'Удалить гостя?';

  @override
  String guestsConfirmDelete(String name) {
    return 'Удалить «$name» из списка гостей?';
  }

  @override
  String get guestsDeleteTooltip => 'Удалить гостя';

  @override
  String guestsPlusOneUnseatedNotice(String name) {
    return '«$name»: место за столом снято — рядом нет свободного места для +1.';
  }

  @override
  String seatingSummary(int count, int unassigned) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count стола',
      many: '$count столов',
      few: '$count стола',
      one: '$count стол',
    );
    return '$_temp0, $unassigned без места';
  }

  @override
  String get seatingAddTable => 'Добавить стол';

  @override
  String get seatingAddDialogTitle => 'Добавить стол';

  @override
  String get seatingTableNameLabel => 'Название';

  @override
  String get seatingTableNameRequired => 'Введите название';

  @override
  String get seatingCapacityLabel => 'Вместимость';

  @override
  String get seatingCapacityRequired => 'Введите положительное число';

  @override
  String get seatingShapeLabel => 'Форма';

  @override
  String get seatingShapeRound => 'Круглый';

  @override
  String get seatingShapeRectangle => 'Прямоугольный';

  @override
  String seatingSelectedBanner(String name) {
    return 'Гость «$name» выбран — нажмите на место.';
  }

  @override
  String get seatingNoTablesYet =>
      'Столов пока нет. Нажмите «Добавить стол», чтобы создать первый.';

  @override
  String seatingSeatedCount(int occupied, int capacity) {
    return '$occupied / $capacity занято мест';
  }

  @override
  String seatingWithoutSeatNumberSuffix(int count) {
    return ' ($count без номера места)';
  }

  @override
  String get seatingDeleteTableTooltip => 'Удалить стол';

  @override
  String get seatingDeleteTableTitle => 'Удалить стол?';

  @override
  String seatingConfirmDeleteTable(String label) {
    return 'Удалить «$label»? Все гости за этим столом будут откреплены.';
  }

  @override
  String seatingSeatLabel(int seat) {
    return 'Место $seat';
  }

  @override
  String get seatingSeatFree => 'Свободно';

  @override
  String seatingSeatReserved(String name) {
    return 'Забронировано для +1 «$name»';
  }

  @override
  String seatingOccupantDialogSubtitle(String table, int seat) {
    return 'За столом «$table», место $seat.';
  }

  @override
  String get seatingReassign => 'Пересадить';

  @override
  String get seatingUnassign => 'Открепить';

  @override
  String get seatingTapGuestFirst => 'Сначала выберите гостя, затем место.';

  @override
  String seatingUnassignedTitle(int count) {
    return 'Без места ($count)';
  }

  @override
  String get seatingEveryoneSeated => 'Все гости рассажены.';
}
