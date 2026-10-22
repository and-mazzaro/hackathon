/// What an activity pays out. Every activity builds one of these and hands
/// it to `GameController.claimReward`; no screen adds coins or XP itself.
class Reward {
  const Reward({this.xp = 0, this.coins = 0, this.tickets = 0})
      : assert(xp >= 0 && coins >= 0 && tickets >= 0,
            'Rewards cannot be negative. Spending uses its own methods.');

  static const none = Reward();

  final int xp;
  final int coins;
  final int tickets;

  bool get isEmpty => xp == 0 && coins == 0 && tickets == 0;

  Reward operator +(Reward other) => Reward(
        xp: xp + other.xp,
        coins: coins + other.coins,
        tickets: tickets + other.tickets,
      );

  @override
  String toString() => 'Reward(xp: $xp, coins: $coins, tickets: $tickets)';
}
