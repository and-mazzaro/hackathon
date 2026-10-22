/// Environmental topics the player can be interested in.
///
/// [id] is what goes into the save file and content files. Never rename an
/// id: old saves would lose that interest. Renaming the enum value is fine.
enum EcoTopic {
  recycling('recycling'),
  climate('climate'),
  oceans('oceans'),
  biodiversity('biodiversity'),
  forests('forests'),
  energy('energy'),
  water('water'),
  transport('transport'),
  consumption('consumption'),
  innovation('innovation');

  const EcoTopic(this.id);

  final String id;

  /// Returns null for unknown ids (e.g. a topic removed in a later version).
  static EcoTopic? fromId(String id) {
    for (final topic in values) {
      if (topic.id == id) return topic;
    }
    return null;
  }
}
