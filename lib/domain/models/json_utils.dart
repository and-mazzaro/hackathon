/// Small helpers for reading the save file safely.
///
/// Missing fields fall back to a default, so a new field can be added later
/// without breaking older saves. A field with the wrong type throws a
/// [FormatException], which the save system treats as a corrupt file.
library;

typedef Json = Map<String, Object?>;

int readInt(Json json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  throw FormatException('"$key" should be a number, found $value');
}

String? readString(Json json, String key) {
  final value = json[key];
  if (value == null || value is String) return value as String?;
  throw FormatException('"$key" should be text, found $value');
}

bool readBool(Json json, String key, {bool fallback = false}) {
  final value = json[key];
  if (value == null) return fallback;
  if (value is bool) return value;
  throw FormatException('"$key" should be true/false, found $value');
}

DateTime readDate(Json json, String key, {required DateTime fallback}) {
  final value = readString(json, key);
  if (value == null) return fallback;
  return DateTime.parse(value);
}

List<String> readStringList(Json json, String key) {
  final value = json[key];
  if (value == null) return const [];
  if (value is List) return value.map((e) => e as String).toList();
  throw FormatException('"$key" should be a list, found $value');
}

Json readObject(Json json, String key) {
  final value = json[key];
  if (value == null) return const {};
  if (value is Map) return value.cast<String, Object?>();
  throw FormatException('"$key" should be an object, found $value');
}
