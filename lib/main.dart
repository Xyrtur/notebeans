import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notebeans/blocs/note_bloc.dart';
import 'package:notebeans/screens/note_home_page.dart';
import 'package:notebeans/utils/centre.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Future.delayed(const Duration(milliseconds: 100));
  runApp(const Notebeans());
}

class Notebeans extends StatelessWidget {
  const Notebeans({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textSelectionTheme:
              TextSelectionThemeData(cursorColor: Centre.linkColor)),
      home: MultiBlocProvider(providers: [
        BlocProvider<NoteBloc>(create: (BuildContext context) => NoteBloc()),
      ], child: HomePage()),
    );
  }
}
