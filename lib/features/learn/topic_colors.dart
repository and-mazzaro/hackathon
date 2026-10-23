import 'package:material_ui/material_ui.dart';

import '../../app/theme/eco_colors.dart';
import '../../domain/models/eco_topic.dart';

/// One colour per topic, for the Learn tiles and the quiz header.
///
/// Used only behind white icons and as bar/tint colours, never for text:
/// every colour has at least 3:1 against white (non-text contrast).
extension EcoTopicColors on EcoTopic {
  Color get color => switch (this) {
        EcoTopic.recycling => const Color(0xFF2E8B57),
        EcoTopic.climate => const Color(0xFFD35400),
        EcoTopic.oceans => const Color(0xFF1C7CB8),
        EcoTopic.biodiversity => const Color(0xFF8E44AD),
        EcoTopic.forests => const Color(0xFF2F7D32),
        EcoTopic.energy => const Color(0xFFB7700A),
        EcoTopic.water => const Color(0xFF00838F),
        EcoTopic.transport => const Color(0xFFC0392B),
        EcoTopic.consumption => const Color(0xFFC2185B),
        EcoTopic.innovation => const Color(0xFF5C6BC0),
      };

  /// A light, opaque tint for tile backgrounds. Ink text on it stays
  /// above 9:1.
  Color get tint =>
      Color.alphaBlend(color.withValues(alpha: 0.14), EcoColors.surface);
}
