import 'dart:math';

import 'package:ecoquest/domain/models/game_state.dart';
import 'package:ecoquest/domain/models/territory.dart';
import 'package:ecoquest/domain/rules/territory_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/territory_fixtures.dart';

final _now = DateTime(2026, 10, 22, 10);

void main() {
  group('aqiBand', () {
    test('follows the EEA bands, boundaries go to the better band', () {
      expect(aqiBand(0), AqiBand.good);
      expect(aqiBand(20), AqiBand.good);
      expect(aqiBand(21), AqiBand.fair);
      expect(aqiBand(40), AqiBand.fair);
      expect(aqiBand(55), AqiBand.moderate);
      expect(aqiBand(61), AqiBand.poor);
      expect(aqiBand(90), AqiBand.veryPoor);
      expect(aqiBand(101), AqiBand.extremelyPoor);
      expect(AqiBand.good.label, 'Buona');
      expect(AqiBand.extremelyPoor.label, 'Estremamente scadente');
    });
  });

  group('territoryQuestions', () {
    List<String> check(List<TownReading> readings,
        [TerritoryTown town = TerritoryTown.schio]) {
      final questions = territoryQuestions(readings, town, _now, Random(1));
      expect(questions, hasLength(3));
      for (final q in questions) {
        expect(q.options, hasLength(4));
        expect(q.options.toSet(), hasLength(4));
        expect(q.question.length, lessThanOrEqualTo(200));
        expect(q.options.every((o) => o.length <= 80), isTrue);
        expect(q.explanation.length, lessThanOrEqualTo(300));
        expect(q.source.name, territorySourceName);
        expect(q.source.verifiedOn, territoryTime);
      }
      expect(questions.map((q) => q.id),
          ['territory_20261022_1', 'territory_20261022_2', 'territory_20261022_3']);
      expect(questions.map((q) => q.difficulty), [1, 2, 2]);
      return [for (final q in questions) q.correctOption];
    }

    test('answers are computed from the data', () {
      final answers = check(testTerritoryReadings());
      expect(answers[0], 'Buona'); // Schio 20
      expect(answers[1], 'Sotto il limite'); // 5,5 < 50
      expect(answers[2], 'Valdagno'); // 18 is the lowest
    });

    test('every band and PM10 case gives the right answer', () {
      for (final aqi in [0, 15, 30, 50, 70, 90, 150]) {
        for (final pm10 in [10.0, 50.0, 50.04, 80.0]) {
          final readings = [
            townReading(TerritoryTown.schio, aqi: aqi, pm10: pm10),
            townReading(TerritoryTown.thiene, aqi: aqi),
            townReading(TerritoryTown.valdagno, aqi: aqi + 1),
          ];
          final answers = check(readings);
          expect(answers[0], aqiBand(aqi).label);
          final rounded = double.parse(pm10.toStringAsFixed(1));
          expect(
              answers[1],
              rounded < 50
                  ? 'Sotto il limite'
                  : rounded > 50
                      ? 'Sopra il limite'
                      : 'Esattamente pari al limite');
          // Schio and Thiene tie for the lowest index.
          expect(answers[2], 'Sono a pari merito');
        }
      }
    });

    test('uses the chosen town', () {
      final questions = territoryQuestions(
          testTerritoryReadings(), TerritoryTown.thiene, _now, Random(1));
      expect(questions.first.question, contains('Thiene'));
      expect(questions.first.correctOption, 'Discreta'); // 35
      expect(questions[1].question, contains('12,0'));
    });

    test('no reading for the town: no questions', () {
      expect(
          territoryQuestions(const [], TerritoryTown.schio, _now, Random(1)),
          isEmpty);
    });
  });

  group('territoryTip', () {
    test('picks one concrete action from the data', () {
      expect(territoryTip(townReading(TerritoryTown.schio)).id, 'good_air');
      expect(territoryTip(townReading(TerritoryTown.schio)).text,
          'Aria buona: oggi vai a scuola in bici o a piedi');
      expect(territoryTip(townReading(TerritoryTown.schio, aqi: 75)).id,
          'bad_air');
      expect(
          territoryTip(townReading(TerritoryTown.schio, precipitation: 1.2)).id,
          'rain');
      expect(territoryTip(townReading(TerritoryTown.schio, temperature: 2)).id,
          'cold');
      expect(territoryTip(townReading(TerritoryTown.schio, temperature: 31)).id,
          'hot');
      expect(territoryTip(townReading(TerritoryTown.schio, aqi: 50)).id,
          'moderate_air');
      // Poor air wins over rain.
      expect(
          territoryTip(townReading(TerritoryTown.schio,
                  aqi: 85, precipitation: 3))
              .id,
          'bad_air');
    });
  });

  test('claim id is per day', () {
    expect(territoryClaimId(_now), 'territory:2026-10-22');
  });

  group('save', () {
    test('old saves without "territory" load with Schio and no cache', () {
      final old = GameState.initial(now: _now).toJson()..remove('territory');
      final state = GameState.fromJson(old, now: _now);
      expect(state.territory.town, TerritoryTown.schio);
      expect(state.territory.cached, isEmpty);
    });

    test('town and cached readings survive a save round trip', () {
      final state = GameState.initial(now: _now).copyWith(
          territory: TerritoryState(
              town: TerritoryTown.valdagno, cached: testTerritoryReadings()));
      final loaded = GameState.fromJson(state.toJson(), now: _now);
      expect(loaded.territory.town, TerritoryTown.valdagno);
      expect(loaded.territory.cached, hasLength(3));
      expect(loaded.territory.cached[1].aqi, 35);
      expect(loaded.territory.cached[1].pm10, 12);
      expect(loaded.territory.cached[0].time, territoryTime);
    });
  });
}
