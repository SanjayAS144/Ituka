import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgettree.dart';
import 'ProfileSiteAddressSetup.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');

class ProfileBillingAddressSetup extends StatefulWidget {
  @override
  _ProfileBillingAddressSetupState createState() => _ProfileBillingAddressSetupState();
}

class _ProfileBillingAddressSetupState extends State<ProfileBillingAddressSetup> {
  String houseNo = "Not Provided", address = "Not Provided", city = "Not Provided", state = "Not Provided";

  void getBasicDetails() async {
    animatedLoader.showDialog(AnimatedLoader.basketBall);

    if (houseNo.isEmpty || address.isEmpty || city.isEmpty || state.isEmpty) {
      final snackBar = SnackBar(content: Text('Enter all the Details Correctly!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      animatedLoader.removeDialog();

    } else {
      final snackBar = SnackBar(content: Text('Successfully Billing Address!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      var userBillingAddress = {
        'houseNo' : houseNo,
        'address' : address,
        'city' : city,
        'state' : state,
      };

      await users.doc(firebaseAuth.currentUser.uid).collection("billingAddress").doc("billing").set(userBillingAddress).whenComplete((){

      animatedLoader.removeDialog();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileSiteAddressSetup()),
      );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthDevice = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billing Address',
          style: GoogleFonts.montserrat(
            color: Colors.black54,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(onTap: () => getBasicDetails(),child: Text("Skip",style: GoogleFonts.montserrat(fontSize: 20),)),
                SizedBox(width: 20,)
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'House No/ Flat No.',
                      style: GoogleFonts.montserrat(
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
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
                    onChanged: (String value) {
                      houseNo = value;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Address',
                      style: GoogleFonts.montserrat(
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
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
                    onChanged: (String value) {
                      address = value;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'City',
                      style: GoogleFonts.montserrat(
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
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
                    onChanged: (String value) {
                      city = value;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'State',
                      style: GoogleFonts.montserrat(
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
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
                    onChanged: (String value) {
                      state = value;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
            InkWell(
              onTap: () => getBasicDetails(),
              child: Container(
                height: 70,
                width: widthDevice * 0.85,
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(3.0, 3.0),
                      blurRadius: 50.0,
                      spreadRadius: 2.0,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Set Location',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.pinkAccent,
                      fontSize: 24,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
