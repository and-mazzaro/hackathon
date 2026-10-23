import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/game_controller.dart';
import '../../domain/models/territory.dart';

/// Reads live open data for the Alto Vicentino towns from Open-Meteo
/// (no API key; air quality from CAMS Europe, CC BY 4.0).
class TerritoryClient {
  TerritoryClient(this._http, {this.timeout = const Duration(seconds: 8)});

  final http.Client _http;
  final Duration timeout;

  static const _towns = TerritoryTown.values;

  static String get _coordinates =>
      'latitude=${_towns.map((t) => t.latitude).join(',')}'
      '&longitude=${_towns.map((t) => t.longitude).join(',')}';

  static Uri get airUri => Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality?$_coordinates'
      '&current=european_aqi,pm10,pm2_5,nitrogen_dioxide,ozone'
      '&timezone=Europe%2FRome');

  static Uri get weatherUri => Uri.parse(
      'https://api.open-meteo.com/v1/forecast?$_coordinates'
      '&current=temperature_2m,precipitation,weather_code,wind_speed_10m'
      '&timezone=Europe%2FRome');

  /// One reading per town, in [TerritoryTown] order.
  /// Throws on network errors, timeouts or unexpected JSON.
  Future<List<TownReading>> fetch() async {
    final responses = await Future.wait([
      _http.get(airUri).timeout(timeout),
      _http.get(weatherUri).timeout(timeout),
    ]);
    for (final response in responses) {
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}');
      }
    }
    return parseReadings(
      air: jsonDecode(responses[0].body),
      weather: jsonDecode(responses[1].body),
    );
  }

  /// Joins the two Open-Meteo answers (JSON arrays, one object per town).
  static List<TownReading> parseReadings({
    required Object? air,
    required Object? weather,
  }) {
    if (air is! List || weather is! List) {
      throw const FormatException('Expected one entry per town');
    }
    if (air.length < _towns.length || weather.length < _towns.length) {
      throw const FormatException('Some towns are missing');
    }
    Map<String, Object?> current(Object? entry) {
      if (entry is Map && entry['current'] is Map) {
        return (entry['current'] as Map).cast<String, Object?>();
      }
      throw const FormatException('Missing "current"');
    }

    double number(Map<String, Object?> json, String key) {
      final value = json[key];
      if (value is num) return value.toDouble();
      throw FormatException('Missing "$key"');
    }

    return [
      for (var i = 0; i < _towns.length; i++)
        () {
          final a = current(air[i]);
          final w = current(weather[i]);
          final time = DateTime.tryParse('${a['time']}');
          if (time == null) throw const FormatException('Missing "time"');
          return TownReading(
            town: _towns[i],
            time: time,
            aqi: number(a, 'european_aqi').round(),
            pm10: number(a, 'pm10'),
            pm25: number(a, 'pm2_5'),
            no2: number(a, 'nitrogen_dioxide'),
            ozone: number(a, 'ozone'),
            temperature: number(w, 'temperature_2m'),
            precipitation: number(w, 'precipitation'),
            weatherCode: number(w, 'weather_code').round(),
            windSpeed: number(w, 'wind_speed_10m'),
          );
        }(),
    ];
  }
}

/// What the territory card shows.
class TerritoryData {
  const TerritoryData({required this.readings, required this.live});

  final List<TownReading> readings;

  /// False when these are the last saved readings (network failed).
  final bool live;
}

/// Live data, else the cached readings, else null ("Dati non disponibili").
/// Never throws.
Future<TerritoryData?> loadTerritory(
  TerritoryClient client,
  List<TownReading> cached,
) async {
  try {
    return TerritoryData(readings: await client.fetch(), live: true);
  } catch (_) {
    if (cached.isEmpty) return null;
    return TerritoryData(readings: cached, live: false);
  }
}

/// The HTTP client (tests override it with http's MockClient).
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final territoryClientProvider =
    Provider<TerritoryClient>((ref) => TerritoryClient(ref.watch(httpClientProvider)));

/// Today's territory data. Fresh readings are also saved, so they are
/// still there offline. Widget tests override this with fixed readings.
final territoryProvider = FutureProvider<TerritoryData?>((ref) async {
  final game = await ref.read(gameControllerProvider.future);
  final data = await loadTerritory(
      ref.read(territoryClientProvider), game.territory.cached);
  if (data != null && data.live) {
    await ref
        .read(gameControllerProvider.notifier)
        .cacheTerritoryReadings(data.readings);
  }
  return data;
});
