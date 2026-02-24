import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_information.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/weather_design.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Kathmandu';
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "an unexpected error occured";
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD54F)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          String currentSky = 'Clear';
          bool isNight = false;

          if (snapshot.hasData) {
            final data = snapshot.data!;
            final currentWeatherData = data['list'][0];
            currentSky = currentWeatherData['weather'][0]['main'];
            final iconCode = currentWeatherData['weather'][0]['icon'];
            isNight = WeatherDesign.isNightFromIcon(iconCode);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              children: [
                WeatherDesign.buildWeatherBackground(currentSky, isNight),
                const Center(child: CircularProgressIndicator.adaptive()),
              ],
            );
          }

          if (snapshot.hasError) {
            return Stack(
              children: [
                WeatherDesign.buildWeatherBackground(currentSky, isNight),
                Center(child: Text(snapshot.error.toString())),
              ],
            );
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          currentSky = currentWeatherData['weather'][0]['main'];
          final pressure = currentWeatherData['main']['pressure'];
          final windSpeed = currentWeatherData['wind']['speed'];
          final humidity = currentWeatherData['main']['humidity'];
          final iconCode = currentWeatherData['weather'][0]['icon'];
          isNight = WeatherDesign.isNightFromIcon(iconCode);

          IconData weatherIcon = WeatherDesign.getWeatherIcon(currentSky);
          final Color currentWeatherIconColor =
              WeatherDesign.getWeatherIconColor(currentSky, isNight: isNight);

          return Stack(
            children: [
              WeatherDesign.buildWeatherBackground(currentSky, isNight),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: WeatherDesign.glassCard(
                          child: Column(
                            children: [
                              Text(
                                "${kelvinToCelsius(currentTemp).toStringAsFixed(1)}°C",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                weatherIcon,
                                size: 52,
                                color: currentWeatherIconColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Hourly Forecast",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 132,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final hourlyForecast = data['list'][index + 1];
                            final hourlyCondition =
                                hourlyForecast['weather'][0]['main'];
                            final time = DateTime.parse(
                              hourlyForecast['dt_txt'],
                            );
                            final hourlyIconCode =
                                hourlyForecast['weather'][0]['icon'];
                            final isHourlyNight = WeatherDesign.isNightFromIcon(
                              hourlyIconCode,
                            );

                            return HourlyForecastItem(
                              Time: DateFormat.j().format(time),
                              icon: Icon(
                                WeatherDesign.getWeatherIcon(
                                  hourlyCondition,
                                  isNight: isHourlyNight,
                                ),
                                color: WeatherDesign.getWeatherIconColor(
                                  hourlyCondition,
                                  isNight: isHourlyNight,
                                ),
                                size: 30,
                              ),
                              temperature:
                                  "${kelvinToCelsius(hourlyForecast['main']['temp']).toStringAsFixed(0)}°C",
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      WeatherDesign.glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Additional Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AdditionalInfo(
                                  icon: const Icon(
                                    Icons.water_drop,
                                    color: Color(0xFF29B6F6),
                                  ),
                                  heading: "Humidity",
                                  subHeading: "$humidity",
                                ),
                                AdditionalInfo(
                                  icon: const Icon(
                                    Icons.air,
                                    color: Color(0xFF00E5FF),
                                  ),
                                  heading: "Wind Speed",
                                  subHeading: "$windSpeed",
                                ),
                                AdditionalInfo(
                                  icon: const Icon(
                                    Icons.beach_access,
                                    color: Color(0xFFFF7043),
                                  ),
                                  heading: "Pressure",
                                  subHeading: "$pressure",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
