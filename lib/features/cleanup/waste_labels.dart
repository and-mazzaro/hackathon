import 'package:material_ui/material_ui.dart';

import '../../domain/models/waste_item.dart';
import '../../l10n/app_localizations.dart';

/// Names, icons and colours of the bins (UI layer only).
///
/// Bin colours differ between Italian municipalities, so these are just
/// distinct tints for the game; the name on each bin is what counts.
extension WasteCategoryLabels on WasteCategory {
  String label(AppLocalizations l10n) => switch (this) {
        WasteCategory.plasticMetal => l10n.binPlasticMetal,
        WasteCategory.paper => l10n.binPaper,
        WasteCategory.organic => l10n.binOrganic,
        WasteCategory.glass => l10n.binGlass,
        WasteCategory.residual => l10n.binResidual,
      };

  IconData get icon => switch (this) {
        WasteCategory.plasticMetal => Icons.recycling_rounded,
        WasteCategory.paper => Icons.description_rounded,
        WasteCategory.organic => Icons.compost_rounded,
        WasteCategory.glass => Icons.wine_bar_rounded,
        WasteCategory.residual => Icons.delete_rounded,
      };

  /// Light tint behind dark text (contrast ≥ 4.5:1 with the ink colour).
  Color get tint => switch (this) {
        WasteCategory.plasticMetal => const Color(0xFFFFE9A8),
        WasteCategory.paper => const Color(0xFFCFE3FA),
        WasteCategory.organic => const Color(0xFFE8D7C3),
        WasteCategory.glass => const Color(0xFFCDEFD9),
        WasteCategory.residual => const Color(0xFFE2E4E3),
      };
}

/// Icon for a waste item's "icon" key from the content file.
/// Unknown keys fall back to a generic icon, so new content never breaks.
IconData wasteIcon(String key) => switch (key) {
      'bottle' => Icons.local_drink_rounded,
      'can' => Icons.sports_bar_rounded,
      'tray' => Icons.lunch_dining_rounded,
      'bag' => Icons.shopping_bag_rounded,
      'pot' => Icons.icecream_rounded,
      'cup' => Icons.coffee_rounded,
      'newspaper' => Icons.newspaper_rounded,
      'sheet' => Icons.description_rounded,
      'box' => Icons.inventory_2_rounded,
      'pizza_box' => Icons.local_pizza_rounded,
      'receipt' => Icons.receipt_long_rounded,
      'carton' => Icons.takeout_dining_rounded,
      'jar' => Icons.kitchen_rounded,
      'glass' => Icons.wine_bar_rounded,
      'food' => Icons.restaurant_rounded,
      'fruit' => Icons.spa_rounded,
      'coffee_grounds' => Icons.coffee_maker_rounded,
      'eggshell' => Icons.egg_alt_rounded,
      'tissue' => Icons.face_rounded,
      'toy' => Icons.toys_rounded,
      'pen' => Icons.edit_rounded,
      'cd' => Icons.album_rounded,
      'toothbrush' => Icons.brush_rounded,
      'diaper' => Icons.baby_changing_station_rounded,
      'cutlery' => Icons.flatware_rounded,
      'plate' => Icons.dinner_dining_rounded,
      _ => Icons.delete_outline_rounded,
    };
