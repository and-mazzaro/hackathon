import 'package:ecoquest/domain/models/territory.dart';

/// A fixed reading time (Europe/Rome local).
final territoryTime = DateTime(2026, 10, 22, 9);

TownReading townReading(
  TerritoryTown town, {
  int aqi = 20,
  double pm10 = 5.5,
  double pm25 = 4.9,
  double temperature = 10.3,
  double precipitation = 0,
}) =>
    TownReading(
      town: town,
      time: territoryTime,
      aqi: aqi,
      pm10: pm10,
      pm25: pm25,
      no2: 6.1,
      ozone: 58,
      temperature: temperature,
      precipitation: precipitation,
      weatherCode: 3,
      windSpeed: 4.5,
    );

/// Schio 20 (Buona), Thiene 35, Valdagno 18 (cleanest).
List<TownReading> testTerritoryReadings() => [
      townReading(TerritoryTown.schio),
      townReading(TerritoryTown.thiene, aqi: 35, pm10: 12),
      townReading(TerritoryTown.valdagno, aqi: 18, pm10: 4),
    ];
