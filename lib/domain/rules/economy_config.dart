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
    this.quizXpPerCorrectAnswer = 10,
    this.quizStreakBonusXp = 5,
    this.coinsPerCorrectSort = 2,
    this.sortComboLength = 3,
    this.sortComboBonusCoins = 3,
    this.ticketPriceInCoins = 100,
  })  : assert(xpForFirstLevelUp > 0),
        assert(xpIncreasePerLevel >= 0);

  static const defaults = EconomyConfig();

  // New player
  final int startingCoins;

  /// One welcome ticket, so the first cosmetic roll can happen early.
  final int startingTickets;
  final int startingPetNeed;

  // Levels: level 1 → 2 needs 100 XP, 2 → 3 needs 150, 3 → 4 needs 200, ...
  final int xpForFirstLevelUp;
  final int xpIncreasePerLevel;

  // Topic Quiz (Mode 5) — used from the quiz milestone
  final int quizXpPerCorrectAnswer;

  /// Extra XP for each correct answer after the first one in a row.
  final int quizStreakBonusXp;

  // Room Cleanup (Mode 1) — used from the recycling milestone
  final int coinsPerCorrectSort;

  /// Every [sortComboLength] correct sorts in a row pay [sortComboBonusCoins].
  final int sortComboLength;
  final int sortComboBonusCoins;

  // Shop — used from the cosmetics milestone
  final int ticketPriceInCoins;
}
