import 'dart:io';

import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../widgettree.dart';
import 'ProfileBillingAddressSetup.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');

class ProfileAboutSetup extends StatefulWidget {
  @override
  _ProfileAboutSetupState createState() => _ProfileAboutSetupState();
}

class _ProfileAboutSetupState extends State<ProfileAboutSetup> {
  String firstName = "",
      lastName = "",
      email = "",
      phone = "",
      photoURL = "https://firebasestorage.googleapis.com/v0/b/acesteels-dd680.appspot.com/o/avatar-1577909_1280.png?alt=media&token=37fb4fdd-f793-4ac4-888d-639e48fc949c";

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

     setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
      }
    });
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    await uploadImageToFirebase(context).whenComplete(() => {
          animatedLoader.removeDialog(),
        });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = firebaseAuth.currentUser.uid + 'profile_id' + _image.path;
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/' + firebaseAuth.currentUser.uid);
    try {
      await firebaseStorageRef.putFile(_image);
      photoURL = await firebaseStorageRef.getDownloadURL();
    } on FirebaseException catch (e) {
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserPhoneEmail();
  }

  getUserPhoneEmail() {
    if (firebaseAuth.currentUser != null) {
      if(firebaseAuth.currentUser.phoneNumber != null){
        setState(() {
          phone = firebaseAuth.currentUser.phoneNumber;
        });
      }
      if (firebaseAuth.currentUser.email != null) {
        setState(() {
          email = firebaseAuth.currentUser.email;
        });
      }

    }


  }

  void getBasicDetails() async {
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      final snackBar = SnackBar(content: Text('Enter all the Details Correctly!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      animatedLoader.removeDialog();
    } else {
      if (email.isEmpty) {
        email = "Not Provided";
      }

      final snackBar = SnackBar(content: Text('Successfully Saved!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      var status = await OneSignal.shared.getPermissionSubscriptionState();
      String playerId = status.subscriptionStatus.userId;

      var userData = {
        'fName': firstName,
        'lName': lastName,
        'email': email,
        'phone': phone,
        'tokenId': playerId,
        'uid': firebaseAuth.currentUser.uid,
        'timestamp': DateTime.now(),
        'photoURL': photoURL,
        'hasCompleted': "false",
        'hasAccepted' : "false"
      };

      await users.doc(firebaseAuth.currentUser.uid).set(userData).whenComplete(() {
        animatedLoader.removeDialog();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileBillingAddressSetup()),
        );
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
    double heightDevice = MediaQuery.of(context).size.height;
    double widthDevice = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Details',
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: getImage,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(5.0, 5.0),
                                blurRadius: 10.0,
                                spreadRadius: 5.0,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _image == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: FittedBox(
                                        child: Image.network(photoURL),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: FittedBox(
                                        child: Image.file(_image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'First Name',
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
                              firstName = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Last Name',
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
                              lastName = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Email',
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
                            initialValue: email,
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
                              email = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Phone',
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
                            initialValue: phone,
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
                              phone = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => getBasicDetails(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
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
                          'Get Started',
                          style: GoogleFonts.nunitoSans(
                            color: Colors.pinkAccent,
                            fontSize: 24,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
