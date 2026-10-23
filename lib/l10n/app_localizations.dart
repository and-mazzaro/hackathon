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
  /// **'Rispondi ai quiz per guadagnare XP e far crescere il tuo cucciolo.'**
  String get learnBody;

  /// No description provided for @learnForYouTitle.
  ///
  /// In it, this message translates to:
  /// **'Quiz per te'**
  String get learnForYouTitle;

  /// No description provided for @learnForYouBody.
  ///
  /// In it, this message translates to:
  /// **'5 domande sui tuoi argomenti preferiti, dalla più facile alla più difficile.'**
  String get learnForYouBody;

  /// No description provided for @learnForYouAction.
  ///
  /// In it, this message translates to:
  /// **'Gioca'**
  String get learnForYouAction;

  /// No description provided for @learnTopicsTitle.
  ///
  /// In it, this message translates to:
  /// **'Quiz per argomento'**
  String get learnTopicsTitle;

  /// No description provided for @learnForYouBadge.
  ///
  /// In it, this message translates to:
  /// **'Per te'**
  String get learnForYouBadge;

  /// No description provided for @learnQuestionCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Domande in arrivo} =1{1 domanda} other{{count} domande}}'**
  String learnQuestionCount(int count);

  /// No description provided for @learnTopicStats.
  ///
  /// In it, this message translates to:
  /// **'Risposte giuste: {correct} su {answered}'**
  String learnTopicStats(int correct, int answered);

  /// No description provided for @learnQuizzesCompleted.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Non hai ancora completato nessun quiz} =1{1 quiz completato} other{{count} quiz completati}}'**
  String learnQuizzesCompleted(int count);

  /// No description provided for @learnContentError.
  ///
  /// In it, this message translates to:
  /// **'Non riesco a caricare le domande. Riavvia l\'app; se il problema continua, avvisa il team.'**
  String get learnContentError;

  /// No description provided for @learnPlayNowTitle.
  ///
  /// In it, this message translates to:
  /// **'Gioca subito'**
  String get learnPlayNowTitle;

  /// No description provided for @learnPlayNowBody.
  ///
  /// In it, this message translates to:
  /// **'5 domande a sorpresa, prima i tuoi argomenti preferiti. Più risposte giuste di fila, più XP!'**
  String get learnPlayNowBody;

  /// No description provided for @learnPlayNowAction.
  ///
  /// In it, this message translates to:
  /// **'Tocca per iniziare'**
  String get learnPlayNowAction;

  /// No description provided for @learnLearnedTotal.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{Nessuna domanda imparata} =1{1 domanda imparata} other{{count} domande imparate}}'**
  String learnLearnedTotal(int count);

  /// No description provided for @learnTopicLearned.
  ///
  /// In it, this message translates to:
  /// **'{learned} su {total} imparate'**
  String learnTopicLearned(int learned, int total);

  /// No description provided for @learnTopicsHint.
  ///
  /// In it, this message translates to:
  /// **'Oppure scegli un argomento'**
  String get learnTopicsHint;

  /// No description provided for @quizMixedTitle.
  ///
  /// In it, this message translates to:
  /// **'Quiz misto'**
  String get quizMixedTitle;

  /// No description provided for @quizQuestionOf.
  ///
  /// In it, this message translates to:
  /// **'Domanda {current} di {total}'**
  String quizQuestionOf(int current, int total);

  /// No description provided for @quizExit.
  ///
  /// In it, this message translates to:
  /// **'Esci dal quiz'**
  String get quizExit;

  /// No description provided for @quizExitTitle.
  ///
  /// In it, this message translates to:
  /// **'Vuoi uscire dal quiz?'**
  String get quizExitTitle;

  /// No description provided for @quizExitBody.
  ///
  /// In it, this message translates to:
  /// **'Le risposte di questo quiz non verranno salvate e non riceverai XP.'**
  String get quizExitBody;

  /// No description provided for @quizExitConfirm.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get quizExitConfirm;

  /// No description provided for @quizExitStay.
  ///
  /// In it, this message translates to:
  /// **'Continua il quiz'**
  String get quizExitStay;

  /// No description provided for @difficultyEasy.
  ///
  /// In it, this message translates to:
  /// **'Facile'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In it, this message translates to:
  /// **'Media'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In it, this message translates to:
  /// **'Difficile'**
  String get difficultyHard;

  /// No description provided for @quizStreak.
  ///
  /// In it, this message translates to:
  /// **'Serie di {count}'**
  String quizStreak(int count);

  /// No description provided for @quizCorrect.
  ///
  /// In it, this message translates to:
  /// **'Corretto!'**
  String get quizCorrect;

  /// No description provided for @quizWrong.
  ///
  /// In it, this message translates to:
  /// **'Non proprio.'**
  String get quizWrong;

  /// No description provided for @quizCorrectAnswerIs.
  ///
  /// In it, this message translates to:
  /// **'La risposta giusta è: {answer}'**
  String quizCorrectAnswerIs(String answer);

  /// No description provided for @quizOptionCorrect.
  ///
  /// In it, this message translates to:
  /// **'risposta giusta'**
  String get quizOptionCorrect;

  /// No description provided for @quizOptionWrong.
  ///
  /// In it, this message translates to:
  /// **'risposta sbagliata'**
  String get quizOptionWrong;

  /// No description provided for @quizSource.
  ///
  /// In it, this message translates to:
  /// **'Fonte: {name}'**
  String quizSource(String name);

  /// No description provided for @quizSourceVerified.
  ///
  /// In it, this message translates to:
  /// **'Verificata dal team il {date}'**
  String quizSourceVerified(String date);

  /// No description provided for @quizSourceCopyHint.
  ///
  /// In it, this message translates to:
  /// **'Tieni premuto l\'indirizzo per copiarlo.'**
  String get quizSourceCopyHint;

  /// No description provided for @quizSeeResult.
  ///
  /// In it, this message translates to:
  /// **'Vedi il risultato'**
  String get quizSeeResult;

  /// No description provided for @quizNotEnough.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono ancora domande per questo quiz.'**
  String get quizNotEnough;

  /// No description provided for @quizResultScore.
  ///
  /// In it, this message translates to:
  /// **'{correct} su {total} risposte giuste'**
  String quizResultScore(int correct, int total);

  /// No description provided for @quizResultPerfect.
  ///
  /// In it, this message translates to:
  /// **'Perfetto! Hai risposto bene a tutto.'**
  String get quizResultPerfect;

  /// No description provided for @quizResultGood.
  ///
  /// In it, this message translates to:
  /// **'Ottimo lavoro!'**
  String get quizResultGood;

  /// No description provided for @quizResultKeepGoing.
  ///
  /// In it, this message translates to:
  /// **'Ogni risposta ti insegna qualcosa: riprova!'**
  String get quizResultKeepGoing;

  /// No description provided for @quizResultXp.
  ///
  /// In it, this message translates to:
  /// **'+{xp} XP'**
  String quizResultXp(int xp);

  /// No description provided for @quizResultBestStreak.
  ///
  /// In it, this message translates to:
  /// **'Serie migliore: {count}'**
  String quizResultBestStreak(int count);

  /// No description provided for @quizResultNewlyLearned.
  ///
  /// In it, this message translates to:
  /// **'Cose nuove imparate: {count}'**
  String quizResultNewlyLearned(int count);

  /// No description provided for @quizResultRepeatNote.
  ///
  /// In it, this message translates to:
  /// **'Le domande che conoscevi già valgono meno XP: prova un altro argomento per guadagnarne di più!'**
  String get quizResultRepeatNote;

  /// No description provided for @quizLevelUp.
  ///
  /// In it, this message translates to:
  /// **'Hai raggiunto il livello {level}!'**
  String quizLevelUp(int level);

  /// No description provided for @quizPlayAgain.
  ///
  /// In it, this message translates to:
  /// **'Gioca ancora'**
  String get quizPlayAgain;

  /// No description provided for @quizClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get quizClose;

  /// No description provided for @petStageEgg.
  ///
  /// In it, this message translates to:
  /// **'Uovo'**
  String get petStageEgg;

  /// No description provided for @petStageBaby.
  ///
  /// In it, this message translates to:
  /// **'Cucciolo'**
  String get petStageBaby;

  /// No description provided for @petStageYoung.
  ///
  /// In it, this message translates to:
  /// **'Giovane'**
  String get petStageYoung;

  /// No description provided for @petStageAdult.
  ///
  /// In it, this message translates to:
  /// **'Adulto'**
  String get petStageAdult;

  /// No description provided for @petMoodHappy.
  ///
  /// In it, this message translates to:
  /// **'Di buon umore'**
  String get petMoodHappy;

  /// No description provided for @petMoodOk.
  ///
  /// In it, this message translates to:
  /// **'Tutto ok'**
  String get petMoodOk;

  /// No description provided for @petMoodSad.
  ///
  /// In it, this message translates to:
  /// **'Un po\' giù'**
  String get petMoodSad;

  /// No description provided for @petEggName.
  ///
  /// In it, this message translates to:
  /// **'Uovo misterioso'**
  String get petEggName;

  /// No description provided for @petSemantics.
  ///
  /// In it, this message translates to:
  /// **'{name}, {stage}, {mood}'**
  String petSemantics(String name, String stage, String mood);

  /// No description provided for @petSadHint.
  ///
  /// In it, this message translates to:
  /// **'Non succede niente di grave: prenditene cura e tornerà di buon umore.'**
  String get petSadHint;

  /// No description provided for @careFeed.
  ///
  /// In it, this message translates to:
  /// **'Dai da mangiare'**
  String get careFeed;

  /// No description provided for @carePlay.
  ///
  /// In it, this message translates to:
  /// **'Gioca insieme'**
  String get carePlay;

  /// No description provided for @careClean.
  ///
  /// In it, this message translates to:
  /// **'Fai il bagnetto'**
  String get careClean;

  /// No description provided for @careFedMessage.
  ///
  /// In it, this message translates to:
  /// **'Gnam! {name} ha mangiato con gusto.'**
  String careFedMessage(String name);

  /// No description provided for @carePlayedMessage.
  ///
  /// In it, this message translates to:
  /// **'Che divertimento per {name}!'**
  String carePlayedMessage(String name);

  /// No description provided for @careCleanedMessage.
  ///
  /// In it, this message translates to:
  /// **'Bagnetto fatto: {name} ora profuma di fresco!'**
  String careCleanedMessage(String name);

  /// No description provided for @careAlreadyFull.
  ///
  /// In it, this message translates to:
  /// **'Già al massimo: {name} sta benissimo così!'**
  String careAlreadyFull(String name);

  /// No description provided for @eggHatchProgress.
  ///
  /// In it, this message translates to:
  /// **'Si schiuderà al livello {level}: ti mancano {xp} XP.'**
  String eggHatchProgress(int level, int xp);

  /// No description provided for @eggHatchHint.
  ///
  /// In it, this message translates to:
  /// **'Completa i quiz in Impara per guadagnare XP e farlo schiudere!'**
  String get eggHatchHint;

  /// No description provided for @eggStroke.
  ///
  /// In it, this message translates to:
  /// **'Accarezza l\'uovo'**
  String get eggStroke;

  /// No description provided for @eggStrokeMessage.
  ///
  /// In it, this message translates to:
  /// **'L\'uovo si è mosso un pochino…'**
  String get eggStrokeMessage;

  /// No description provided for @eggReady.
  ///
  /// In it, this message translates to:
  /// **'L\'uovo si muove: è pronto a schiudersi!'**
  String get eggReady;

  /// No description provided for @eggHatchAction.
  ///
  /// In it, this message translates to:
  /// **'Fai schiudere l\'uovo'**
  String get eggHatchAction;

  /// No description provided for @hatchTitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo cucciolo è nato!'**
  String get hatchTitle;

  /// No description provided for @hatchBody.
  ///
  /// In it, this message translates to:
  /// **'Scegli un nome (facoltativo). Crescerà insieme a te, quiz dopo quiz.'**
  String get hatchBody;

  /// No description provided for @petNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome del cucciolo (facoltativo)'**
  String get petNameLabel;

  /// No description provided for @petNameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Ecò'**
  String get petNameHint;

  /// No description provided for @hatchConfirm.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get hatchConfirm;

  /// No description provided for @hatchedMessage.
  ///
  /// In it, this message translates to:
  /// **'Ecco {name}, il tuo nuovo cucciolo!'**
  String hatchedMessage(String name);

  /// No description provided for @growReady.
  ///
  /// In it, this message translates to:
  /// **'È il momento di crescere per {name}!'**
  String growReady(String name);

  /// No description provided for @growAction.
  ///
  /// In it, this message translates to:
  /// **'Fai crescere'**
  String get growAction;

  /// No description provided for @grownMessage.
  ///
  /// In it, this message translates to:
  /// **'{name} ora è {stage}!'**
  String grownMessage(String name, String stage);

  /// No description provided for @nextGrowth.
  ///
  /// In it, this message translates to:
  /// **'Prossima crescita al livello {level}.'**
  String nextGrowth(int level);

  /// No description provided for @quizPetHappier.
  ///
  /// In it, this message translates to:
  /// **'Anche il tuo cucciolo è più felice grazie al quiz!'**
  String get quizPetHappier;

  /// No description provided for @binPlasticMetal.
  ///
  /// In it, this message translates to:
  /// **'Plastica e metalli'**
  String get binPlasticMetal;

  /// No description provided for @binPaper.
  ///
  /// In it, this message translates to:
  /// **'Carta e cartone'**
  String get binPaper;

  /// No description provided for @binOrganic.
  ///
  /// In it, this message translates to:
  /// **'Organico'**
  String get binOrganic;

  /// No description provided for @binGlass.
  ///
  /// In it, this message translates to:
  /// **'Vetro'**
  String get binGlass;

  /// No description provided for @binResidual.
  ///
  /// In it, this message translates to:
  /// **'Indifferenziato'**
  String get binResidual;

  /// No description provided for @cleanupProgress.
  ///
  /// In it, this message translates to:
  /// **'{done} di {total} sistemati'**
  String cleanupProgress(int done, int total);

  /// No description provided for @cleanupLocalRules.
  ///
  /// In it, this message translates to:
  /// **'Qui trovi le indicazioni generali: le regole possono cambiare da Comune a Comune, controlla sempre quelle del tuo.'**
  String get cleanupLocalRules;

  /// No description provided for @cleanupHowTo.
  ///
  /// In it, this message translates to:
  /// **'Tocca un rifiuto e poi il bidone giusto. Puoi anche trascinarlo sul bidone.'**
  String get cleanupHowTo;

  /// No description provided for @cleanupSelected.
  ///
  /// In it, this message translates to:
  /// **'Selezionato: {name}. Ora tocca un bidone.'**
  String cleanupSelected(String name);

  /// No description provided for @cleanupPickFirst.
  ///
  /// In it, this message translates to:
  /// **'Prima scegli un rifiuto nella stanza.'**
  String get cleanupPickFirst;

  /// No description provided for @cleanupCorrect.
  ///
  /// In it, this message translates to:
  /// **'Giusto! {name} va in: {bin}.'**
  String cleanupCorrect(String name, String bin);

  /// No description provided for @cleanupWrong.
  ///
  /// In it, this message translates to:
  /// **'Quasi! {name} va in: {bin}.'**
  String cleanupWrong(String name, String bin);

  /// No description provided for @cleanupComboBonus.
  ///
  /// In it, this message translates to:
  /// **'Combo di {count}: monete bonus!'**
  String cleanupComboBonus(int count);

  /// No description provided for @cleanupCombo.
  ///
  /// In it, this message translates to:
  /// **'Combo x{count}'**
  String cleanupCombo(int count);

  /// No description provided for @cleanupExit.
  ///
  /// In it, this message translates to:
  /// **'Esci dalla pulizia'**
  String get cleanupExit;

  /// No description provided for @cleanupExitTitle.
  ///
  /// In it, this message translates to:
  /// **'Vuoi interrompere la pulizia?'**
  String get cleanupExitTitle;

  /// No description provided for @cleanupExitBody.
  ///
  /// In it, this message translates to:
  /// **'I rifiuti già sistemati non verranno salvati e non riceverai monete.'**
  String get cleanupExitBody;

  /// No description provided for @cleanupExitStay.
  ///
  /// In it, this message translates to:
  /// **'Continua a pulire'**
  String get cleanupExitStay;

  /// No description provided for @cleanupNoItems.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono ancora rifiuti da sistemare.'**
  String get cleanupNoItems;

  /// No description provided for @cleanupResultScore.
  ///
  /// In it, this message translates to:
  /// **'{correct} rifiuti su {total} nel bidone giusto'**
  String cleanupResultScore(int correct, int total);

  /// No description provided for @cleanupResultCoins.
  ///
  /// In it, this message translates to:
  /// **'+{coins} monete'**
  String cleanupResultCoins(int coins);

  /// No description provided for @cleanupResultBestCombo.
  ///
  /// In it, this message translates to:
  /// **'Combo migliore: {count}'**
  String cleanupResultBestCombo(int count);

  /// No description provided for @cleanupRoomClean.
  ///
  /// In it, this message translates to:
  /// **'La stanza è pulita!'**
  String get cleanupRoomClean;

  /// No description provided for @levelUpTickets.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{Premio: 1 biglietto per la ruota dell\'Armadio!} other{Premio: {count} biglietti per la ruota dell\'Armadio!}}'**
  String levelUpTickets(int count);

  /// No description provided for @wardrobeTitle.
  ///
  /// In it, this message translates to:
  /// **'Armadio'**
  String get wardrobeTitle;

  /// No description provided for @wardrobeOpenFromPet.
  ///
  /// In it, this message translates to:
  /// **'Apri l\'armadio'**
  String get wardrobeOpenFromPet;

  /// No description provided for @homeWardrobeTitle.
  ///
  /// In it, this message translates to:
  /// **'Armadio del cucciolo'**
  String get homeWardrobeTitle;

  /// No description provided for @homeWardrobeSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Vestiti e accessori con monete e biglietti'**
  String get homeWardrobeSubtitle;

  /// No description provided for @wardrobeEggNote.
  ///
  /// In it, this message translates to:
  /// **'Gli oggetti si vedranno addosso al cucciolo quando l\'uovo si schiude. Puoi già raccoglierli!'**
  String get wardrobeEggNote;

  /// No description provided for @wardrobeContentError.
  ///
  /// In it, this message translates to:
  /// **'Non riesco a caricare gli oggetti. Riprova più tardi.'**
  String get wardrobeContentError;

  /// No description provided for @slotHead.
  ///
  /// In it, this message translates to:
  /// **'Testa'**
  String get slotHead;

  /// No description provided for @slotFace.
  ///
  /// In it, this message translates to:
  /// **'Viso'**
  String get slotFace;

  /// No description provided for @slotNeck.
  ///
  /// In it, this message translates to:
  /// **'Collo'**
  String get slotNeck;

  /// No description provided for @slotPaws.
  ///
  /// In it, this message translates to:
  /// **'Zampe'**
  String get slotPaws;

  /// No description provided for @rarityCommon.
  ///
  /// In it, this message translates to:
  /// **'Comune'**
  String get rarityCommon;

  /// No description provided for @rarityUncommon.
  ///
  /// In it, this message translates to:
  /// **'Non comune'**
  String get rarityUncommon;

  /// No description provided for @rarityRare.
  ///
  /// In it, this message translates to:
  /// **'Raro'**
  String get rarityRare;

  /// No description provided for @rarityEpic.
  ///
  /// In it, this message translates to:
  /// **'Epico'**
  String get rarityEpic;

  /// No description provided for @rarityLegendary.
  ///
  /// In it, this message translates to:
  /// **'Leggendario'**
  String get rarityLegendary;

  /// No description provided for @rarityMythic.
  ///
  /// In it, this message translates to:
  /// **'Mitico'**
  String get rarityMythic;

  /// No description provided for @rarityCommonPlural.
  ///
  /// In it, this message translates to:
  /// **'comuni'**
  String get rarityCommonPlural;

  /// No description provided for @rarityUncommonPlural.
  ///
  /// In it, this message translates to:
  /// **'non comuni'**
  String get rarityUncommonPlural;

  /// No description provided for @rarityRarePlural.
  ///
  /// In it, this message translates to:
  /// **'rari'**
  String get rarityRarePlural;

  /// No description provided for @rarityEpicPlural.
  ///
  /// In it, this message translates to:
  /// **'epici'**
  String get rarityEpicPlural;

  /// No description provided for @rarityLegendaryPlural.
  ///
  /// In it, this message translates to:
  /// **'leggendari'**
  String get rarityLegendaryPlural;

  /// No description provided for @rarityMythicPlural.
  ///
  /// In it, this message translates to:
  /// **'mitici'**
  String get rarityMythicPlural;

  /// No description provided for @listLastItem.
  ///
  /// In it, this message translates to:
  /// **'{items} e {last}'**
  String listLastItem(String items, String last);

  /// No description provided for @rollTitle.
  ///
  /// In it, this message translates to:
  /// **'Ruota dei premi'**
  String get rollTitle;

  /// No description provided for @rollBody.
  ///
  /// In it, this message translates to:
  /// **'Usa un biglietto per ricevere un oggetto a sorpresa. Queste sono le probabilità:'**
  String get rollBody;

  /// No description provided for @rollOddsLine.
  ///
  /// In it, this message translates to:
  /// **'{rarity}: {percent}%'**
  String rollOddsLine(String rarity, int percent);

  /// No description provided for @rollOddsSemantics.
  ///
  /// In it, this message translates to:
  /// **'Probabilità: {odds}'**
  String rollOddsSemantics(String odds);

  /// No description provided for @rollOddsSpokenItem.
  ///
  /// In it, this message translates to:
  /// **'{rarity} {percent} percento'**
  String rollOddsSpokenItem(String rarity, int percent);

  /// No description provided for @rollDuplicateRule.
  ///
  /// In it, this message translates to:
  /// **'Se esce un oggetto che hai già, ricevi monete al suo posto: {refunds}.'**
  String rollDuplicateRule(String refunds);

  /// No description provided for @rollRefundItem.
  ///
  /// In it, this message translates to:
  /// **'{rarity} {coins}'**
  String rollRefundItem(String rarity, int coins);

  /// No description provided for @rollAction.
  ///
  /// In it, this message translates to:
  /// **'Usa 1 biglietto'**
  String get rollAction;

  /// No description provided for @rollNoTickets.
  ///
  /// In it, this message translates to:
  /// **'Non hai biglietti. Li guadagni salendo di livello, oppure puoi comprarne uno.'**
  String get rollNoTickets;

  /// No description provided for @buyTicketAction.
  ///
  /// In it, this message translates to:
  /// **'Compra un biglietto ({price} monete)'**
  String buyTicketAction(int price);

  /// No description provided for @ticketBought.
  ///
  /// In it, this message translates to:
  /// **'Hai comprato un biglietto premio!'**
  String get ticketBought;

  /// No description provided for @rollRevealNew.
  ///
  /// In it, this message translates to:
  /// **'Nuovo oggetto!'**
  String get rollRevealNew;

  /// No description provided for @rollRevealDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Ce l\'hai già'**
  String get rollRevealDuplicate;

  /// No description provided for @rollRevealSpecial.
  ///
  /// In it, this message translates to:
  /// **'{rarity}!'**
  String rollRevealSpecial(String rarity);

  /// No description provided for @rollRefund.
  ///
  /// In it, this message translates to:
  /// **'Al suo posto ricevi {coins} monete.'**
  String rollRefund(int coins);

  /// No description provided for @rollWearNow.
  ///
  /// In it, this message translates to:
  /// **'Indossa ora'**
  String get rollWearNow;

  /// No description provided for @rollClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get rollClose;

  /// No description provided for @shopTitle.
  ///
  /// In it, this message translates to:
  /// **'Negozio'**
  String get shopTitle;

  /// No description provided for @shopRollOnlyNote.
  ///
  /// In it, this message translates to:
  /// **'Gli oggetti {rarities} si trovano solo nella ruota dei premi.'**
  String shopRollOnlyNote(String rarities);

  /// No description provided for @shopAllOwned.
  ///
  /// In it, this message translates to:
  /// **'Hai già tutti gli oggetti del negozio!'**
  String get shopAllOwned;

  /// No description provided for @shopBuyAction.
  ///
  /// In it, this message translates to:
  /// **'Compra ({price} monete)'**
  String shopBuyAction(int price);

  /// No description provided for @shopNotEnoughCoins.
  ///
  /// In it, this message translates to:
  /// **'Ti servono altre {missing} monete. Le guadagni pulendo la stanza.'**
  String shopNotEnoughCoins(int missing);

  /// No description provided for @itemBought.
  ///
  /// In it, this message translates to:
  /// **'Hai comprato: {name}!'**
  String itemBought(String name);

  /// No description provided for @itemDetails.
  ///
  /// In it, this message translates to:
  /// **'{rarity} · {slot}'**
  String itemDetails(String rarity, String slot);

  /// No description provided for @myItemsTitle.
  ///
  /// In it, this message translates to:
  /// **'I miei oggetti'**
  String get myItemsTitle;

  /// No description provided for @myItemsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora oggetti. Prova la ruota o il negozio!'**
  String get myItemsEmpty;

  /// No description provided for @equipAction.
  ///
  /// In it, this message translates to:
  /// **'Indossa'**
  String get equipAction;

  /// No description provided for @unequipAction.
  ///
  /// In it, this message translates to:
  /// **'Togli'**
  String get unequipAction;

  /// No description provided for @petWearsItem.
  ///
  /// In it, this message translates to:
  /// **'{pet} indossa: {item}'**
  String petWearsItem(String pet, String item);

  /// No description provided for @petTookOffItem.
  ///
  /// In it, this message translates to:
  /// **'{pet} ha tolto: {item}'**
  String petTookOffItem(String pet, String item);

  /// No description provided for @cleanupPetCleaner.
  ///
  /// In it, this message translates to:
  /// **'La stanza è in ordine e anche il tuo cucciolo è più pulito!'**
  String get cleanupPetCleaner;

  /// No description provided for @cleanupRepeatNote.
  ///
  /// In it, this message translates to:
  /// **'I rifiuti che sapevi già sistemare valgono meno monete: le combo invece valgono sempre!'**
  String get cleanupRepeatNote;

  /// No description provided for @cleanupOpenFromPet.
  ///
  /// In it, this message translates to:
  /// **'Pulisci la stanza'**
  String get cleanupOpenFromPet;

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

  /// No description provided for @comebackTitle.
  ///
  /// In it, this message translates to:
  /// **'Mi sei mancato!'**
  String get comebackTitle;

  /// No description provided for @comebackBody.
  ///
  /// In it, this message translates to:
  /// **'Che bello rivederti. Ripartiamo con calma, senza fretta.'**
  String get comebackBody;

  /// No description provided for @comebackEggBody.
  ///
  /// In it, this message translates to:
  /// **'L\'uovo è rimasto al calduccio. Che bello rivederti: ripartiamo con calma.'**
  String get comebackEggBody;

  /// No description provided for @comebackSuggestCare.
  ///
  /// In it, this message translates to:
  /// **'Idea facile: fai una coccola al cucciolo'**
  String get comebackSuggestCare;

  /// No description provided for @comebackSuggestCleanup.
  ///
  /// In it, this message translates to:
  /// **'Idea facile: un giro di Pulisci la stanza'**
  String get comebackSuggestCleanup;

  /// No description provided for @comebackBonusAction.
  ///
  /// In it, this message translates to:
  /// **'Prendi il regalo: +{coins} monete'**
  String comebackBonusAction(int coins);

  /// No description provided for @comebackBonusClaimed.
  ///
  /// In it, this message translates to:
  /// **'Regalo preso! Che bello giocare di nuovo insieme.'**
  String get comebackBonusClaimed;

  /// No description provided for @reminderTitle.
  ///
  /// In it, this message translates to:
  /// **'Promemoria giornaliero'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In it, this message translates to:
  /// **'Se vuoi, EcoQuest può mandarti un solo avviso al giorno, all\'ora che scegli tu. Il promemoria resta su questo telefono e puoi spegnerlo quando vuoi.'**
  String get reminderBody;

  /// No description provided for @reminderSwitch.
  ///
  /// In it, this message translates to:
  /// **'Ricordamelo ogni giorno'**
  String get reminderSwitch;

  /// No description provided for @reminderTime.
  ///
  /// In it, this message translates to:
  /// **'Ora del promemoria: {time}'**
  String reminderTime(String time);

  /// No description provided for @reminderChangeTime.
  ///
  /// In it, this message translates to:
  /// **'Cambia ora'**
  String get reminderChangeTime;

  /// No description provided for @reminderPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Le notifiche sono bloccate sul telefono, quindi il promemoria non arriverà. Il gioco funziona lo stesso.'**
  String get reminderPermissionDenied;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In it, this message translates to:
  /// **'{pet} ti aspetta!'**
  String reminderNotificationTitle(String pet);

  /// No description provided for @reminderNotificationBody.
  ///
  /// In it, this message translates to:
  /// **'Hai 2 minuti? C\'è una nuova scoperta su {topic}.'**
  String reminderNotificationBody(String topic);

  /// No description provided for @reminderNotificationBodyGeneric.
  ///
  /// In it, this message translates to:
  /// **'Hai 2 minuti? Vieni a scoprire qualcosa di nuovo sulla natura.'**
  String get reminderNotificationBodyGeneric;

  /// No description provided for @reminderPetFallback.
  ///
  /// In it, this message translates to:
  /// **'Il tuo cucciolo'**
  String get reminderPetFallback;

  /// No description provided for @activityDataTitle.
  ///
  /// In it, this message translates to:
  /// **'La tua attività'**
  String get activityDataTitle;

  /// No description provided for @activityDataBody.
  ///
  /// In it, this message translates to:
  /// **'Per capire quando darti una mano, EcoQuest conta sul telefono quante volte giochi e quante risposte indovini negli ultimi 14 giorni. Niente posizione, niente Wi-Fi, niente dati inviati.'**
  String get activityDataBody;

  /// No description provided for @activityClearAction.
  ///
  /// In it, this message translates to:
  /// **'Cancella la mia attività'**
  String get activityClearAction;

  /// No description provided for @activityClearConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Cancellare la tua attività?'**
  String get activityClearConfirmTitle;

  /// No description provided for @activityClearConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Cancelliamo il registro degli ultimi giorni e spegniamo il promemoria. Livello, monete, cucciolo e oggetti restano come sono.'**
  String get activityClearConfirmBody;

  /// No description provided for @activityClearConfirm.
  ///
  /// In it, this message translates to:
  /// **'Cancella'**
  String get activityClearConfirm;

  /// No description provided for @activityClearCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get activityClearCancel;

  /// No description provided for @activityCleared.
  ///
  /// In it, this message translates to:
  /// **'Attività cancellata.'**
  String get activityCleared;

  /// No description provided for @introProfileButton.
  ///
  /// In it, this message translates to:
  /// **'Guarda l\'introduzione'**
  String get introProfileButton;

  /// No description provided for @introSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get introSkip;

  /// No description provided for @introSkipLabel.
  ///
  /// In it, this message translates to:
  /// **'Salta l\'introduzione'**
  String get introSkipLabel;

  /// No description provided for @introLogo.
  ///
  /// In it, this message translates to:
  /// **'LAIQUA'**
  String get introLogo;

  /// No description provided for @introSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva il pianeta, un gioco alla volta'**
  String get introSubtitle;

  /// No description provided for @introPressStart.
  ///
  /// In it, this message translates to:
  /// **'Tocca per iniziare'**
  String get introPressStart;

  /// No description provided for @introNext.
  ///
  /// In it, this message translates to:
  /// **'Tocca per continuare'**
  String get introNext;

  /// No description provided for @introLine1.
  ///
  /// In it, this message translates to:
  /// **'Ciao! Benvenuto nel mondo di Laiqua!'**
  String get introLine1;

  /// No description provided for @introLine2.
  ///
  /// In it, this message translates to:
  /// **'Io sono Laiqua, una lontra. Il nostro pianeta ha bisogno di aiuto!'**
  String get introLine2;

  /// No description provided for @introLine3.
  ///
  /// In it, this message translates to:
  /// **'Rispondi ai quiz e scopri come proteggere la natura.'**
  String get introLine3;

  /// No description provided for @introLine4.
  ///
  /// In it, this message translates to:
  /// **'Impara a dividere i rifiuti e rimetti in ordine la stanza.'**
  String get introLine4;

  /// No description provided for @introLine5.
  ///
  /// In it, this message translates to:
  /// **'E prenditi cura di me: pappa, giochi e bagnetto. Insieme salveremo il pianeta!'**
  String get introLine5;

  /// No description provided for @introOtterLabel.
  ///
  /// In it, this message translates to:
  /// **'Laiqua, la lontra, saluta felice'**
  String get introOtterLabel;

  /// No description provided for @introFinaleTitle.
  ///
  /// In it, this message translates to:
  /// **'Laiqua!'**
  String get introFinaleTitle;

  /// No description provided for @introStart.
  ///
  /// In it, this message translates to:
  /// **'Inizia l\'avventura'**
  String get introStart;

  /// No description provided for @demoStart.
  ///
  /// In it, this message translates to:
  /// **'Modalità demo'**
  String get demoStart;

  /// No description provided for @demoStop.
  ///
  /// In it, this message translates to:
  /// **'Esci dalla demo'**
  String get demoStop;

  /// No description provided for @demoCaptionHome.
  ///
  /// In it, this message translates to:
  /// **'Home: la missione del giorno e i tuoi progressi'**
  String get demoCaptionHome;

  /// No description provided for @demoCaptionLearn.
  ///
  /// In it, this message translates to:
  /// **'Impara: quiz brevi sui temi che ti interessano'**
  String get demoCaptionLearn;

  /// No description provided for @demoCaptionPet.
  ///
  /// In it, this message translates to:
  /// **'Cucciolo: prenditi cura di Laiqua, la tua lontra'**
  String get demoCaptionPet;

  /// No description provided for @demoCaptionWardrobe.
  ///
  /// In it, this message translates to:
  /// **'Guardaroba: premi e vestiti per il tuo cucciolo'**
  String get demoCaptionWardrobe;
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
