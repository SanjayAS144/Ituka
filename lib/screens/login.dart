import 'dart:async';

import 'package:acesteels/animation/FadeAnimation.dart';
import 'package:acesteels/authentication/authentication.dart';
import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/screens/profilesetup/login_with_phone.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgettree.dart';
import 'homeWithBn.dart';



final GoogleSignIn googleSignIn = GoogleSignIn();

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<void> signInWithGoogle() async {
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    await Authentication().signInWithGoogle().whenComplete((){
      animatedLoader.removeDialog();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeWithBN()));
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeAnimation(1, Text("Welcome to,", style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    color: kPrimaryDarkColor
                  ),)),
                  SizedBox(height: 6,),
                  FadeAnimation(1, Text("ITUKAA,", style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color:kPrimaryColor
                  ),)),
                  SizedBox(height: 10,),
                  FadeAnimation(1.2, Text("Make your professional life easy with ITUKAA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15
                    ),)),
                ],
              ),
              FadeAnimation(1.4, Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/giphy.gif')
                    )
                ),
              )),
              Column(
                children: <Widget>[
                  FadeAnimation(1.5, InkWell(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginWithPhone())),
                    child: Container(
                      padding: EdgeInsets.all(17),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color:Colors.grey)
                      ),
                      child:  Center(
                        child: Text("Login Using Phone", style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: kPrimaryDarkColor
                        ),),
                      ),),
                    ),
                  ),
                  SizedBox(height: 20,),
                  FadeAnimation(1.6, GestureDetector(
                    onTap:() => signInWithGoogle() ,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        border: Border.all(color:Colors.grey)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("lib/images/googleicon.png",width: 25,height: 25,),
                          SizedBox(width: 20,),
                          Center(
                            child: Text("Sign up", style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              color: kPrimaryDarkColor
                            ),),
                          ),
                        ],
                      ),
                    ),
                  ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
