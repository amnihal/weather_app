import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_information_session.dart';
import 'package:weather_app/hourly_forecast_session.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weatherFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weatherFuture = getCurrentWeather();
    debugPrint("Api called");
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Kozhikode';
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey',
        ),
      );

      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        // throw data['message'];
        throw 'Sorry, Some error occurred';
      }
      // (data['list'][0]['main']['temp'] - 273.15).toStringAsFixed(1);
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weatherFuture = getCurrentWeather();
              });
              debugPrint("Api called");
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),

      body: FutureBuilder(
        future: weatherFuture,
        builder: (context, snapshot) {
          // print(snapshot);
          // print(snapshot.runtimeType);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                color: Colors.black38,
              ),
            );
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final currentData = data['list'][0];
          final currentTemp = (currentData['main']['temp'] - 273.15)
              .toStringAsFixed(1);
          final currentSky = currentData['weather'][0]['main'];
          final windSpeed = currentData['wind']['speed'];
          final humidity = currentData['main']['humidity'];
          final pressure = currentData['main']['pressure'];

          final weatherIcons = {
            'Rain': Icons.cloudy_snowing,
            'Clouds': Icons.cloud,
            'Clear': Icons.sunny,
          };

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                // const Placeholder(fallbackHeight: 250,),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp°C",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Icon(
                                weatherIcons[currentSky] ?? Icons.wb_sunny,
                                size: 70,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "$currentSky",
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //weather forecast card
                const SizedBox(height: 20),
                const Text(
                  "Weather Forecast",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       // const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
                //       // const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
                //       // const Placeholder(fallbackHeight: 100, fallbackWidth: 100),
                //       for (int i = 1; i < 6; i++)
                //         HourlyForecastCard(
                //           time: '${data['list'][i]['dt_txt']}.',
                //           icon:
                //               data['list'][i]['weather'][0]['main'] == 'Rain' ||
                //               data['list'][i]['weather'][0]['main'] == 'Clouds'
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           value:
                //               '${(data['list'][i]['main']['temp'] - 273.15).toStringAsFixed(1)}°C',
                //         ),
                //
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final time = DateTime.parse(
                        data['list'][index + 1]['dt_txt'],
                      );
                      final sky = data['list'][index + 1]['weather'][0]['main'];

                      return HourlyForecastCard(
                        icon: weatherIcons[sky] ?? Icons.sunny,
                        time: DateFormat.jm().format(time),
                        value:
                            '${(data['list'][index + 1]['main']['temp'] - 273.15).toStringAsFixed(1)}°C',
                      );
                    },
                  ),
                ),

                //Additional Info
                const SizedBox(height: 20),
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // const Placeholder(fallbackHeight: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      title: 'Humidity',
                      value: '$humidity',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      title: 'Wind Speed',
                      value: '$windSpeed',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.gas_meter_outlined,
                      title: 'Pressure',
                      value: '$pressure',
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
}
