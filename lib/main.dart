import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/widgettree.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FirebaseAuth _auth;
  User _user;
  bool isLoading = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configOneSignel();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    isLoading = false;
  }

  void configOneSignel()
  {
    OneSignal.shared.init('7d108336-42a4-4e9f-9a23-6105dd125a74');
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        primaryColorDark: kPrimaryDarkColor,
      ),
      home:WidgetTree(),
      // home: OnBoardingPage(),
    );
  }
}

