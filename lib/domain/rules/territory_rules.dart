import 'dart:math';

import '../models/activity_log.dart';
import '../models/eco_topic.dart';
import '../models/quiz_question.dart';
import '../models/territory.dart';

// "Il mio territorio": questions and a daily tip computed from live open
// data (Open-Meteo, air quality from CAMS Europe). Pure Dart, no Flutter.
//
// The Italian texts here are generated CONTENT (like the quiz content file),
// not UI strings: UI strings stay in app_it.arb.

/// European Air Quality Index bands (EEA), best to worst.
enum AqiBand {
  good('Buona'),
  fair('Discreta'),
  moderate('Moderata'),
  poor('Scadente'),
  veryPoor('Molto scadente'),
  extremelyPoor('Estremamente scadente');

  const AqiBand(this.label);

  /// Italian label, also used as a quiz answer.
  final String label;

  /// True from "Scadente" up: time for the "heavy air" tip.
  bool get isPoor => index >= AqiBand.poor.index;
}

/// 0–20 Buona, 20–40 Discreta, 40–60 Moderata, 60–80 Scadente,
/// 80–100 Molto scadente, above 100 Estremamente scadente.
/// A value on a boundary belongs to the better band.
AqiBand aqiBand(int aqi) {
  if (aqi <= 20) return AqiBand.good;
  if (aqi <= 40) return AqiBand.fair;
  if (aqi <= 60) return AqiBand.moderate;
  if (aqi <= 80) return AqiBand.poor;
  if (aqi <= 100) return AqiBand.veryPoor;
  return AqiBand.extremelyPoor;
}

/// EU daily limit for PM10 (Directive 2008/50/EC), in µg/m³.
const pm10DailyLimit = 50.0;

/// Shown with every territory question.
const territorySourceName = 'Open-Meteo / CAMS Europe';
const territorySourceUrl = 'https://open-meteo.com/en/docs/air-quality-api';

/// Claim id for the daily "L'ho fatto!" reward.
String territoryClaimId(DateTime now) => 'territory:${dayKey(now)}';

/// The reading for [town], or null when it is missing.
TownReading? readingFor(List<TownReading> readings, TerritoryTown town) {
  for (final reading in readings) {
    if (reading.town == town) return reading;
  }
  return null;
}

/// "5,5" (Italian decimal comma, one decimal).
String formatMeasure(double value) =>
    value.toStringAsFixed(1).replaceAll('.', ',');

/// Up to 3 questions whose answers are computed from [readings]:
/// the EAQI band of [chosenTown], its PM10 against the EU limit, and which
/// town has the cleanest air. Empty when [chosenTown] has no reading.
///
/// [random] is accepted for symmetry with the other quiz pickers; the quiz
/// session already shuffles the options.
List<QuizQuestion> territoryQuestions(
  List<TownReading> readings,
  TerritoryTown chosenTown,
  DateTime now,
  Random random,
) {
  final reading = readingFor(readings, chosenTown);
  if (reading == null) return const [];
  final day = dayKey(now).replaceAll('-', '');
  final source = ContentSource(
    name: territorySourceName,
    url: territorySourceUrl,
    verifiedOn: reading.time,
  );
  final town = chosenTown.label;

  // 1. EAQI band: four neighbouring bands around the right one.
  final band = aqiBand(reading.aqi);
  final start = (band.index - 1).clamp(0, AqiBand.values.length - 4);
  final bands = AqiBand.values.sublist(start, start + 4);
  final q1 = QuizQuestion(
    id: 'territory_${day}_1',
    topic: EcoTopic.climate,
    difficulty: 1,
    question: "Com'è oggi l'aria a $town secondo l'indice europeo (EAQI)?",
    options: [for (final b in bands) b.label],
    correctIndex: bands.indexOf(band),
    explanation: "L'indice ora è ${reading.aqi}: fascia \"${band.label}\". "
        "L'EAQI unisce PM10, PM2,5, biossido di azoto e ozono: più è basso, "
        'più l\'aria è pulita (0-20 buona, oltre 60 scadente).',
    source: source,
  );

  // 2. PM10 against the EU daily limit.
  final pm10 = double.parse(reading.pm10.toStringAsFixed(1));
  final pm10Index = pm10 < pm10DailyLimit
      ? 0
      : pm10 > pm10DailyLimit
          ? 1
          : 2;
  final pm10Text = formatMeasure(pm10);
  final q2 = QuizQuestion(
    id: 'territory_${day}_2',
    topic: EcoTopic.climate,
    difficulty: 2,
    question: 'A $town il PM10 adesso è $pm10Text µg/m³. Rispetto al limite '
        'UE giornaliero di 50 µg/m³ è…',
    options: const [
      'Sotto il limite',
      'Sopra il limite',
      'Esattamente pari al limite',
      'Il PM10 non si misura',
    ],
    correctIndex: pm10Index,
    explanation: '$pm10Text µg/m³ è '
        '${const ['sotto', 'sopra', 'pari a'][pm10Index]} 50 µg/m³, il '
        'limite giornaliero della Direttiva 2008/50/CE. Il PM10 sono polveri '
        'fini da traffico, riscaldamento e fuochi; questo è un valore orario.',
    source: source,
  );

  final questions = [q1, q2];

  // 3. Cleanest town right now (only with all three towns).
  final all = [
    for (final t in TerritoryTown.values) readingFor(readings, t),
  ];
  if (all.every((r) => r != null)) {
    final values = [for (final r in all) r!.aqi];
    final best = values.reduce(min);
    final winners = [
      for (var i = 0; i < values.length; i++)
        if (values[i] == best) i,
    ];
    final names = [for (final t in TerritoryTown.values) t.label];
    final listing = [
      for (var i = 0; i < names.length; i++) '${names[i]} ${values[i]}',
    ].join(', ');
    questions.add(QuizQuestion(
      id: 'territory_${day}_3',
      topic: EcoTopic.climate,
      difficulty: 2,
      question: "In quale di questi comuni l'aria è più pulita in questo "
          'momento?',
      options: [...names, 'Sono a pari merito'],
      correctIndex: winners.length == 1 ? winners.single : names.length,
      explanation: "Indice europeo dell'aria (EAQI) adesso: $listing. "
          "Vince il valore più basso: vuol dire meno inquinanti nell'aria.",
      source: source,
    ));
  }
  return questions;
}

/// One small action suggested by today's data.
class TerritoryTip {
  const TerritoryTip(this.id, this.text);

  /// Stable id (for tests and analytics), e.g. "good_air".
  final String id;
  final String text;
}

/// The most useful action for [reading]: poor air first, then rain,
/// cold, heat, and finally the air quality.
TerritoryTip territoryTip(TownReading reading) {
  final band = aqiBand(reading.aqi);
  if (band.isPoor) {
    return const TerritoryTip('bad_air',
        "Aria pesante: evita sport intenso all'aperto, usa i mezzi pubblici "
        'e non bruciare foglie');
  }
  if (reading.isRaining) {
    return const TerritoryTip(
        'rain', "Piove: raccogli l'acqua piovana per le piante");
  }
  if (reading.temperature < 5) {
    return const TerritoryTip(
        'cold', 'Fa freddo: chiudi bene le finestre, risparmi energia');
  }
  if (reading.temperature > 28) {
    return const TerritoryTip('hot',
        'Fa caldo: abbassa le tapparelle invece di accendere il condizionatore');
  }
  if (band == AqiBand.moderate) {
    return const TerritoryTip('moderate_air',
        'Aria così così: oggi un viaggio in auto in meno, fallo a piedi o in bus');
  }
  return const TerritoryTip(
      'good_air', 'Aria buona: oggi vai a scuola in bici o a piedi');
}
