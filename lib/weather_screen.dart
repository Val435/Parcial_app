import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  final String cityName = 'Republic of El Salvador';
  Timer? _timer;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeatherAPIKey',
      ));

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'Error al obtener datos del clima. Por favor, intenta nuevamente.';
      }

      return data;
    } catch (e) {
      throw 'No se pudo conectar con el servidor. Por favor, verifica tu conexión a internet o intenta más tarde.';
    }
  }

  int findInitialIndex(List<dynamic> forecastList) {
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: -6));

    int closestIndex = 0;
    Duration smallestDifference = const Duration(hours: 3);

    for (int i = 0; i < forecastList.length; i++) {
      DateTime forecastTime = DateTime.parse(forecastList[i]['dt_txt']);
      Duration difference = forecastTime.difference(now).abs();

      if (difference < smallestDifference) {
        smallestDifference = difference;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        weather = getCurrentWeather();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          title: const Text(
            'Clima',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudo conectar con el servidor. Por favor, verifica tu conexión a internet o intenta más tarde.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data!;
          final initialIndex = findInitialIndex(data['list']);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'República de El Salvador',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: const Color(0xFF005ADE),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '${(data['list'][initialIndex]['main']['temp'] - 273.15).toStringAsFixed(1)} °C',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Icon(
                              _getWeatherIcon(data['list'][initialIndex]
                                  ['weather'][0]['main']),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _translateWeatherCondition(data['list']
                                  [initialIndex]['weather'][0]['main']),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Pronóstico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecastIndex = initialIndex + index;
                      if (hourlyForecastIndex >= data['list'].length) {
                        return Container();
                      }

                      final hourlyForecast = data['list'][hourlyForecastIndex];
                      final hourlySky = hourlyForecast['weather'][0]['main'];
                      final hourlyTemp =
                          (hourlyForecast['main']['temp'] - 273.15)
                              .toStringAsFixed(1);
                      final time = DateTime.parse(hourlyForecast['dt_txt']);

                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        temperature: '$hourlyTemp °C',
                        icon: _getWeatherIcon(hourlySky),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Información Adicional',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humedad',
                      value: data['list'][initialIndex]['main']['humidity']
                          .toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Velocidad del Viento',
                      value: data['list'][initialIndex]['wind']['speed']
                          .toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Presión',
                      value: data['list'][initialIndex]['main']['pressure']
                          .toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getWeatherIcon(String weatherCondition) {
    switch (weatherCondition) {
      case 'Clear':
        return Icons.wb_sunny;
      case 'Clouds':
        return Icons.cloud;
      case 'Rain':
        return Icons.umbrella;

      default:
        return Icons.help;
    }
  }

  String _translateWeatherCondition(String condition) {
    switch (condition) {
      case 'Clear':
        return 'Despejado';
      case 'Clouds':
        return 'Nublado';
      case 'Rain':
        return 'Lluvia';

      default:
        return 'Desconocido';
    }
  }
}
