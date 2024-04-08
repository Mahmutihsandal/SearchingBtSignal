import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothListScreen(),
    );
  }
}

class BluetoothListScreen extends StatefulWidget {
  @override
  _BluetoothListScreenState createState() => _BluetoothListScreenState();
}

class _BluetoothListScreenState extends State<BluetoothListScreen> {
  List<BluetoothDevice> devicesList = [];
  bool isScanning = false;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _scan();
              },
              child: Text(isScanning ? 'Stop Scanning' : 'Start Scanning'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devicesList[index].name ?? "Unknown"),
                    subtitle: Text(devicesList[index].id.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scan() {
    setState(() {
      isScanning = !isScanning;
    });
    if (isScanning) {
      flutterBlue.startScan(timeout: Duration(seconds: 4));

      // Listen to scan results
      var subscription = flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          if (!devicesList.contains(r.device)) {
            setState(() {
              devicesList.add(r.device);
            });
          }
        }
      });

      // Stop scanning after 4 seconds
      flutterBlue.stopScan().then((value) {
        subscription.cancel();
      });
    } else {
      flutterBlue.stopScan();
    }
  }
}
