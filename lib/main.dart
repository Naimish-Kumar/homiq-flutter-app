import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homiq/firebase_options.dart';
import 'package:homiq/app/app.dart';
import 'package:homiq/app/register_cubits.dart';
import 'package:homiq/exports/main_export.dart';
import 'package:homiq/utils/hive_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await HiveUtils.initBoxes();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiBlocProvider(
      providers: RegisterCubits().register(),
      child: const App(),
    ),
  );
}
