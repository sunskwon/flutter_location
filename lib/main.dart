import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double lat = 0;
  double lng = 0;
  Location location = new Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  _locateMe() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    await location.getLocation().then((res) {
      setState(() {
        lat = res.latitude!;
        lng = res.longitude!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Geolocation'),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('lat: $lat, lng: $lng'),
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () => _locateMe(),
                child: Text('locate me'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String url = 'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?';
          String finalUrl = url + 'x=' + lng.toString() + '&y=' + lat.toString();
          print(finalUrl);
          Map<String, String> reqHeader = {
            'Authorization': 'Authorization: KakaoAK 933d2df92a5af1c1024efdf32b3f268a'
          };
          print(reqHeader);

          var response = await http.get(Uri.parse(finalUrl),
              headers: {"Authorization": "KakaoAK "});
          print(response.body);
        },
        child: Icon(Icons.abc),
      ),
    );
  }
}
