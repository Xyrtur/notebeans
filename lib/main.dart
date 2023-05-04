import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notebeans/note_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const Notebeans());
}

class Notebeans extends StatelessWidget {
  const Notebeans({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }
}
