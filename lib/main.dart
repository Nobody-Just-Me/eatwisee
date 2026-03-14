import 'package:eatwise2/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/util/session.dart';
import 'package:eatwise2/login.dart';
import 'package:eatwise2/page/home_integrated.dart';
import 'package:eatwise2/page/hasil_integrated.dart';
import 'package:eatwise2/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:eatwise2/util/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize notification service
  await NotificationService.initialize();

  // Tambahkan di sini
  FlutterError.demangleStackTrace = (StackTrace stack) => stack;

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Indonesian
        Locale('en', 'US'), // English
      ],
      locale: const Locale('id', 'ID'), // Set default to Indonesian
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => const HomeContent(),
      },
      home: FutureBuilder(
        future: _loadSession(),
        builder: (context, snapshot) {
          late Widget result;
          late final SharedPreferences prefs = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            result = Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (prefs.getBool(IS_LOGIN) ?? false) {
                // Gunakan HomeContent, bukan UserProfileScreen
                result = const HomeContent();
              } else {
                result = LoginPage();
              }
            } else {
              // result = SignUpPage();
              return Container(child: Text('Error..'));
            }
          }

          return result;
        },
      ),
    );
  }

  Future _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
