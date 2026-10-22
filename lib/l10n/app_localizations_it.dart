// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'EcoQuest';

  @override
  String get navHome => 'Home';

  @override
  String get navLearn => 'Impara';

  @override
  String get navPet => 'Cucciolo';

  @override
  String get navProfile => 'Profilo';

  @override
  String levelLabel(int level) {
    return 'Livello $level';
  }

  @override
  String xpProgress(int current, int target) {
    return '$current su $target punti esperienza';
  }

  @override
  String coinsAmount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString monete',
      one: '1 moneta',
    );
    return '$_temp0';
  }

  @override
  String ticketsAmount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString biglietti premio',
      one: '1 biglietto premio',
    );
    return '$_temp0';
  }

  @override
  String percentValue(int percent) {
    return '$percent percento';
  }

  @override
  String get statSatiety => 'Sazietà';

  @override
  String get statHappiness => 'Felicità';

  @override
  String get statCleanliness => 'Pulizia';

  @override
  String get comingSoon => 'In arrivo';

  @override
  String get homePetPreview => 'Il tuo cucciolo, ancora nell\'uovo';

  @override
  String get homeActivitiesTitle => 'Attività di oggi';

  @override
  String get homeQuizTitle => 'Quiz del giorno';

  @override
  String get homeQuizSubtitle => '5 domande · circa 3 minuti';

  @override
  String get homeCleanupTitle => 'Pulisci la stanza';

  @override
  String get homeCleanupSubtitle => 'Ricicla i rifiuti e guadagna monete';

  @override
  String get loadingProgress => 'Carico i tuoi progressi…';

  @override
  String get saveErrorTitle => 'Non riesco a leggere i tuoi progressi';

  @override
  String get saveCorruptedBody =>
      'Il salvataggio sembra danneggiato. Puoi riprovare oppure ricominciare da capo.';

  @override
  String get saveNewerAppBody =>
      'Questi progressi sono stati salvati da una versione più recente di EcoQuest. Aggiorna l\'app per continuare.';

  @override
  String get saveUnknownErrorBody =>
      'Si è verificato un problema imprevisto. Riprova tra poco.';

  @override
  String get retryAction => 'Riprova';

  @override
  String get startFreshAction => 'Ricomincia da capo';

  @override
  String get debugRewardAction => 'Ricompensa di prova (solo debug)';

  @override
  String get learnTitle => 'Impara giocando';

  @override
  String get learnBody =>
      'Qui arriveranno quiz, mini-giochi e curiosità sull\'ambiente.';

  @override
  String get petTitle => 'La stanza del tuo cucciolo';

  @override
  String get petBody =>
      'Qui potrai prenderti cura del tuo compagno e riciclare i rifiuti della sua stanza.';

  @override
  String get profileTitle => 'Il tuo profilo';

  @override
  String get profileBody =>
      'Qui troverai i tuoi interessi, i progressi e le impostazioni.';
}
