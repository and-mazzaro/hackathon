import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sound_id.dart';

/// Which file plays for each [SoundId].
///
/// Only files with a known licence are listed (see
/// `assets/audio/ATTRIBUTION.md`). Ids without a file stay silent until a
/// licensed sound is added here; `missing` lists them.
class AudioCatalog {
  const AudioCatalog(this._assets);

  final Map<SoundId, String> _assets;

  /// The sounds shipped with EcoQuest today.
  static const ecoQuest = AudioCatalog({
    SoundId.ambienceSea: 'assets/audio/ambience/sea_waves.mp3',
  });

  /// The asset path (e.g. `assets/audio/ui/tap.ogg`), or null if missing.
  String? assetFor(SoundId id) => _assets[id];

  Map<SoundId, String> get assets => Map.unmodifiable(_assets);

  List<SoundId> get missing =>
      [for (final id in SoundId.values) if (!_assets.containsKey(id)) id];
}

final audioCatalogProvider = Provider<AudioCatalog>((ref) => AudioCatalog.ecoQuest);
