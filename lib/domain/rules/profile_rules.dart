import 'package:characters/characters.dart';

const maxNicknameLength = 20;

/// Cleans what the player typed as a nickname.
///
/// Removes invisible control characters, turns runs of spaces into one,
/// trims, and keeps at most [maxNicknameLength] visible characters
/// (an emoji counts as one). Returns null when nothing is left.
String? normalizeNickname(String? raw) {
  if (raw == null) return null;
  final cleaned = raw
      .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.isEmpty) return null;
  return cleaned.characters.take(maxNicknameLength).toString().trimRight();
}
