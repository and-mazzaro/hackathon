import 'json_utils.dart';

/// The Alto Vicentino towns with live open data ("Il mio territorio").
///
/// [id] goes into the save: never rename it.
enum TerritoryTown {
  schio('schio', 'Schio', 45.713, 11.355),
  thiene('thiene', 'Thiene', 45.708, 11.476),
  valdagno('valdagno', 'Valdagno', 45.647, 11.300);

  const TerritoryTown(this.id, this.label, this.latitude, this.longitude);

  final String id;

  /// Proper name of the town (the same in every language).
  final String label;
  final double latitude;
  final double longitude;

  static TerritoryTown fromId(Object? id) {
    for (final town in values) {
      if (town.id == id) return town;
    }
    return schio;
  }
}

/// One live reading for one town: air quality (CAMS Europe) and weather.
class TownReading {
  const TownReading({
    required this.town,
    required this.time,
    required this.aqi,
    required this.pm10,
    required this.pm25,
    required this.no2,
    required this.ozone,
    required this.temperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  final TerritoryTown town;

  /// Local time of the measurement (Europe/Rome).
  final DateTime time;

  /// European Air Quality Index (0 = best).
  final int aqi;

  /// Micrograms per cubic metre.
  final double pm10;
  final double pm25;
  final double no2;
  final double ozone;

  /// Degrees Celsius.
  final double temperature;

  /// Millimetres in the last hour.
  final double precipitation;
  final int weatherCode;

  /// Km/h.
  final double windSpeed;

  bool get isRaining => precipitation > 0;

  Json toJson() => {
        'town': town.id,
        'time': time.toIso8601String(),
        'aqi': aqi,
        'pm10': pm10,
        'pm25': pm25,
        'no2': no2,
        'ozone': ozone,
        'temperature': temperature,
        'precipitation': precipitation,
        'weatherCode': weatherCode,
        'windSpeed': windSpeed,
      };

  /// Returns null when the entry is incomplete.
  static TownReading? tryFromJson(Json json) {
    final time = DateTime.tryParse(readString(json, 'time') ?? '');
    final aqi = json['aqi'];
    if (time == null || aqi is! num) return null;
    double d(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return TownReading(
      town: TerritoryTown.fromId(json['town']),
      time: time,
      aqi: aqi.round(),
      pm10: d('pm10'),
      pm25: d('pm25'),
      no2: d('no2'),
      ozone: d('ozone'),
      temperature: d('temperature'),
      precipitation: d('precipitation'),
      weatherCode: (json['weatherCode'] as num?)?.round() ?? 0,
      windSpeed: d('windSpeed'),
    );
  }
}

/// What "Il mio territorio" keeps in the save: the chosen town and the last
/// good readings (shown when the network is down). Added with the
/// territory card: older saves get Schio and no cached readings.
class TerritoryState {
  const TerritoryState({
    this.town = TerritoryTown.schio,
    this.cached = const [],
  });

  static const defaults = TerritoryState();

  final TerritoryTown town;
  final List<TownReading> cached;

  TerritoryState copyWith({TerritoryTown? town, List<TownReading>? cached}) =>
      TerritoryState(town: town ?? this.town, cached: cached ?? this.cached);

  Json toJson() => {
        'town': town.id,
        'cached': [for (final r in cached) r.toJson()],
      };

  factory TerritoryState.fromJson(Json json) {
    final list = json['cached'];
    final cached = <TownReading>[];
    if (list is List) {
      for (final item in list) {
        if (item is! Map) continue;
        final reading = TownReading.tryFromJson(item.cast<String, Object?>());
        if (reading != null) cached.add(reading);
      }
    }
    return TerritoryState(town: TerritoryTown.fromId(json['town']), cached: cached);
  }
}
