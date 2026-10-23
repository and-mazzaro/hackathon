import '../../domain/models/eco_topic.dart';
import '../../domain/models/game_state.dart';
import '../../l10n/app_localizations.dart';
import 'profile_labels.dart';

/// Title and text of the daily reminder: the pet's name and, when the
/// player has one, their first interest. Never guilt ("ti aspetta", not
/// "sta male").
(String title, String body) reminderMessage(
    GameState game, AppLocalizations l10n) {
  final title =
      l10n.reminderNotificationTitle(game.pet.name ?? l10n.reminderPetFallback);
  final interests = EcoTopic.values.where(game.profile.interests.contains);
  if (interests.isEmpty) return (title, l10n.reminderNotificationBodyGeneric);
  final topic = interests.first.label(l10n);
  final lower = topic.substring(0, 1).toLowerCase() + topic.substring(1);
  return (title, l10n.reminderNotificationBody(lower));
}
