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

  /// No description provided for @onboardingStep.
  ///
  /// In it, this message translates to:
  /// **'Passo {step} di {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @backAction.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get backAction;

  /// No description provided for @nextAction.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get nextAction;

  /// No description provided for @skipAction.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get skipAction;

  /// No description provided for @finishAction.
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get finishAction;

  /// No description provided for @saveAction.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get saveAction;

  /// No description provided for @cancelAction.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancelAction;

  /// No description provided for @welcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Ti diamo il benvenuto in EcoQuest!'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In it, this message translates to:
  /// **'Impara a proteggere l\'ambiente giocando. Ogni quiz e ogni rifiuto riciclato aiutano il tuo cucciolo a schiudersi e a vivere in una stanza sempre più verde.'**
  String get welcomeBody;

  /// No description provided for @welcomePrivacy.
  ///
  /// In it, this message translates to:
  /// **'Non serve un account: i tuoi progressi vengono salvati su questo telefono.'**
  String get welcomePrivacy;

  /// No description provided for @welcomeStartAction.
  ///
  /// In it, this message translates to:
  /// **'Iniziamo'**
  String get welcomeStartAction;

  /// No description provided for @welcomeEggLabel.
  ///
  /// In it, this message translates to:
  /// **'Il tuo cucciolo, ancora nell\'uovo, ti aspetta'**
  String get welcomeEggLabel;

  /// No description provided for @interestsTitle.
  ///
  /// In it, this message translates to:
  /// **'Cosa ti interessa?'**
  String get interestsTitle;

  /// No description provided for @interestsBody.
  ///
  /// In it, this message translates to:
  /// **'Scegli gli argomenti che preferisci: li useremo per proporti quiz e curiosità. Potrai cambiarli quando vuoi dal profilo.'**
  String get interestsBody;

  /// No description provided for @interestsSelectedCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessun argomento scelto} =1{1 argomento scelto} other{{count} argomenti scelti}}'**
  String interestsSelectedCount(int count);

  /// No description provided for @interestsMinHint.
  ///
  /// In it, this message translates to:
  /// **'Scegline almeno uno per continuare.'**
  String get interestsMinHint;

  /// No description provided for @aboutTitle.
  ///
  /// In it, this message translates to:
  /// **'Parlaci un po\' di te'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In it, this message translates to:
  /// **'Entrambe le risposte sono facoltative. L\'età ci serve solo per scegliere domande adatte: non chiediamo la data di nascita.'**
  String get aboutBody;

  /// No description provided for @nicknameLabel.
  ///
  /// In it, this message translates to:
  /// **'Soprannome (facoltativo)'**
  String get nicknameLabel;

  /// No description provided for @nicknameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. EcoAle'**
  String get nicknameHint;

  /// No description provided for @nicknameHelper.
  ///
  /// In it, this message translates to:
  /// **'Non usare il tuo nome e cognome completi.'**
  String get nicknameHelper;

  /// No description provided for @ageRangeLabel.
  ///
  /// In it, this message translates to:
  /// **'Età (facoltativa)'**
  String get ageRangeLabel;

  /// No description provided for @ageRange13to15.
  ///
  /// In it, this message translates to:
  /// **'13–15 anni'**
  String get ageRange13to15;

  /// No description provided for @ageRange16to18.
  ///
  /// In it, this message translates to:
  /// **'16–18 anni'**
  String get ageRange16to18;

  /// No description provided for @ageRange19to22.
  ///
  /// In it, this message translates to:
  /// **'19–22 anni'**
  String get ageRange19to22;

  /// No description provided for @ageRange23to26.
  ///
  /// In it, this message translates to:
  /// **'23–26 anni'**
  String get ageRange23to26;

  /// No description provided for @ageRangeOver26.
  ///
  /// In it, this message translates to:
  /// **'27 anni o più'**
  String get ageRangeOver26;

  /// No description provided for @ageRangeNotSaid.
  ///
  /// In it, this message translates to:
  /// **'Preferisco non dirlo'**
  String get ageRangeNotSaid;

  /// No description provided for @topicRecycling.
  ///
  /// In it, this message translates to:
  /// **'Riciclo e rifiuti'**
  String get topicRecycling;

  /// No description provided for @topicClimate.
  ///
  /// In it, this message translates to:
  /// **'Clima'**
  String get topicClimate;

  /// No description provided for @topicOceans.
  ///
  /// In it, this message translates to:
  /// **'Oceani e vita marina'**
  String get topicOceans;

  /// No description provided for @topicBiodiversity.
  ///
  /// In it, this message translates to:
  /// **'Animali e biodiversità'**
  String get topicBiodiversity;

  /// No description provided for @topicForests.
  ///
  /// In it, this message translates to:
  /// **'Foreste ed ecosistemi'**
  String get topicForests;

  /// No description provided for @topicEnergy.
  ///
  /// In it, this message translates to:
  /// **'Energia rinnovabile'**
  String get topicEnergy;

  /// No description provided for @topicWater.
  ///
  /// In it, this message translates to:
  /// **'Risparmio d\'acqua'**
  String get topicWater;

  /// No description provided for @topicTransport.
  ///
  /// In it, this message translates to:
  /// **'Mobilità sostenibile'**
  String get topicTransport;

  /// No description provided for @topicConsumption.
  ///
  /// In it, this message translates to:
  /// **'Consumo responsabile'**
  String get topicConsumption;

  /// No description provided for @topicInnovation.
  ///
  /// In it, this message translates to:
  /// **'Innovazione green'**
  String get topicInnovation;

  /// No description provided for @profileGuestName.
  ///
  /// In it, this message translates to:
  /// **'Ospite'**
  String get profileGuestName;

  /// No description provided for @profileLevelLine.
  ///
  /// In it, this message translates to:
  /// **'Livello {level} · profilo su questo telefono'**
  String profileLevelLine(int level);

  /// No description provided for @profileAgeLine.
  ///
  /// In it, this message translates to:
  /// **'Età: {range}'**
  String profileAgeLine(String range);

  /// No description provided for @profileEditDetails.
  ///
  /// In it, this message translates to:
  /// **'Modifica soprannome ed età'**
  String get profileEditDetails;

  /// No description provided for @profileEditTitle.
  ///
  /// In it, this message translates to:
  /// **'Soprannome ed età'**
  String get profileEditTitle;

  /// No description provided for @profileInterestsTitle.
  ///
  /// In it, this message translates to:
  /// **'I tuoi interessi'**
  String get profileInterestsTitle;

  /// No description provided for @profileInterestsBody.
  ///
  /// In it, this message translates to:
  /// **'Tocca un argomento per attivarlo o disattivarlo. Le modifiche vengono salvate subito e i tuoi progressi restano invariati.'**
  String get profileInterestsBody;

  /// No description provided for @profileKeepOneInterest.
  ///
  /// In it, this message translates to:
  /// **'Tieni almeno un interesse.'**
  String get profileKeepOneInterest;

  /// No description provided for @profileDataTitle.
  ///
  /// In it, this message translates to:
  /// **'I tuoi dati'**
  String get profileDataTitle;

  /// No description provided for @profileDataBody.
  ///
  /// In it, this message translates to:
  /// **'Non serve un account. Soprannome, età, interessi e progressi sono salvati su questo telefono. EcoQuest non usa la tua posizione e non chiede la data di nascita.'**
  String get profileDataBody;
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
