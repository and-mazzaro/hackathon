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
      'Rispondi ai quiz per guadagnare XP e far crescere il tuo cucciolo.';

  @override
  String get learnForYouTitle => 'Quiz per te';

  @override
  String get learnForYouBody =>
      '5 domande sui tuoi argomenti preferiti, dalla più facile alla più difficile.';

  @override
  String get learnForYouAction => 'Gioca';

  @override
  String get learnTopicsTitle => 'Quiz per argomento';

  @override
  String get learnForYouBadge => 'Per te';

  @override
  String learnQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count domande',
      one: '1 domanda',
      zero: 'Domande in arrivo',
    );
    return '$_temp0';
  }

  @override
  String learnTopicStats(int correct, int answered) {
    return 'Risposte giuste: $correct su $answered';
  }

  @override
  String learnQuizzesCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quiz completati',
      one: '1 quiz completato',
      zero: 'Non hai ancora completato nessun quiz',
    );
    return '$_temp0';
  }

  @override
  String get learnContentError =>
      'Non riesco a caricare le domande. Riavvia l\'app; se il problema continua, avvisa il team.';

  @override
  String get quizMixedTitle => 'Quiz misto';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Domanda $current di $total';
  }

  @override
  String get quizExit => 'Esci dal quiz';

  @override
  String get quizExitTitle => 'Vuoi uscire dal quiz?';

  @override
  String get quizExitBody =>
      'Le risposte di questo quiz non verranno salvate e non riceverai XP.';

  @override
  String get quizExitConfirm => 'Esci';

  @override
  String get quizExitStay => 'Continua il quiz';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String quizStreak(int count) {
    return 'Serie di $count';
  }

  @override
  String get quizCorrect => 'Corretto!';

  @override
  String get quizWrong => 'Non proprio.';

  @override
  String quizCorrectAnswerIs(String answer) {
    return 'La risposta giusta è: $answer';
  }

  @override
  String get quizOptionCorrect => 'risposta giusta';

  @override
  String get quizOptionWrong => 'risposta sbagliata';

  @override
  String quizSource(String name) {
    return 'Fonte: $name';
  }

  @override
  String quizSourceVerified(String date) {
    return 'Verificata dal team il $date';
  }

  @override
  String get quizSourceCopyHint => 'Tieni premuto l\'indirizzo per copiarlo.';

  @override
  String get quizSeeResult => 'Vedi il risultato';

  @override
  String get quizNotEnough => 'Non ci sono ancora domande per questo quiz.';

  @override
  String quizResultScore(int correct, int total) {
    return '$correct su $total risposte giuste';
  }

  @override
  String get quizResultPerfect => 'Perfetto! Hai risposto bene a tutto.';

  @override
  String get quizResultGood => 'Ottimo lavoro!';

  @override
  String get quizResultKeepGoing =>
      'Ogni risposta ti insegna qualcosa: riprova!';

  @override
  String quizResultXp(int xp) {
    return '+$xp XP';
  }

  @override
  String quizResultBestStreak(int count) {
    return 'Serie migliore: $count';
  }

  @override
  String quizResultNewlyLearned(int count) {
    return 'Cose nuove imparate: $count';
  }

  @override
  String get quizResultRepeatNote =>
      'Le domande che conoscevi già valgono meno XP: prova un altro argomento per guadagnarne di più!';

  @override
  String quizLevelUp(int level) {
    return 'Hai raggiunto il livello $level!';
  }

  @override
  String get quizPlayAgain => 'Gioca ancora';

  @override
  String get quizClose => 'Chiudi';

  @override
  String get petTitle => 'La stanza del tuo cucciolo';

  @override
  String get petBody =>
      'Qui potrai prenderti cura del tuo compagno e riciclare i rifiuti della sua stanza.';

  @override
  String onboardingStep(int step, int total) {
    return 'Passo $step di $total';
  }

  @override
  String get backAction => 'Indietro';

  @override
  String get nextAction => 'Avanti';

  @override
  String get skipAction => 'Salta';

  @override
  String get finishAction => 'Fine';

  @override
  String get saveAction => 'Salva';

  @override
  String get cancelAction => 'Annulla';

  @override
  String get welcomeTitle => 'Ti diamo il benvenuto in EcoQuest!';

  @override
  String get welcomeBody =>
      'Impara a proteggere l\'ambiente giocando. Ogni quiz e ogni rifiuto riciclato aiutano il tuo cucciolo a schiudersi e a vivere in una stanza sempre più verde.';

  @override
  String get welcomePrivacy =>
      'Non serve un account: i tuoi progressi vengono salvati su questo telefono.';

  @override
  String get welcomeStartAction => 'Iniziamo';

  @override
  String get welcomeEggLabel =>
      'Il tuo cucciolo, ancora nell\'uovo, ti aspetta';

  @override
  String get interestsTitle => 'Cosa ti interessa?';

  @override
  String get interestsBody =>
      'Scegli gli argomenti che preferisci: li useremo per proporti quiz e curiosità. Potrai cambiarli quando vuoi dal profilo.';

  @override
  String interestsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count argomenti scelti',
      one: '1 argomento scelto',
      zero: 'Nessun argomento scelto',
    );
    return '$_temp0';
  }

  @override
  String get interestsMinHint => 'Scegline almeno uno per continuare.';

  @override
  String get aboutTitle => 'Parlaci un po\' di te';

  @override
  String get aboutBody =>
      'Entrambe le risposte sono facoltative. L\'età ci serve solo per scegliere domande adatte: non chiediamo la data di nascita.';

  @override
  String get nicknameLabel => 'Soprannome (facoltativo)';

  @override
  String get nicknameHint => 'Es. EcoAle';

  @override
  String get nicknameHelper => 'Non usare il tuo nome e cognome completi.';

  @override
  String get ageRangeLabel => 'Età (facoltativa)';

  @override
  String get ageRange13to15 => '13–15 anni';

  @override
  String get ageRange16to18 => '16–18 anni';

  @override
  String get ageRange19to22 => '19–22 anni';

  @override
  String get ageRange23to26 => '23–26 anni';

  @override
  String get ageRangeOver26 => '27 anni o più';

  @override
  String get ageRangeNotSaid => 'Preferisco non dirlo';

  @override
  String get topicRecycling => 'Riciclo e rifiuti';

  @override
  String get topicClimate => 'Clima';

  @override
  String get topicOceans => 'Oceani e vita marina';

  @override
  String get topicBiodiversity => 'Animali e biodiversità';

  @override
  String get topicForests => 'Foreste ed ecosistemi';

  @override
  String get topicEnergy => 'Energia rinnovabile';

  @override
  String get topicWater => 'Risparmio d\'acqua';

  @override
  String get topicTransport => 'Mobilità sostenibile';

  @override
  String get topicConsumption => 'Consumo responsabile';

  @override
  String get topicInnovation => 'Innovazione green';

  @override
  String get profileGuestName => 'Ospite';

  @override
  String profileLevelLine(int level) {
    return 'Livello $level · profilo su questo telefono';
  }

  @override
  String profileAgeLine(String range) {
    return 'Età: $range';
  }

  @override
  String get profileEditDetails => 'Modifica soprannome ed età';

  @override
  String get profileEditTitle => 'Soprannome ed età';

  @override
  String get profileInterestsTitle => 'I tuoi interessi';

  @override
  String get profileInterestsBody =>
      'Tocca un argomento per attivarlo o disattivarlo. Le modifiche vengono salvate subito e i tuoi progressi restano invariati.';

  @override
  String get profileKeepOneInterest => 'Tieni almeno un interesse.';

  @override
  String get profileDataTitle => 'I tuoi dati';

  @override
  String get profileDataBody =>
      'Non serve un account. Soprannome, età, interessi e progressi sono salvati su questo telefono. EcoQuest non usa la tua posizione e non chiede la data di nascita.';
}
