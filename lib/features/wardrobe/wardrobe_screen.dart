import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../app/theme/eco_spacing.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/sound_id.dart';
import '../../core/widgets/currency_chip.dart';
import '../../core/widgets/eco_button.dart';
import '../../core/widgets/eco_card.dart';
import '../../core/widgets/game_state_view.dart';
import '../../data/content/cosmetic_content.dart';
import '../../domain/game_controller.dart';
import '../../domain/models/cosmetic_item.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/pet_state.dart';
import '../../domain/rules/cosmetic_rules.dart';
import '../../domain/rules/economy_config.dart';
import '../../domain/rules/pet_rules.dart';
import '../../domain/rules/progression.dart';
import '../../l10n/app_localizations.dart';
import '../pet/pet_labels.dart';
import '../pet/pet_view.dart';
import 'cosmetic_art.dart';
import 'cosmetic_labels.dart';

/// The wardrobe (full screen, from the Pet tab and Home): the reward roll
/// with its odds, the shop, and the items the pet can wear.
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalogAsync = ref.watch(cosmeticCatalogProvider);
    final catalog = catalogAsync.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wardrobeTitle)),
      body: catalog == null
          ? Center(
              child: catalogAsync.hasError
                  ? Padding(
                      padding: const EdgeInsets.all(EcoSpacing.l),
                      child: Text(l10n.wardrobeContentError,
                          textAlign: TextAlign.center),
                    )
                  : const CircularProgressIndicator(),
            )
          : GameStateView(
              builder: (context, game) =>
                  _WardrobeContent(game: game, catalog: catalog),
            ),
    );
  }
}

class _WardrobeContent extends ConsumerWidget {
  const _WardrobeContent({required this.game, required this.catalog});

  final GameState game;
  final CosmeticCatalog catalog;

  GameController _controller(WidgetRef ref) =>
      ref.read(gameControllerProvider.notifier);

  void _say(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _buyTicket(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await _controller(ref).buyTicket();
    if (!context.mounted) return;
    final audio = ref.read(audioServiceProvider);
    if (result == PurchaseResult.bought) {
      audio.play(SoundId.rewardCoins);
      _say(context, l10n.ticketBought);
    } else {
      audio.play(SoundId.uiUnavailable);
    }
  }

  Future<void> _buyItem(
      BuildContext context, WidgetRef ref, CosmeticItem item) async {
    final l10n = AppLocalizations.of(context);
    final result = await _controller(ref).buyItem(item);
    if (!context.mounted) return;
    final audio = ref.read(audioServiceProvider);
    if (result == PurchaseResult.bought) {
      audio.play(SoundId.rewardCoins);
      _say(context, l10n.itemBought(item.name));
    } else {
      audio.play(SoundId.uiUnavailable);
    }
  }

  Future<void> _roll(BuildContext context, WidgetRef ref) async {
    final outcome = await _controller(ref).rollCosmetic(catalog);
    if (!context.mounted) return;
    final audio = ref.read(audioServiceProvider);
    if (outcome == null) {
      audio.play(SoundId.uiUnavailable);
      return;
    }
    audio.play(outcome.isNew ? SoundId.rewardXp : SoundId.rewardCoins);
    final wear = await _showReveal(context, outcome);
    if (wear == true && context.mounted) {
      await _setWorn(context, ref, outcome.item, wear: true);
    }
  }

  Future<void> _setWorn(BuildContext context, WidgetRef ref, CosmeticItem item,
      {required bool wear}) async {
    final l10n = AppLocalizations.of(context);
    final name = petDisplayName(game.pet, l10n);
    if (wear) {
      await _controller(ref).equip(item);
    } else {
      await _controller(ref).unequip(item.slot);
    }
    if (!context.mounted) return;
    ref.read(audioServiceProvider).play(SoundId.uiTap);
    _say(
      context,
      wear
          ? l10n.petWearsItem(name, item.name)
          : l10n.petTookOffItem(name, item.name),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final economy = ref.watch(economyProvider);
    final pet = petNow(game.pet, ref.watch(clockProvider)(), economy);
    final level = levelForTotalXp(game.progress.totalXp, economy).level;
    final progress = game.progress;
    final inventory = game.inventory;

    final forSale = [
      for (final item in catalog.items)
        if (shopPrice(item.rarity, economy) != null &&
            !inventory.owns(item.id))
          item,
    ];
    final owned = [
      for (final item in catalog.items)
        if (inventory.owns(item.id)) item,
    ];
    // "epici, leggendari e mitici": the rarities the shop does not sell.
    final rollOnly = [
      for (final rarity in CosmeticRarity.values)
        if (shopPrice(rarity, economy) == null && rollOdds(rarity, economy) > 0)
          rarity.pluralLabel(l10n),
    ];

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: const EdgeInsets.all(EcoSpacing.m),
          children: [
            Wrap(
              alignment: WrapAlignment.end,
              spacing: EcoSpacing.s,
              runSpacing: EcoSpacing.s,
              children: [
                CurrencyChip(kind: CurrencyKind.coins, amount: progress.coins),
                CurrencyChip(
                    kind: CurrencyKind.tickets, amount: progress.tickets),
              ],
            ),
            const SizedBox(height: EcoSpacing.m),
            SizedBox(
              height: math.max(200.0, constraints.maxHeight * 0.3),
              child: PetView(
                pet: pet,
                plants: roomPlants(level, economy),
                semanticLabel: petSemanticLabel(pet, l10n),
              ),
            ),
            if (pet.stage == PetStage.egg) ...[
              const SizedBox(height: EcoSpacing.s),
              Text(l10n.wardrobeEggNote,
                  textAlign: TextAlign.center,
                  style:
                      textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted)),
            ],
            const SizedBox(height: EcoSpacing.l),
            _RollCard(
              economy: economy,
              tickets: progress.tickets,
              coins: progress.coins,
              onRoll: () => _roll(context, ref),
              onBuyTicket: () => _buyTicket(context, ref),
            ),
            const SizedBox(height: EcoSpacing.l),
            _SectionTitle(l10n.shopTitle),
            if (rollOnly.isNotEmpty) ...[
              Text(l10n.shopRollOnlyNote(_listInWords(rollOnly, l10n)),
                  style: textTheme.bodyMedium
                      ?.copyWith(color: EcoColors.inkMuted)),
              const SizedBox(height: EcoSpacing.s),
            ],
            if (forSale.isEmpty) Text(l10n.shopAllOwned),
            for (final item in forSale) ...[
              _ShopTile(
                item: item,
                price: shopPrice(item.rarity, economy)!,
                coins: progress.coins,
                onBuy: () => _buyItem(context, ref, item),
              ),
              const SizedBox(height: EcoSpacing.s),
            ],
            const SizedBox(height: EcoSpacing.l),
            _SectionTitle(l10n.myItemsTitle),
            if (owned.isEmpty) Text(l10n.myItemsEmpty),
            for (final slot in CosmeticSlot.values)
              if (owned.any((item) => item.slot == slot)) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      top: EcoSpacing.s, bottom: EcoSpacing.xs),
                  child: Text(slot.label(l10n), style: textTheme.titleMedium),
                ),
                for (final item in owned.where((item) => item.slot == slot)) ...[
                  _OwnedTile(
                    item: item,
                    worn: inventory.equippedBySlot[slot.id] == item.id,
                    onToggle: (wear) =>
                        _setWorn(context, ref, item, wear: wear),
                  ),
                  const SizedBox(height: EcoSpacing.s),
                ],
              ],
          ],
        ),
      ),
    );
  }
}

/// Shows what came out of the roll. Returns true for "wear it now".
///
/// Legendary and mythic items get their own heading ("Leggendario!") and a
/// bigger picture with a ring and sparkles: special, but calm (nothing
/// moves or flashes). The heading is one live region, so screen readers
/// announce it as soon as the sheet opens.
Future<bool?> _showReveal(BuildContext context, RollOutcome outcome) {
  final item = outcome.item;
  final special = item.rarity.isSpecial;
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final textTheme = Theme.of(context).textTheme;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              EcoSpacing.l, 0, EcoSpacing.l, EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                container: true,
                header: true,
                liveRegion: true,
                child: Column(
                  children: [
                    if (special)
                      Text(
                        l10n.rollRevealSpecial(item.rarity.label(l10n)),
                        style: textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    Text(
                      outcome.isNew
                          ? l10n.rollRevealNew
                          : l10n.rollRevealDuplicate,
                      style: special
                          ? textTheme.titleLarge
                          : textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EcoSpacing.m),
              Center(child: _RevealPicture(item: item)),
              const SizedBox(height: EcoSpacing.m),
              Text(item.name,
                  style: textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: EcoSpacing.xs),
              Center(child: _RarityChip(rarity: item.rarity)),
              if (!outcome.isNew) ...[
                const SizedBox(height: EcoSpacing.m),
                Text(l10n.rollRefund(outcome.refundCoins),
                    style: textTheme.bodyLarge, textAlign: TextAlign.center),
              ],
              const SizedBox(height: EcoSpacing.l),
              if (outcome.isNew) ...[
                EcoButton(
                  label: l10n.rollWearNow,
                  icon: Icons.checkroom_rounded,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: EcoSpacing.s),
              ],
              EcoButton(
                label: l10n.rollClose,
                variant: EcoButtonVariant.secondary,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// The rolled item on a disc in its rarity tint. Legendary and mythic
/// items get a bigger disc, a ring and a few still sparkles. Decorative
/// only: the name and rarity are written below it.
class _RevealPicture extends StatelessWidget {
  const _RevealPicture({required this.item});

  final CosmeticItem item;

  @override
  Widget build(BuildContext context) {
    final special = item.rarity.isSpecial;
    final disc = special ? 172.0 : 140.0;
    // Room around the disc for the sparkles, so they never cover the ring.
    final side = special ? disc + 44 : disc;
    final tint = item.rarity.tint;
    // A deeper shade of the tint (gold for legendary, pink for mythic).
    final accent = HSLColor.fromColor(tint).withLightness(0.5).toColor();
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: side,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: disc,
              height: disc,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
                border: special ? Border.all(color: accent, width: 4) : null,
              ),
            ),
            CosmeticArt(item: item, size: Size.square(disc * 0.62)),
            if (special)
              for (final (x, y, size) in [
                (-1.0, -0.86, 30.0),
                (1.0, -0.52, 22.0),
                (0.84, 1.0, 26.0),
              ])
                Align(
                  alignment: Alignment(x, y),
                  child: Icon(Icons.auto_awesome_rounded,
                      size: size, color: accent),
                ),
          ],
        ),
      ),
    );
  }
}

/// Rarity words for sentences on this screen. UI layer only, like the
/// labels in `cosmetic_labels.dart`.
extension _RarityWords on CosmeticRarity {
  /// Lowercase plural adjective for "oggetti": "Gli oggetti epici ...".
  String pluralLabel(AppLocalizations l10n) => switch (this) {
        CosmeticRarity.common => l10n.rarityCommonPlural,
        CosmeticRarity.uncommon => l10n.rarityUncommonPlural,
        CosmeticRarity.rare => l10n.rarityRarePlural,
        CosmeticRarity.epic => l10n.rarityEpicPlural,
        CosmeticRarity.legendary => l10n.rarityLegendaryPlural,
        CosmeticRarity.mythic => l10n.rarityMythicPlural,
      };

  /// The name inside a sentence ("non comune 25 percento").
  String spokenLabel(AppLocalizations l10n) => label(l10n).toLowerCase();

  /// Legendary and mythic: the reveal makes a little more of them.
  bool get isSpecial => index >= CosmeticRarity.legendary.index;
}

/// "a, b e c": a list in plain words, with "e" before the last part.
String _listInWords(List<String> parts, AppLocalizations l10n) {
  if (parts.length < 2) return parts.join();
  return l10n.listLastItem(
      parts.sublist(0, parts.length - 1).join(', '), parts.last);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.xs),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

/// The reward roll: odds and duplicate rule in plain words, then buttons.
class _RollCard extends StatelessWidget {
  const _RollCard({
    required this.economy,
    required this.tickets,
    required this.coins,
    required this.onRoll,
    required this.onBuyTicket,
  });

  final EconomyConfig economy;
  final int tickets;
  final int coins;
  final VoidCallback onRoll;
  final VoidCallback onBuyTicket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    const rarities = CosmeticRarity.values;
    int odds(CosmeticRarity r) => rollOdds(r, economy);
    // "comune 40 percento, non comune 25 percento, ..."
    final spokenOdds = [
      for (final rarity in rarities)
        l10n.rollOddsSpokenItem(rarity.spokenLabel(l10n), odds(rarity)),
    ].join(', ');
    // "comune 15, non comune 25, ..."
    final refunds = [
      for (final rarity in rarities)
        l10n.rollRefundItem(
            rarity.spokenLabel(l10n), duplicateRefund(rarity, economy)),
    ].join(', ');

    return EcoCard(
      color: EcoColors.coin.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l10n.rollTitle, style: textTheme.titleLarge),
          ),
          const SizedBox(height: EcoSpacing.xs),
          Text(l10n.rollBody, style: textTheme.bodyMedium),
          const SizedBox(height: EcoSpacing.s),
          // One screen-reader item with all the odds (the chips say "%").
          Semantics(
            container: true,
            label: l10n.rollOddsSemantics(spokenOdds),
            child: ExcludeSemantics(
              child: Wrap(
                spacing: EcoSpacing.s,
                runSpacing: EcoSpacing.s,
                children: [
                  for (final rarity in rarities)
                    _RarityChip(
                      rarity: rarity,
                      text: l10n.rollOddsLine(
                          rarity.label(l10n), odds(rarity)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: EcoSpacing.s),
          Text(l10n.rollDuplicateRule(refunds), style: textTheme.bodyMedium),
          const SizedBox(height: EcoSpacing.m),
          EcoButton(
            label: l10n.rollAction,
            icon: Icons.confirmation_number_rounded,
            expand: true,
            onPressed: tickets > 0 ? onRoll : null,
          ),
          if (tickets == 0) ...[
            const SizedBox(height: EcoSpacing.s),
            Text(l10n.rollNoTickets, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: EcoSpacing.s),
          EcoButton(
            label: l10n.buyTicketAction(economy.ticketPriceInCoins),
            icon: Icons.monetization_on_rounded,
            variant: EcoButtonVariant.secondary,
            expand: true,
            onPressed: coins >= economy.ticketPriceInCoins ? onBuyTicket : null,
          ),
        ],
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  const _RarityChip({required this.rarity, this.text});

  final CosmeticRarity rarity;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: EcoSpacing.s + EcoSpacing.xs, vertical: EcoSpacing.xs),
      decoration: BoxDecoration(
        color: rarity.tint,
        borderRadius: BorderRadius.circular(EcoSpacing.radiusPill),
      ),
      child: Text(text ?? rarity.label(AppLocalizations.of(context)),
          style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

/// Picture, name and "rarity · slot" of an item.
class _ItemHeader extends StatelessWidget {
  const _ItemHeader({required this.item});

  final CosmeticItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        CosmeticThumbnail(item: item),
        const SizedBox(width: EcoSpacing.s + EcoSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: textTheme.titleMedium),
              Text(
                l10n.itemDetails(
                    item.rarity.label(l10n), item.slot.label(l10n)),
                style:
                    textTheme.bodyMedium?.copyWith(color: EcoColors.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShopTile extends StatelessWidget {
  const _ShopTile({
    required this.item,
    required this.price,
    required this.coins,
    required this.onBuy,
  });

  final CosmeticItem item;
  final int price;
  final int coins;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final affordable = coins >= price;
    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemHeader(item: item),
          const SizedBox(height: EcoSpacing.s),
          EcoButton(
            label: l10n.shopBuyAction(price),
            icon: Icons.shopping_bag_rounded,
            variant: EcoButtonVariant.secondary,
            expand: true,
            onPressed: affordable ? onBuy : null,
          ),
          if (!affordable) ...[
            const SizedBox(height: EcoSpacing.xs),
            Text(
              l10n.shopNotEnoughCoins(price - coins),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: EcoColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _OwnedTile extends StatelessWidget {
  const _OwnedTile({
    required this.item,
    required this.worn,
    required this.onToggle,
  });

  final CosmeticItem item;
  final bool worn;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EcoCard(
      color: worn ? EcoColors.primaryContainer : EcoColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemHeader(item: item),
          const SizedBox(height: EcoSpacing.s),
          // Screen readers hear "Indossato" / "Indossa" as a toggle.
          Semantics(
            toggled: worn,
            child: EcoButton(
              label: worn ? l10n.unequipAction : l10n.equipAction,
              icon: worn ? Icons.check_circle_rounded : Icons.checkroom_rounded,
              variant:
                  worn ? EcoButtonVariant.secondary : EcoButtonVariant.primary,
              expand: true,
              onPressed: () => onToggle(!worn),
            ),
          ),
        ],
      ),
    );
  }
}
