import 'package:courier_app/Location/FastDeliveryAlgrorithm.dart';
import 'package:courier_app/Screens/Login/login_screen.dart';
import 'package:courier_app/Screens/CourierPage/courier_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AddressesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CourierStateProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demoo!!',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
