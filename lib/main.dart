import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class ColorObject {
  final String type;
  final Color color;

  ColorObject({required this.type, required this.color});
}

class ColorChangeNotifier with ChangeNotifier {
  int _currentIndex = 0;
  final List<ColorObject> colorObjectPairs = [
    ColorObject(type: 'Apple', color: Colors.red),
    ColorObject(type: 'Banana', color: Colors.yellow),
    ColorObject(type: 'Orange', color: Colors.orange),
    ColorObject(type: 'Grape', color: Colors.purple),
    ColorObject(type: 'Guava', color: Colors.green),
  ];
   Map<Color, String> colorNameMap = {
    Colors.red: 'Red',
    Colors.yellow: 'Yellow',
    Colors.orange: 'Orange',
    Colors.purple: 'Purple',
    Colors.green: 'Green',
  };

  ColorObject get currentColorObject => colorObjectPairs[_currentIndex];

  void changeColorAndType() {
    _currentIndex = (_currentIndex + 1) % colorObjectPairs.length;
    notifyListeners();

    final updatedColorObject = currentColorObject;
    FirebaseFirestore.instance.collection('color_objects').add({
      'type': updatedColorObject.type,
      'color':colorNameMap[updatedColorObject.color],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => ColorChangeNotifier(),
        child: const ColorChangePage(),
      ),
    );
  }
}

class ColorChangePage extends StatelessWidget {
  const ColorChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorChangeNotifier = Provider.of<ColorChangeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Change App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              color: colorChangeNotifier.currentColorObject.color,
            ),
            const SizedBox(height: 20),
            Text(
              "Type: ${colorChangeNotifier.currentColorObject.type} , Color: ${colorChangeNotifier.colorNameMap[colorChangeNotifier.currentColorObject.color]}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                colorChangeNotifier.changeColorAndType();
              },
              child: const Text('Change Color and Type'),
            ),
          ],
        ),
      ),
    );
  }
}
