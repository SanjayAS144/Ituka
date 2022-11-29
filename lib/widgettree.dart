import 'package:acesteels/screens/homeWithBn.dart';
import 'package:acesteels/screens/login.dart';
import 'package:acesteels/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_loading/show_custom_loader.dart';


AnimatedLoader animatedLoader;

class WidgetTree extends StatefulWidget {


  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {


  bool isFirstRun = true;
  checkIfFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('isFirstRun');
    if (checkValue) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstRun = prefs.getBool('isFirstRun');
      if (isFirstRun == true) {
      } else {
        isFirstRun = false;
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isFirstRun', false);
      isFirstRun = true;
    }
  }

  checkForFirstRun() async{
    await checkIfFirstRun();
  }

  bool isUserExist = false;
  @override
  void initState() {
    checkForFirstRun();
    super.initState();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    if (user != null) {
      setState(() {
      isUserExist = true;
      });
    }


  }


  @override
  Widget build(BuildContext context) {

    animatedLoader = new AnimatedLoader(
      context: context,
      height: 100.0,
      width: 100.0,
      isDismissable: false,
    );


    if (!isUserExist) {
      if(isFirstRun){
        return OnBoardingPage();
      }else{
        return LoginScreen();
      }

    }else{
      return HomeWithBN();
    }

  }
}
