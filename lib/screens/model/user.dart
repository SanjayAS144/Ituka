import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String fName;
  final String lName;
  final String email;
  final String phone;
  final String photoURL;


  User({this.uid, this.fName, this.lName, this.email, this.phone, this.photoURL});

   factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc['uid'],
      fName: doc['fName'],
      lName: doc['lName'],
      email: doc['email'],
      phone: doc['phone'],
      photoURL: doc['photoURL'],
    );
  }
}
