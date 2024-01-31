import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weather = 'Loading...';
  Position? _position;
  String _city = '';
  String _mapUrl = '';
  double _temp = 0.0;
  int _humidity = 0;


  @override
  void initState() {
    super.initState();
    _updateWeather();
  }

  Future<void> _updateWeather() async {
    Position position = await getCurrentPosition();
    _getMap(position.latitude, position.longitude);
    final response = await http.get(
        Uri.parse('http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid='));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String weather = data['weather'][0]['description'];
      double temp = data['main']['temp'];
      int humidity = data['main']['humidity'];
      String city = data['name'];

      setState(() {
        _weather = weather;
        _position = position;
        _city = city;
        _temp = temp;
        _humidity = humidity;
      });
    } else {
      setState(() {
        _weather = 'Failed to load weather data.';
      });
    }
  }

  Future<void> _getMap(double latitude, double longitude) async {
    final apiKey = '';
    final urlMap = 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=15&size=400x400&markers=color:red%7C$latitude,$longitude&key=$apiKey';

    setState(() {
      _mapUrl = urlMap;
    });
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if(permission == LocationPermission.deniedForever) {
      return Future.error('Location permisssions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 24,),
                Text(
                    'We are currently at:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$_city',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Latitude:${_position!.latitude}'),
                    Text('Longitude:${_position!.longitude}'),
                  ],
                ),
                SizedBox(height: 24,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text('Current Weather', style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)
                          ),
                          Text('$_weather', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text('Temperature', style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                          Text('$_temp°C', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Text('Humidity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                          Text('$_humidity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(75.0), // Set the border radius as needed
                    child: Image.network(
                      _mapUrl.toString(),
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
