// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Laiqua';

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
      'Questi progressi sono stati salvati da una versione più recente di Laiqua. Aggiorna l\'app per continuare.';

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
  String get learnPlayNowTitle => 'Gioca subito';

  @override
  String get learnPlayNowBody =>
      '5 domande a sorpresa, prima i tuoi argomenti preferiti. Più risposte giuste di fila, più XP!';

  @override
  String get learnPlayNowAction => 'Tocca per iniziare';

  @override
  String learnLearnedTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count domande imparate',
      one: '1 domanda imparata',
      zero: 'Nessuna domanda imparata',
    );
    return '$_temp0';
  }

  @override
  String learnTopicLearned(int learned, int total) {
    return '$learned su $total imparate';
  }

  @override
  String get learnTopicsHint => 'Oppure scegli un argomento';

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
  String get petStageEgg => 'Uovo';

  @override
  String get petStageBaby => 'Cucciolo';

  @override
  String get petStageYoung => 'Giovane';

  @override
  String get petStageAdult => 'Adulto';

  @override
  String get petMoodHappy => 'Di buon umore';

  @override
  String get petMoodOk => 'Tutto ok';

  @override
  String get petMoodSad => 'Un po\' giù';

  @override
  String get petEggName => 'Uovo misterioso';

  @override
  String petSemantics(String name, String stage, String mood) {
    return '$name, $stage, $mood';
  }

  @override
  String get petSadHint =>
      'Non succede niente di grave: prenditene cura e tornerà di buon umore.';

  @override
  String get careFeed => 'Dai da mangiare';

  @override
  String get carePlay => 'Gioca insieme';

  @override
  String get careClean => 'Fai il bagnetto';

  @override
  String careFedMessage(String name) {
    return 'Gnam! $name ha mangiato con gusto.';
  }

  @override
  String carePlayedMessage(String name) {
    return 'Che divertimento per $name!';
  }

  @override
  String careCleanedMessage(String name) {
    return 'Bagnetto fatto: $name ora profuma di fresco!';
  }

  @override
  String careAlreadyFull(String name) {
    return 'Già al massimo: $name sta benissimo così!';
  }

  @override
  String eggHatchProgress(int level, int xp) {
    return 'Si schiuderà al livello $level: ti mancano $xp XP.';
  }

  @override
  String get eggHatchHint =>
      'Completa i quiz in Impara per guadagnare XP e farlo schiudere!';

  @override
  String get eggStroke => 'Accarezza l\'uovo';

  @override
  String get eggStrokeMessage => 'L\'uovo si è mosso un pochino…';

  @override
  String get eggReady => 'L\'uovo si muove: è pronto a schiudersi!';

  @override
  String get eggHatchAction => 'Fai schiudere l\'uovo';

  @override
  String get hatchTitle => 'Il tuo cucciolo è nato!';

  @override
  String get hatchBody =>
      'Scegli un nome (facoltativo). Crescerà insieme a te, quiz dopo quiz.';

  @override
  String get petNameLabel => 'Nome del cucciolo (facoltativo)';

  @override
  String get petNameHint => 'Es. Laiqua';

  @override
  String get hatchConfirm => 'Fatto';

  @override
  String hatchedMessage(String name) {
    return 'Ecco $name, il tuo nuovo cucciolo!';
  }

  @override
  String growReady(String name) {
    return 'È il momento di crescere per $name!';
  }

  @override
  String get growAction => 'Fai crescere';

  @override
  String grownMessage(String name, String stage) {
    return '$name ora è $stage!';
  }

  @override
  String nextGrowth(int level) {
    return 'Prossima crescita al livello $level.';
  }

  @override
  String get quizPetHappier =>
      'Anche il tuo cucciolo è più felice grazie al quiz!';

  @override
  String get binPlasticMetal => 'Plastica e metalli';

  @override
  String get binPaper => 'Carta e cartone';

  @override
  String get binOrganic => 'Organico';

  @override
  String get binGlass => 'Vetro';

  @override
  String get binResidual => 'Indifferenziato';

  @override
  String cleanupProgress(int done, int total) {
    return '$done di $total sistemati';
  }

  @override
  String get cleanupLocalRules =>
      'Qui trovi le indicazioni generali: le regole possono cambiare da Comune a Comune, controlla sempre quelle del tuo.';

  @override
  String get cleanupHowTo =>
      'Tocca un rifiuto e poi il bidone giusto. Puoi anche trascinarlo sul bidone.';

  @override
  String cleanupSelected(String name) {
    return 'Selezionato: $name. Ora tocca un bidone.';
  }

  @override
  String get cleanupPickFirst => 'Prima scegli un rifiuto nella stanza.';

  @override
  String cleanupCorrect(String name, String bin) {
    return 'Giusto! $name va in: $bin.';
  }

  @override
  String cleanupWrong(String name, String bin) {
    return 'Quasi! $name va in: $bin.';
  }

  @override
  String cleanupComboBonus(int count) {
    return 'Combo di $count: monete bonus!';
  }

  @override
  String cleanupCombo(int count) {
    return 'Combo x$count';
  }

  @override
  String get cleanupExit => 'Esci dalla pulizia';

  @override
  String get cleanupExitTitle => 'Vuoi interrompere la pulizia?';

  @override
  String get cleanupExitBody =>
      'I rifiuti già sistemati non verranno salvati e non riceverai monete.';

  @override
  String get cleanupExitStay => 'Continua a pulire';

  @override
  String get cleanupNoItems => 'Non ci sono ancora rifiuti da sistemare.';

  @override
  String cleanupResultScore(int correct, int total) {
    return '$correct rifiuti su $total nel bidone giusto';
  }

  @override
  String cleanupResultCoins(int coins) {
    return '+$coins monete';
  }

  @override
  String cleanupResultBestCombo(int count) {
    return 'Combo migliore: $count';
  }

  @override
  String get cleanupRoomClean => 'La stanza è pulita!';

  @override
  String levelUpTickets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Premio: $count biglietti per la ruota dell\'Armadio!',
      one: 'Premio: 1 biglietto per la ruota dell\'Armadio!',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeTitle => 'Armadio';

  @override
  String get wardrobeOpenFromPet => 'Apri l\'armadio';

  @override
  String get homeWardrobeTitle => 'Armadio del cucciolo';

  @override
  String get homeWardrobeSubtitle =>
      'Vestiti e accessori con monete e biglietti';

  @override
  String get wardrobeEggNote =>
      'Gli oggetti si vedranno addosso al cucciolo quando l\'uovo si schiude. Puoi già raccoglierli!';

  @override
  String get wardrobeContentError =>
      'Non riesco a caricare gli oggetti. Riprova più tardi.';

  @override
  String get slotHead => 'Testa';

  @override
  String get slotFace => 'Viso';

  @override
  String get slotNeck => 'Collo';

  @override
  String get slotPaws => 'Zampe';

  @override
  String get rarityCommon => 'Comune';

  @override
  String get rarityUncommon => 'Non comune';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityEpic => 'Epico';

  @override
  String get rarityLegendary => 'Leggendario';

  @override
  String get rarityMythic => 'Mitico';

  @override
  String get rarityCommonPlural => 'comuni';

  @override
  String get rarityUncommonPlural => 'non comuni';

  @override
  String get rarityRarePlural => 'rari';

  @override
  String get rarityEpicPlural => 'epici';

  @override
  String get rarityLegendaryPlural => 'leggendari';

  @override
  String get rarityMythicPlural => 'mitici';

  @override
  String listLastItem(String items, String last) {
    return '$items e $last';
  }

  @override
  String get rollTitle => 'Ruota dei premi';

  @override
  String get rollBody =>
      'Usa un biglietto per ricevere un oggetto a sorpresa. Queste sono le probabilità:';

  @override
  String rollOddsLine(String rarity, int percent) {
    return '$rarity: $percent%';
  }

  @override
  String rollOddsSemantics(String odds) {
    return 'Probabilità: $odds';
  }

  @override
  String rollOddsSpokenItem(String rarity, int percent) {
    return '$rarity $percent percento';
  }

  @override
  String rollDuplicateRule(String refunds) {
    return 'Se esce un oggetto che hai già, ricevi monete al suo posto: $refunds.';
  }

  @override
  String rollRefundItem(String rarity, int coins) {
    return '$rarity $coins';
  }

  @override
  String get rollAction => 'Usa 1 biglietto';

  @override
  String get rollNoTickets =>
      'Non hai biglietti. Li guadagni salendo di livello, oppure puoi comprarne uno.';

  @override
  String buyTicketAction(int price) {
    return 'Compra un biglietto ($price monete)';
  }

  @override
  String get ticketBought => 'Hai comprato un biglietto premio!';

  @override
  String get rollRevealNew => 'Nuovo oggetto!';

  @override
  String get rollRevealDuplicate => 'Ce l\'hai già';

  @override
  String rollRevealSpecial(String rarity) {
    return '$rarity!';
  }

  @override
  String rollRefund(int coins) {
    return 'Al suo posto ricevi $coins monete.';
  }

  @override
  String get rollWearNow => 'Indossa ora';

  @override
  String get rollClose => 'Chiudi';

  @override
  String get shopTitle => 'Negozio';

  @override
  String shopRollOnlyNote(String rarities) {
    return 'Gli oggetti $rarities si trovano solo nella ruota dei premi.';
  }

  @override
  String get shopAllOwned => 'Hai già tutti gli oggetti del negozio!';

  @override
  String shopBuyAction(int price) {
    return 'Compra ($price monete)';
  }

  @override
  String shopNotEnoughCoins(int missing) {
    return 'Ti servono altre $missing monete. Le guadagni pulendo la stanza.';
  }

  @override
  String itemBought(String name) {
    return 'Hai comprato: $name!';
  }

  @override
  String itemDetails(String rarity, String slot) {
    return '$rarity · $slot';
  }

  @override
  String get myItemsTitle => 'I miei oggetti';

  @override
  String get myItemsEmpty =>
      'Non hai ancora oggetti. Prova la ruota o il negozio!';

  @override
  String get equipAction => 'Indossa';

  @override
  String get unequipAction => 'Togli';

  @override
  String petWearsItem(String pet, String item) {
    return '$pet indossa: $item';
  }

  @override
  String petTookOffItem(String pet, String item) {
    return '$pet ha tolto: $item';
  }

  @override
  String get cleanupPetCleaner =>
      'La stanza è in ordine e anche il tuo cucciolo è più pulito!';

  @override
  String get cleanupRepeatNote =>
      'I rifiuti che sapevi già sistemare valgono meno monete: le combo invece valgono sempre!';

  @override
  String get cleanupOpenFromPet => 'Pulisci la stanza';

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
  String get welcomeTitle => 'Ti diamo il benvenuto in Laiqua!';

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
      'Non serve un account. Soprannome, età, interessi e progressi sono salvati su questo telefono. Laiqua non usa la tua posizione e non chiede la data di nascita.';

  @override
  String get comebackTitle => 'Mi sei mancato!';

  @override
  String get comebackBody =>
      'Che bello rivederti. Ripartiamo con calma, senza fretta.';

  @override
  String get comebackEggBody =>
      'L\'uovo è rimasto al calduccio. Che bello rivederti: ripartiamo con calma.';

  @override
  String get comebackSuggestCare => 'Idea facile: fai una coccola al cucciolo';

  @override
  String get comebackSuggestCleanup =>
      'Idea facile: un giro di Pulisci la stanza';

  @override
  String comebackBonusAction(int coins) {
    return 'Prendi il regalo: +$coins monete';
  }

  @override
  String get comebackBonusClaimed =>
      'Regalo preso! Che bello giocare di nuovo insieme.';

  @override
  String get reminderTitle => 'Promemoria giornaliero';

  @override
  String get reminderBody =>
      'Se vuoi, Laiqua può mandarti un solo avviso al giorno, all\'ora che scegli tu. Il promemoria resta su questo telefono e puoi spegnerlo quando vuoi.';

  @override
  String get reminderSwitch => 'Ricordamelo ogni giorno';

  @override
  String reminderTime(String time) {
    return 'Ora del promemoria: $time';
  }

  @override
  String get reminderChangeTime => 'Cambia ora';

  @override
  String get reminderPermissionDenied =>
      'Le notifiche sono bloccate sul telefono, quindi il promemoria non arriverà. Il gioco funziona lo stesso.';

  @override
  String reminderNotificationTitle(String pet) {
    return '$pet ti aspetta!';
  }

  @override
  String reminderNotificationBody(String topic) {
    return 'Hai 2 minuti? C\'è una nuova scoperta su $topic.';
  }

  @override
  String get reminderNotificationBodyGeneric =>
      'Hai 2 minuti? Vieni a scoprire qualcosa di nuovo sulla natura.';

  @override
  String get reminderPetFallback => 'Il tuo cucciolo';

  @override
  String get activityDataTitle => 'La tua attività';

  @override
  String get activityDataBody =>
      'Per capire quando darti una mano, Laiqua conta sul telefono quante volte giochi e quante risposte indovini negli ultimi 14 giorni. Niente posizione, niente Wi-Fi, niente dati inviati.';

  @override
  String get activityClearAction => 'Cancella la mia attività';

  @override
  String get activityClearConfirmTitle => 'Cancellare la tua attività?';

  @override
  String get activityClearConfirmBody =>
      'Cancelliamo il registro degli ultimi giorni e spegniamo il promemoria. Livello, monete, cucciolo e oggetti restano come sono.';

  @override
  String get activityClearConfirm => 'Cancella';

  @override
  String get activityClearCancel => 'Annulla';

  @override
  String get activityCleared => 'Attività cancellata.';

  @override
  String get feedGameTitle => 'Prepara la pappa';

  @override
  String feedGameIntro(String name) {
    return 'Rispondi a 2 domande veloci per preparare la pappa di $name.';
  }

  @override
  String get feedGameNext => 'Prossima domanda';

  @override
  String get feedGameServe => 'Servi la pappa';

  @override
  String feedGameKindMessage(String name) {
    return 'Ci riproviamo! Intanto $name ha fatto merenda.';
  }

  @override
  String get introProfileButton => 'Guarda l\'introduzione';

  @override
  String get introSkip => 'Salta';

  @override
  String get introSkipLabel => 'Salta l\'introduzione';

  @override
  String get introLogo => 'LAIQUA';

  @override
  String get introSubtitle => 'Salva il pianeta, un gioco alla volta';

  @override
  String get introPressStart => 'Tocca per iniziare';

  @override
  String get introNext => 'Tocca per continuare';

  @override
  String get introLine1 => 'Ciao! Benvenuto nel mondo di Laiqua!';

  @override
  String get introLine2 =>
      'Io sono Laiqua, una lontra. Il nostro pianeta ha bisogno di aiuto!';

  @override
  String get introLine3 =>
      'Rispondi ai quiz e scopri come proteggere la natura.';

  @override
  String get introLine4 =>
      'Impara a dividere i rifiuti e rimetti in ordine la stanza.';

  @override
  String get introLine5 =>
      'E prenditi cura di me: pappa, giochi e bagnetto. Insieme salveremo il pianeta!';

  @override
  String get introOtterLabel => 'Laiqua, la lontra, saluta felice';

  @override
  String get introFinaleTitle => 'Laiqua!';

  @override
  String get introStart => 'Inizia l\'avventura';

  @override
  String get demoStart => 'Modalità demo';

  @override
  String get demoStop => 'Esci dalla demo';

  @override
  String get demoCaptionHome =>
      'Home: la missione del giorno e i tuoi progressi';

  @override
  String get demoCaptionLearn =>
      'Impara: quiz brevi sui temi che ti interessano';

  @override
  String get demoCaptionPet =>
      'Cucciolo: prenditi cura di Laiqua, la tua lontra';

  @override
  String get demoCaptionWardrobe =>
      'Guardaroba: premi e vestiti per il tuo cucciolo';

  @override
  String get lookTitle => 'Aspetto';

  @override
  String get lookBody =>
      'Come appare la stanza del cucciolo. Con Automatico segue l\'ora del telefono.';

  @override
  String get lookAuto => 'Automatico';

  @override
  String get lookDay => 'Giorno';

  @override
  String get lookAfternoon => 'Pomeriggio';

  @override
  String get lookNight => 'Notte';

  @override
  String get roomTrashClean => 'La stanza è pulita! Torna più tardi';

  @override
  String roomTrashSemantics(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nella stanza ci sono $count rifiuti: $names.',
      one: 'Nella stanza c\'è 1 rifiuto: $names.',
    );
    return '$_temp0';
  }
}
