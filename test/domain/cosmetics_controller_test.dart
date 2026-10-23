import 'dart:math';

import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/cosmetic_item.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/reward.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/cosmetic_fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 22, 10);
  late InMemorySaveRepository repository;
  final hat = testCosmetic(CosmeticSlot.head, CosmeticRarity.common);
  final rareHat = testCosmetic(CosmeticSlot.head, CosmeticRarity.rare);
  final epicHat = testCosmetic(CosmeticSlot.head, CosmeticRarity.epic);
  final mythicPebble = testCosmetic(CosmeticSlot.paws, CosmeticRarity.mythic);

  /// Creating a new container with the same repository = restarting.
  Future<ProviderContainer> startApp() async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => now),
        randomProvider.overrideWithValue(Random(42)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(gameControllerProvider.future);
    return container;
  }

  GameController controller(ProviderContainer c) =>
      c.read(gameControllerProvider.notifier);
  GameState game(ProviderContainer c) =>
      c.read(gameControllerProvider).requireValue;

  Future<ProviderContainer> startWithCoins(int coins, {int tickets = 1}) async {
    repository = InMemorySaveRepository(GameState.initial(now: now).copyWith(
      progress: GameState.initial(now: now)
          .progress
          .copyWith(coins: coins, tickets: tickets),
    ));
    return startApp();
  }

  setUp(() => repository = InMemorySaveRepository());

  group('level-up tickets', () {
    test('each level gained pays one ticket, in the claim result', () async {
      final app = await startApp(); // 1 welcome ticket

      final result =
          await controller(app).claimReward('quiz:1', const Reward(xp: 100));

      expect(result.leveledUp, isTrue);
      expect(result.reward.tickets, 1);
      expect(game(app).progress.tickets, 2);
      expect(repository.saved!.progress.tickets, 2);
    });

    test('two levels at once pay two tickets', () async {
      final app = await startApp();
      // Level 3 needs 100 + 150 XP.
      await controller(app).claimReward('quiz:1', const Reward(xp: 250));
      expect(game(app).progress.tickets, 3);
    });

    test('no level-up, no ticket; a repeated claim pays nothing', () async {
      final app = await startApp();
      await controller(app).claimReward('quiz:1', const Reward(xp: 50));
      expect(game(app).progress.tickets, 1);

      await controller(app).claimReward('quiz:2', const Reward(xp: 50));
      final again =
          await controller(app).claimReward('quiz:2', const Reward(xp: 50));
      expect(again.applied, isFalse);
      expect(game(app).progress.tickets, 2);
    });
  });

  group('shop', () {
    test('buying a ticket costs 100 coins', () async {
      final app = await startWithCoins(130);

      expect(await controller(app).buyTicket(), PurchaseResult.bought);
      expect(game(app).progress.coins, 30);
      expect(game(app).progress.tickets, 2);
      expect(await controller(app).buyTicket(), PurchaseResult.notEnoughCoins);
      expect(game(app).progress.tickets, 2);
    });

    test('buying an item spends coins and adds it once', () async {
      final app = await startWithCoins(100);

      expect(await controller(app).buyItem(hat), PurchaseResult.bought);
      expect(game(app).progress.coins, 40);
      expect(game(app).inventory.owns(hat.id), isTrue);
      expect(await controller(app).buyItem(hat), PurchaseResult.alreadyOwned);
      expect(game(app).progress.coins, 40);
    });

    test('an uncommon item costs 100 coins', () async {
      final app = await startWithCoins(100);
      final uncommonHat =
          testCosmetic(CosmeticSlot.head, CosmeticRarity.uncommon);

      expect(await controller(app).buyItem(uncommonHat), PurchaseResult.bought);
      expect(game(app).progress.coins, 0);
    });

    test('not enough coins, or a roll-only item: nothing changes', () async {
      final app = await startWithCoins(159);

      // A rare costs 160.
      expect(
          await controller(app).buyItem(rareHat), PurchaseResult.notEnoughCoins);
      expect(await controller(app).buyItem(epicHat), PurchaseResult.notForSale);
      expect(
          await controller(app).buyItem(
              testCosmetic(CosmeticSlot.neck, CosmeticRarity.legendary)),
          PurchaseResult.notForSale);
      expect(await controller(app).buyItem(mythicPebble),
          PurchaseResult.notForSale);
      expect(game(app).progress.coins, 159);
      expect(game(app).inventory.ownedItemIds, isEmpty);
      expect(repository.saveCount, 0);
    });
  });

  group('reward roll', () {
    test('spends a ticket and adds a new item', () async {
      final app = await startApp(); // 1 ticket

      final outcome = await controller(app).rollCosmetic(testCosmeticCatalog());

      expect(outcome, isNotNull);
      expect(outcome!.isNew, isTrue);
      expect(outcome.refundCoins, 0);
      expect(game(app).progress.tickets, 0);
      expect(game(app).inventory.owns(outcome.item.id), isTrue);
      expect(repository.saved!.inventory.owns(outcome.item.id), isTrue);
    });

    test('a duplicate pays coins back instead', () async {
      final only = CosmeticCatalog([hat]);
      final app = await startWithCoins(0, tickets: 2);

      await controller(app).rollCosmetic(only);
      final second = await controller(app).rollCosmetic(only);

      expect(second!.isNew, isFalse);
      expect(second.refundCoins, 15);
      expect(game(app).progress.coins, 15);
      expect(game(app).progress.tickets, 0);
      expect(game(app).inventory.ownedItemIds, {hat.id});
      expect(repository.saved!.progress.coins, 15);
    });

    test('a duplicate of a mythic item pays 150 coins', () async {
      // With only one (mythic) item, every roll gives it.
      final only = CosmeticCatalog([mythicPebble]);
      final app = await startWithCoins(0, tickets: 2);

      final first = await controller(app).rollCosmetic(only);
      final second = await controller(app).rollCosmetic(only);

      expect(first!.isNew, isTrue);
      expect(first.refundCoins, 0);
      expect(second!.isNew, isFalse);
      expect(second.item.rarity, CosmeticRarity.mythic);
      expect(second.refundCoins, 150);
      expect(game(app).progress.coins, 150);
      expect(repository.saved!.progress.coins, 150);
      expect(game(app).inventory.ownedItemIds, {mythicPebble.id});
    });

    test('without tickets nothing happens', () async {
      final app = await startWithCoins(0, tickets: 0);

      expect(await controller(app).rollCosmetic(testCosmeticCatalog()), isNull);
      expect(repository.saveCount, 0);
    });
  });

  group('equip', () {
    test('only owned items, one per slot, kept after a restart', () async {
      final app = await startWithCoins(300);

      expect(await controller(app).equip(hat), isFalse);
      await controller(app).buyItem(hat);
      await controller(app).buyItem(rareHat);
      expect(await controller(app).equip(hat), isTrue);
      await controller(app).equip(rareHat);
      expect(game(app).inventory.equippedBySlot, {'head': rareHat.id});

      final restarted = await startApp();
      expect(game(restarted).inventory.equippedBySlot, {'head': rareHat.id});

      await controller(restarted).unequip(CosmeticSlot.head);
      expect(game(restarted).inventory.equippedBySlot, isEmpty);
      expect(game(restarted).inventory.owns(rareHat.id), isTrue);
    });

    test('a paws item is worn together with a head item', () async {
      final app = await startWithCoins(120);
      final pebble = testCosmetic(CosmeticSlot.paws, CosmeticRarity.common);

      await controller(app).buyItem(hat);
      await controller(app).buyItem(pebble);
      await controller(app).equip(hat);
      await controller(app).equip(pebble);

      expect(game(app).inventory.equippedBySlot,
          {'head': hat.id, 'paws': pebble.id});
    });
  });
}
