import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgettree.dart';


final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');

class UpdateSiteAddress extends StatefulWidget {
  @override
  _UpdateSiteAddressState createState() => _UpdateSiteAddressState();
}

class _UpdateSiteAddressState extends State<UpdateSiteAddress> {
  String houseNo = "", address = "", city = "", state = "";

  TextEditingController houseController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  void getBasicDetails() async {
    animatedLoader.showDialog(AnimatedLoader.basketBall);

    if (houseNo.isEmpty || address.isEmpty || city.isEmpty || state.isEmpty) {
      final snackBar = SnackBar(content: Text('Enter all the Details Correctly!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      animatedLoader.removeDialog();

    } else {
      final snackBar = SnackBar(content: Text('Successfully Site Address!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      var userSiteAddress = {
        'siteHouseNo' : houseNo,
        'siteAddress' : address,
        'siteCity' : city,
        'siteState' : state,
      };

      await users.doc(firebaseAuth.currentUser.uid).collection("siteAddress").doc("site").update(userSiteAddress).whenComplete((){

        animatedLoader.removeDialog();

        Navigator.pop(context);
      });


    }
  }

  @override
  void initState() {
    super.initState();
    getSiteAddress();
  }

  getSiteAddress() async{
    var billingAddress = await users.doc(firebaseAuth.currentUser.uid).collection("siteAddress").doc("site").get();
    setState(() {

      houseController.text = billingAddress.data()["siteHouseNo"].toString();
      houseNo = billingAddress.data()["siteHouseNo"].toString();

      addressController.text = billingAddress.data()["siteAddress"].toString();
      address = billingAddress.data()["siteAddress"].toString();

      cityController.text = billingAddress.data()["siteCity"].toString();
      city = billingAddress.data()["siteCity"].toString();

      stateController.text = billingAddress.data()["siteState"].toString();
      state = billingAddress.data()["siteState"].toString();

    });
  }

  @override
  Widget build(BuildContext context) {
    double widthDevice = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Site Address',
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
            SizedBox(
              height: 32,
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
                    controller: houseController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: ()=>{
                          houseController.clear()
                        },
                      ),
                      fillColor: Colors.redAccent,
                      focusColor: Colors.pink,
                      hoverColor: Colors.pink,
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
                    controller: addressController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: ()=>{
                          addressController.clear()
                        },
                      ),
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
                    controller: cityController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: ()=>{
                          cityController.clear()
                        },
                      ),
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
                    controller: stateController,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: ()=>{
                          stateController.clear()
                        },
                      ),
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
