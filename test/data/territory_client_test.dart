import 'dart:convert';

import 'package:ecoquest/data/save/in_memory_save_repository.dart';
import 'package:ecoquest/data/save/save_repository.dart';
import 'package:ecoquest/data/territory/territory_client.dart';
import 'package:ecoquest/domain/game_controller.dart';
import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/territory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/territory_fixtures.dart';

const _air = [
  {
    'latitude': 45.7,
    'current': {
      'time': '2026-10-24T01:00',
      'european_aqi': 20,
      'pm10': 5.5,
      'pm2_5': 4.9,
      'nitrogen_dioxide': 6.1,
      'ozone': 58.0,
    },
  },
  {
    'current': {
      'time': '2026-10-24T01:00',
      'european_aqi': 33,
      'pm10': 9.0,
      'pm2_5': 7.0,
      'nitrogen_dioxide': 10.0,
      'ozone': 40.0,
    },
  },
  {
    'current': {
      'time': '2026-10-24T01:00',
      'european_aqi': 17,
      'pm10': 3.0,
      'pm2_5': 2.0,
      'nitrogen_dioxide': 2.0,
      'ozone': 60.0,
    },
  },
];

Map<String, Object> _weatherEntry(double temp) => {
      'current': {
        'time': '2026-10-24T01:00',
        'temperature_2m': temp,
        'precipitation': 0.0,
        'weather_code': 3,
        'wind_speed_10m': 4.5,
      },
    };

final _weather = [_weatherEntry(10.3), _weatherEntry(11), _weatherEntry(8)];

MockClient _openMeteo() => MockClient((request) async {
      if (request.url.host.startsWith('air-quality')) {
        expect(request.url.queryParameters['current'], contains('european_aqi'));
        return http.Response(jsonEncode(_air), 200);
      }
      expect(request.url.queryParameters['latitude'], '45.713,45.708,45.647');
      return http.Response(jsonEncode(_weather), 200);
    });

void main() {
  test('parses both Open-Meteo answers into one reading per town', () async {
    final readings = await TerritoryClient(_openMeteo()).fetch();
    expect(readings.map((r) => r.town), TerritoryTown.values);
    final schio = readings.first;
    expect(schio.time, DateTime(2026, 10, 24, 1));
    expect(schio.aqi, 20);
    expect(schio.pm10, 5.5);
    expect(schio.pm25, 4.9);
    expect(schio.no2, 6.1);
    expect(schio.ozone, 58);
    expect(schio.temperature, 10.3);
    expect(schio.weatherCode, 3);
    expect(readings[1].aqi, 33);
    expect(readings[2].temperature, 8);
  });

  test('bad JSON or HTTP errors throw', () async {
    final broken = MockClient((request) async => http.Response('{}', 200));
    await expectLater(TerritoryClient(broken).fetch(), throwsFormatException);
    final down = MockClient((request) async => http.Response('', 503));
    await expectLater(
        TerritoryClient(down).fetch(), throwsA(isA<http.ClientException>()));
  });

  group('loadTerritory', () {
    final failing = TerritoryClient(
        MockClient((request) async => throw http.ClientException('offline')));

    test('live data when the network works', () async {
      final data = await loadTerritory(TerritoryClient(_openMeteo()), const []);
      expect(data!.live, isTrue);
      expect(data.readings, hasLength(3));
    });

    test('network error: the cached readings', () async {
      final data = await loadTerritory(failing, testTerritoryReadings());
      expect(data!.live, isFalse);
      expect(data.readings.first.aqi, 20);
    });

    test('network error and no cache: unavailable (null)', () async {
      expect(await loadTerritory(failing, const []), isNull);
    });

    test('timeout counts as an error', () async {
      final slow = TerritoryClient(
        MockClient((request) => Future.delayed(
            const Duration(seconds: 1), () => http.Response('[]', 200))),
        timeout: const Duration(milliseconds: 10),
      );
      expect(await loadTerritory(slow, const []), isNull);
    });
  });

  group('territoryProvider', () {
    final now = DateTime(2026, 10, 24, 1, 30);

    ProviderContainer container(http.Client client, InMemorySaveRepository repo) {
      final c = ProviderContainer(overrides: [
        saveRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => now),
        httpClientProvider.overrideWithValue(client),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('live readings are kept in the save for offline use', () async {
      final repo = InMemorySaveRepository(GameState.initial(now: now));
      final data =
          await container(_openMeteo(), repo).read(territoryProvider.future);
      expect(data!.live, isTrue);
      expect(repo.saved!.territory.cached, hasLength(3));
      expect(repo.saved!.territory.cached.first.aqi, 20);
    });

    test('offline: the readings saved last time', () async {
      final saved = GameState.initial(now: now);
      final repo = InMemorySaveRepository(saved.copyWith(
          territory: saved.territory.copyWith(cached: testTerritoryReadings())));
      final offline = MockClient(
          (request) async => throw http.ClientException('offline'));
      final data =
          await container(offline, repo).read(territoryProvider.future);
      expect(data!.live, isFalse);
      expect(data.readings[1].aqi, 35);
    });
  });
}
