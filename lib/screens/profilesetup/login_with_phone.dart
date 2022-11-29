import 'package:acesteels/animation/FadeAnimation.dart';
import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/screens/homeWithBn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgettree.dart';


enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginWithPhone extends StatefulWidget {
  @override
  _LoginWithPhoneState createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {

  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      animatedLoader.showDialog(AnimatedLoader.basketBall);
    });

    try {
      final authCredential =
      await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        animatedLoader.removeDialog();
      });

      if(authCredential?.user != null){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeWithBN()));
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        animatedLoader.removeDialog();
      });

      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  getMobileFormWidget(context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black,),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FadeAnimation(1, Text("Login", style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),)),
                        SizedBox(height: 20,),
                        FadeAnimation(1.2, Text("Login to your account", style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700]
                        ),)),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: <Widget>[
                          FadeAnimation(1.2, TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Phone Number",
                              fillColor: Colors.redAccent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          ),),
                        ],
                      ),
                    ),
                    FadeAnimation(1.4, Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: InkWell(
                        onTap: () async{
                          setState(() {
                            animatedLoader.showDialog(AnimatedLoader.basketBall);
                          });

                          await _auth.verifyPhoneNumber(
                            phoneNumber: "+91"+phoneController.text,
                            verificationCompleted: (phoneAuthCredential) async {
                              setState(() {
                                animatedLoader.removeDialog();
                              });
                              //signInWithPhoneAuthCredential(phoneAuthCredential);
                            },
                            verificationFailed: (verificationFailed) async {
                              setState(() {
                                animatedLoader.removeDialog();
                              });
                              _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(content: Text(verificationFailed.message)));
                            },
                            codeSent: (verificationId, resendingToken) async {
                              setState(() {
                                animatedLoader.removeDialog();
                                currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                                this.verificationId = verificationId;
                              });
                            },
                            codeAutoRetrievalTimeout: (verificationId) async {},
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(17),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color:Colors.grey)
                          ),
                          child:  Center(
                            child: Text("Login", style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: kPrimaryDarkColor
                            ),),
                          ),),
                      ),
                    )),
                  ],
                ),
              ),
              FadeAnimation(1.2, Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/background.png'),
                        fit: BoxFit.cover
                    )
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
  getMobileOtp(context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black,),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FadeAnimation(1, Text("Enter Otp", style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),)),
                        SizedBox(height: 20,),
                        FadeAnimation(1.2, Text("", style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700]
                        ),)),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: <Widget>[
                          FadeAnimation(1.2, TextFormField(
                            controller: otpController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "OTP",
                              fillColor: Colors.redAccent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          ),),
                        ],
                      ),
                    ),
                    FadeAnimation(1.4, Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: InkWell(
                        onTap: () async{
                          PhoneAuthCredential phoneAuthCredential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: otpController.text);

                          signInWithPhoneAuthCredential(phoneAuthCredential);
                        },
                        child: Container(
                          padding: EdgeInsets.all(17),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color:Colors.grey)
                          ),
                          child:  Center(
                            child: Text("Verify", style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: kPrimaryDarkColor
                            ),),
                          ),),
                      ),
                    )),
                  ],
                ),
              ),
              FadeAnimation(1.2, Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/background.png'),
                        fit: BoxFit.cover
                    )
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
              ? getMobileFormWidget(context)
              : getMobileOtp(context),
        ));

  }

}