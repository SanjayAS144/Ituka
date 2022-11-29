import 'dart:async';
import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/screens/homeWithBn.dart';
import 'package:acesteels/update_user_info/update_billing_address.dart';
import 'package:acesteels/update_user_info/update_site_address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icons.dart';
import 'package:acesteels/screens/model/user.dart' as userInfo;
import 'package:url_launcher/url_launcher.dart';

import '../login.dart';

GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth mAuth = FirebaseAuth.instance;
CollectionReference currentUserDataRef = FirebaseFirestore.instance.collection('users');
Map<String, dynamic> data;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    super.initState();
  }

  getBillingAddress() async{
    var billingAddress = await currentUserDataRef.doc(mAuth.currentUser.uid).collection("billingAddress").doc("billing").get();
    setState(() {

    });
  }
  logout() async{
    await googleSignIn.signOut();
    await mAuth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
   circularProgress() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10.0),
        child: SpinKitDoubleBounce(
          color: Color(0xFFC850C0),
          size: 100.0,
        ),
      ),
    );
  }

  static const MethodChannel _channel = const MethodChannel('flutter_launch');

  static Future<Null> launchWhatsApp(
      {@required String phone, @required String message}) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'phone': phone,
      'message': message
    };
    await _channel.invokeMethod('launchWathsApp', params);
  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: currentUserDataRef.doc(mAuth.currentUser.uid).get(),
            builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot){
              if (snapshot.hasError) {
                return circularProgress();
              }
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                userInfo.User user = userInfo.User.fromDocument(snapshot.data);
                return  Padding(
                  padding: const EdgeInsets.only(top: 50, left: 36, right: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 100.0,
                                      width: 100.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                        AlwaysStoppedAnimation(Color(0xffFF6550)),
                                        strokeWidth: 2,
                                        value: 0.7,
                                      ),
                                    ),
                                    Container(
                                      height: 83.0,
                                      width: 83.0,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Color(0xffFF6550).withOpacity(0.1)),
                                        strokeWidth: 15,
                                        value: 0.7,
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: NetworkImage(
                                          '${user.photoURL}'),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 1,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey.shade400),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quotes',
                                            style: GoogleFonts.montserrat(
                                                fontSize: 16, color: Colors.grey),
                                          ),
                                          RichText(
                                              text: TextSpan(
                                                  text: quoteCount.toString(),
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: 24,
                                                    color: Colors.black,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                        text: ' Quotes',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14)),
                                                  ]))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              "${user.fName}",
                              style: GoogleFonts.montserrat(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            Text(
                              "${user.lName}",
                              style: GoogleFonts.montserrat(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black38),
                            ),
                            SizedBox(
                              height: 60,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ProfileCard(
                                  color: cardColorsHome[2][0],
                                  backColor: cardColorsHome[2][1],
                                  text: 'Billing Address',
                                  icon: LineIcons.wavyMoneyBill,
                                  onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateBillingAddress())),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                ProfileCard(
                                  color: cardColorsHome[1][0],
                                  backColor: cardColorsHome[1][1],
                                  text: 'Site Address',
                                  icon: FeatherIcons.alignRight,
                                  onTap:()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateSiteAddress())),

                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                ProfileCard(
                                  color: cardColorsHome[0][0],
                                  backColor: cardColorsHome[0][1],
                                  text: '${user.phone}',
                                  icon: FeatherIcons.phone,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 50,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                logout();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color(0xffF5F5F6),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FeatherIcons.logOut,
                                      color: Color(0xffF72F0D),
                                      size: 22,
                                    ),
                                    SizedBox(width: 10,),
                                    Text('Sign Out',style:GoogleFonts.montserrat(fontSize: 16,color: Color(0xff13182A),fontWeight: FontWeight.w500),),
                                    SizedBox(width: 3,)
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async{
                                String url = "whatsapp://send?phone=+917290837260&text=Hello I Need a Help On My Order";
                                await canLaunch(url)?launch(url):print("Cant open url");
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color(0xffF5F5F6),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LineIcons.headset,
                                      color: Color(0xffF72F0D),
                                      size: 22,
                                    ),
                                    SizedBox(width: 10,),
                                    Text('Help',style:GoogleFonts.montserrat(fontSize: 16,color: Color(0xff13182A),fontWeight: FontWeight.w500),),
                                    SizedBox(width: 3,)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                      ],
                    ),
                  ),
                );
              }
              return  circularProgress();
            },
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color backColor;
  final String text;
  final Function onTap;

  const ProfileCard({this.color, this.icon, this.backColor, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              decoration: BoxDecoration(
                  color: backColor, borderRadius: BorderRadius.circular(100)),
            ),
            SizedBox(width: 20),
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xff13182A),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(11.0),
              child: Icon(
                CupertinoIcons.chevron_forward,
                color: Color(0xff13182A),
                size: 22,
              ),
            ),
            decoration: BoxDecoration(
                color: Color(0xffF5F5F7),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
