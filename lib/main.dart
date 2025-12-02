import 'package:eatwise2/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eatwise2/util/session.dart';
import 'package:eatwise2/login.dart';
import 'package:eatwise2/page/home_integrated.dart';
import 'package:eatwise2/page/hasil_integrated.dart'; 
import 'package:eatwise2/page/user_profile.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      // theme: ThemeData(primarySwatch: const Color.fromARGB(255, 255, 255, 255)),
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
                  int idproduk = 11;
                  // result = const HomeContent(); 
                  // result = const ReportScreenApi(productId: 11,);
                  //// Gunakan HomeContent baru
                  result = const UserProfileScreen(userId: 3,);
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
