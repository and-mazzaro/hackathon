import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('it')];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'EcoQuest'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLearn.
  ///
  /// In it, this message translates to:
  /// **'Impara'**
  String get navLearn;

  /// No description provided for @navPet.
  ///
  /// In it, this message translates to:
  /// **'Cucciolo'**
  String get navPet;

  /// No description provided for @navProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get navProfile;

  /// No description provided for @levelLabel.
  ///
  /// In it, this message translates to:
  /// **'Livello {level}'**
  String levelLabel(int level);

  /// No description provided for @xpProgress.
  ///
  /// In it, this message translates to:
  /// **'{current} su {target} punti esperienza'**
  String xpProgress(int current, int target);

  /// No description provided for @coinsAmount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 moneta} other{{count} monete}}'**
  String coinsAmount(int count);

  /// No description provided for @ticketsAmount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 biglietto premio} other{{count} biglietti premio}}'**
  String ticketsAmount(int count);

  /// No description provided for @percentValue.
  ///
  /// In it, this message translates to:
  /// **'{percent} percento'**
  String percentValue(int percent);

  /// No description provided for @statSatiety.
  ///
  /// In it, this message translates to:
  /// **'Sazietà'**
  String get statSatiety;

  /// No description provided for @statHappiness.
  ///
  /// In it, this message translates to:
  /// **'Felicità'**
  String get statHappiness;

  /// No description provided for @statCleanliness.
  ///
  /// In it, this message translates to:
  /// **'Pulizia'**
  String get statCleanliness;

  /// No description provided for @comingSoon.
  ///
  /// In it, this message translates to:
  /// **'In arrivo'**
  String get comingSoon;

  /// No description provided for @homePetPreview.
  ///
  /// In it, this message translates to:
  /// **'Il tuo cucciolo, ancora nell\'uovo'**
  String get homePetPreview;

  /// No description provided for @homeActivitiesTitle.
  ///
  /// In it, this message translates to:
  /// **'Attività di oggi'**
  String get homeActivitiesTitle;

  /// No description provided for @homeQuizTitle.
  ///
  /// In it, this message translates to:
  /// **'Quiz del giorno'**
  String get homeQuizTitle;

  /// No description provided for @homeQuizSubtitle.
  ///
  /// In it, this message translates to:
  /// **'5 domande · circa 3 minuti'**
  String get homeQuizSubtitle;

  /// No description provided for @homeCleanupTitle.
  ///
  /// In it, this message translates to:
  /// **'Pulisci la stanza'**
  String get homeCleanupTitle;

  /// No description provided for @homeCleanupSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ricicla i rifiuti e guadagna monete'**
  String get homeCleanupSubtitle;

  /// No description provided for @loadingProgress.
  ///
  /// In it, this message translates to:
  /// **'Carico i tuoi progressi…'**
  String get loadingProgress;

  /// No description provided for @saveErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Non riesco a leggere i tuoi progressi'**
  String get saveErrorTitle;

  /// No description provided for @saveCorruptedBody.
  ///
  /// In it, this message translates to:
  /// **'Il salvataggio sembra danneggiato. Puoi riprovare oppure ricominciare da capo.'**
  String get saveCorruptedBody;

  /// No description provided for @saveNewerAppBody.
  ///
  /// In it, this message translates to:
  /// **'Questi progressi sono stati salvati da una versione più recente di EcoQuest. Aggiorna l\'app per continuare.'**
  String get saveNewerAppBody;

  /// No description provided for @saveUnknownErrorBody.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un problema imprevisto. Riprova tra poco.'**
  String get saveUnknownErrorBody;

  /// No description provided for @retryAction.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retryAction;

  /// No description provided for @startFreshAction.
  ///
  /// In it, this message translates to:
  /// **'Ricomincia da capo'**
  String get startFreshAction;

  /// No description provided for @debugRewardAction.
  ///
  /// In it, this message translates to:
  /// **'Ricompensa di prova (solo debug)'**
  String get debugRewardAction;

  /// No description provided for @learnTitle.
  ///
  /// In it, this message translates to:
  /// **'Impara giocando'**
  String get learnTitle;

  /// No description provided for @learnBody.
  ///
  /// In it, this message translates to:
  /// **'Qui arriveranno quiz, mini-giochi e curiosità sull\'ambiente.'**
  String get learnBody;

  /// No description provided for @petTitle.
  ///
  /// In it, this message translates to:
  /// **'La stanza del tuo cucciolo'**
  String get petTitle;

  /// No description provided for @petBody.
  ///
  /// In it, this message translates to:
  /// **'Qui potrai prenderti cura del tuo compagno e riciclare i rifiuti della sua stanza.'**
  String get petBody;

  /// No description provided for @profileTitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo profilo'**
  String get profileTitle;

  /// No description provided for @profileBody.
  ///
  /// In it, this message translates to:
  /// **'Qui troverai i tuoi interessi, i progressi e le impostazioni.'**
  String get profileBody;
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
      <String>['it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
