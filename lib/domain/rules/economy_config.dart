/// Every number that balances the game, in one place.
///
/// All values are FIRST GUESSES. Tune them while play-testing; never write
/// these numbers directly in a screen or feature.
class EconomyConfig {
  const EconomyConfig({
    this.startingCoins = 0,
    this.startingTickets = 1,
    this.startingPetNeed = 80,
    this.xpForFirstLevelUp = 100,
    this.xpIncreasePerLevel = 50,
    this.quizQuestionCount = 5,
    this.quizXpPerCorrectAnswer = 10,
    this.quizRepeatXp = 2,
    this.quizStreakBonusXp = 5,
    this.quizPetHappinessBoost = 15,
    this.petNeedFloor = 20,
    this.satietyDecayPerHour = 4,
    this.happinessDecayPerHour = 3,
    this.cleanlinessDecayPerHour = 2,
    this.petCareAmount = 30,
    this.hatchLevel = 2,
    this.youngLevel = 5,
    this.adultLevel = 10,
    this.levelsPerRoomPlant = 2,
    this.cleanupItemCount = 8,
    this.coinsPerCorrectSort = 2,
    this.coinsPerRepeatSort = 1,
    this.sortComboLength = 3,
    this.sortComboBonusCoins = 3,
    this.cleanupGoodRoundXp = 10,
    this.cleanupGoodRoundPercent = 75,
    this.cleanupPetCleanliness = 25,
    this.ticketPriceInCoins = 100,
    this.ticketsPerLevelUp = 1,
    this.shopPriceCommon = 60,
    this.shopPriceRare = 150,
    this.rollOddsCommon = 60,
    this.rollOddsRare = 30,
    this.rollOddsEpic = 10,
    this.duplicateRefundCommon = 20,
    this.duplicateRefundRare = 40,
    this.duplicateRefundEpic = 80,
  })  : assert(xpForFirstLevelUp > 0),
        assert(xpIncreasePerLevel >= 0),
        assert(rollOddsCommon + rollOddsRare + rollOddsEpic == 100);

  static const defaults = EconomyConfig();

  // New player
  final int startingCoins;

  /// One welcome ticket, so the first cosmetic roll can happen early.
  final int startingTickets;
  final int startingPetNeed;

  // Levels: level 1 → 2 needs 100 XP, 2 → 3 needs 150, 3 → 4 needs 200, ...
  final int xpForFirstLevelUp;
  final int xpIncreasePerLevel;

  // Topic Quiz (Mode 5)
  final int quizQuestionCount;

  /// XP for a question answered correctly for the first time.
  final int quizXpPerCorrectAnswer;

  /// XP for a correct answer to a question already learned before.
  /// Low on purpose: replaying the same quiz should not farm levels.
  final int quizRepeatXp;

  /// Extra XP for each correct answer after the first one in a row
  /// (also for repeats: it rewards attention).
  final int quizStreakBonusXp;

  /// Happiness the pet gains from every completed quiz (learning ↔ pet).
  final int quizPetHappinessBoost;

  // Virtual pet
  /// Needs never drop below this: the pet is never punished hard.
  final int petNeedFloor;

  /// How much each need drops per hour while the app is closed.
  final int satietyDecayPerHour;
  final int happinessDecayPerHour;
  final int cleanlinessDecayPerHour;

  /// What one care action (feed, play, bath) adds to its need.
  final int petCareAmount;

  /// Player level needed for each stage: learning makes the pet grow.
  final int hatchLevel;
  final int youngLevel;
  final int adultLevel;

  /// The room gets one more plant every N levels (max 3).
  final int levelsPerRoomPlant;

  // Room Cleanup (Mode 1)
  final int cleanupItemCount;

  /// Coins for an item sorted correctly for the first time.
  final int coinsPerCorrectSort;

  /// Coins for an item already sorted correctly before (anti-farming).
  final int coinsPerRepeatSort;

  /// Every [sortComboLength] correct sorts in a row pay [sortComboBonusCoins].
  final int sortComboLength;
  final int sortComboBonusCoins;

  /// XP for a round with at least [cleanupGoodRoundPercent]% right.
  final int cleanupGoodRoundXp;
  final int cleanupGoodRoundPercent;

  /// A clean room makes a hatched pet cleaner too.
  final int cleanupPetCleanliness;

  // Cosmetics: shop and reward roll
  final int ticketPriceInCoins;

  /// Tickets earned for every level gained (in the same claim).
  final int ticketsPerLevelUp;

  /// Shop prices in coins. Epic items are not sold: roll only.
  final int shopPriceCommon;
  final int shopPriceRare;

  /// Roll odds in percent, shown to the player as they are. Sum = 100.
  final int rollOddsCommon;
  final int rollOddsRare;
  final int rollOddsEpic;

  /// Coins paid back when a roll lands on an item already owned.
  final int duplicateRefundCommon;
  final int duplicateRefundRare;
  final int duplicateRefundEpic;
}
