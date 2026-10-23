/// The room look the player picked in Profile → "Aspetto".
///
/// [auto] follows the phone's clock (see `timeOfDayFor`).
enum LookMode {
  auto('auto'),
  day('day'),
  afternoon('afternoon'),
  night('night');

  const LookMode(this.id);

  /// Stable id used in the save file.
  final String id;

  /// Unknown or missing ids (older saves) fall back to [auto].
  static LookMode fromId(Object? id) => LookMode.values.firstWhere(
        (mode) => mode.id == id,
        orElse: () => LookMode.auto,
      );
}
