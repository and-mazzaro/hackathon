import 'package:material_ui/material_ui.dart';

import '../../domain/models/eco_topic.dart';
import '../../domain/models/player_profile.dart';
import '../../l10n/app_localizations.dart';

/// Italian names and icons for topics. Kept in the UI layer: the domain
/// only knows stable ids, the screens decide how they look.
extension EcoTopicLabels on EcoTopic {
  String label(AppLocalizations l10n) => switch (this) {
        EcoTopic.recycling => l10n.topicRecycling,
        EcoTopic.climate => l10n.topicClimate,
        EcoTopic.oceans => l10n.topicOceans,
        EcoTopic.biodiversity => l10n.topicBiodiversity,
        EcoTopic.forests => l10n.topicForests,
        EcoTopic.energy => l10n.topicEnergy,
        EcoTopic.water => l10n.topicWater,
        EcoTopic.transport => l10n.topicTransport,
        EcoTopic.consumption => l10n.topicConsumption,
        EcoTopic.innovation => l10n.topicInnovation,
      };

  IconData get icon => switch (this) {
        EcoTopic.recycling => Icons.recycling_rounded,
        EcoTopic.climate => Icons.thermostat_rounded,
        EcoTopic.oceans => Icons.waves_rounded,
        EcoTopic.biodiversity => Icons.pets_rounded,
        EcoTopic.forests => Icons.forest_rounded,
        EcoTopic.energy => Icons.solar_power_rounded,
        EcoTopic.water => Icons.water_drop_rounded,
        EcoTopic.transport => Icons.directions_bike_rounded,
        EcoTopic.consumption => Icons.shopping_basket_rounded,
        EcoTopic.innovation => Icons.lightbulb_rounded,
      };
}

extension AgeRangeLabels on AgeRange {
  String label(AppLocalizations l10n) => switch (this) {
        AgeRange.age13to15 => l10n.ageRange13to15,
        AgeRange.age16to18 => l10n.ageRange16to18,
        AgeRange.age19to22 => l10n.ageRange19to22,
        AgeRange.age23to26 => l10n.ageRange23to26,
        AgeRange.over26 => l10n.ageRangeOver26,
      };
}
