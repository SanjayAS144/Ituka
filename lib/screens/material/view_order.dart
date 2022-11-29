import 'dart:convert';
import 'dart:io';

import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/widgettree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../viewNewPdf.dart';

String userId = FirebaseAuth.instance.currentUser.uid;
CollectionReference materialRef = FirebaseFirestore.instance.collection("material");
CollectionReference adminRef = FirebaseFirestore.instance.collection("admin").doc("users").collection("data");
CollectionReference tokenRef = FirebaseFirestore.instance.collection("users");


class ViewOrder extends StatefulWidget {
  final String materialId;

  const ViewOrder({this.materialId,});

  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  String materialDesc = "";
  String materialName = "";
  String jobName = "";
  String materialQuantity = "";
  String materialDate = "";
  File file;
  String fileUrl = "";
  String invoiceUrl = "";
  String fileName = "";
  String invoiceName = "";
  String tokenId = "";
  String userName = "";
  String userPhone = "";
  String adminID = "";
  String userEmail = "";
  String adminName = "";
  String adminMail = "";
  @override
  void initState() {
    super.initState();
    getDate();
  }

  getDate() async {
    var materialData = await materialRef.doc(userId).collection("ongoing").doc(widget.materialId).get();
    var userRef = await tokenRef.doc(userId).get();
    var adminData = await adminRef.doc(materialData.data()["adminUserId"]).get();
    setState((){
      materialName = materialData.data()["materialName"];
      jobName = materialData.data()["jobName"];
      materialDesc = materialData.data()["materialDesc"];
      materialDate = DateFormat.yMEd().format(DateTime.parse(materialData.data()["startDate"]));
      materialQuantity = materialData.data()["quantity"];
      tokenId = userRef.data()["tokenId"];
      fileUrl = materialData.data()["pdfUrl"];
      invoiceUrl = materialData.data()["invoiceUrl"];
      userName = userRef.data()["fName"] +" "+userRef.data()["lName"];
      userPhone = userRef.data()["phone"];
      userEmail = userRef.data()["email"];
      fileName = materialData.data()["pdfName"]+"(Quotation)";
      invoiceName = materialData.data()["invoiceName"]+"(Invoice)";
      adminName=adminData.data()["adminName"];
      adminMail=adminData.data()["email"];

    });
  }


  Future<Response> createAlbum() async {
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id": kAppId,
        "include_player_ids": [tokenId],
        "data": {"foo": "bar"},
        "android_accent_color": "FF9976D2",
        "small_icon": "ic_stat_onesignal_default",
        "large_icon": "https://www.filepicker.io/api/file/zPloHSmnQsix82nlj9Aj?filename=name.jpg",
        "contents": {"en": materialName},
        "headings": {"en": "Your Order is Completed"},
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, right: 12, left: 12, bottom: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 25),
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        color: kPrimaryDarkColor,
                      ))),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text("Admin Details",style: GoogleFonts.montserrat(color: kPrimaryDarkColor,fontSize: 14),),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 7),
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white, ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        adminName,
                        style: cardTitleTextStyle().copyWith(
                          fontSize: 26,
                          color: kPrimaryDarkColor,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: 'Email : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryDarkColor,
                                fontSize: 12,
                                letterSpacing: 0.9,
                              ),
                              children: [
                                TextSpan(
                                    text: adminMail,
                                    style: cardSubHeadTextStyle().copyWith(
                                      color: kPrimaryDarkColor.withOpacity(0.6),
                                      fontSize: 12,
                                      letterSpacing: 0.9,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 7),
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        materialName,
                        style: cardTitleTextStyle().copyWith(
                          fontSize: 26,
                          color: kPrimaryDarkColor,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: 'Job : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryDarkColor,
                                fontSize: 12,
                                letterSpacing: 0.9,
                              ),
                              children: [
                                TextSpan(
                                    text: jobName,
                                    style: cardSubHeadTextStyle().copyWith(
                                      color: kPrimaryDarkColor.withOpacity(0.6),
                                      fontSize: 12,
                                      letterSpacing: 0.9,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: 'materialName : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryDarkColor,
                                fontSize: 12,
                                letterSpacing: 0.9,
                              ),
                              children: [
                                TextSpan(
                                    text: materialName,
                                    style: cardSubHeadTextStyle().copyWith(
                                      color: kPrimaryDarkColor.withOpacity(0.6),
                                      fontSize: 12,
                                      letterSpacing: 0.9,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: 'Quantity : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryDarkColor,
                                fontSize: 12,
                                letterSpacing: 0.9,
                              ),
                              children: [
                                TextSpan(
                                    text: materialQuantity,
                                    style: cardSubHeadTextStyle().copyWith(
                                      color: kPrimaryDarkColor.withOpacity(0.6),
                                      fontSize: 12,
                                      letterSpacing: 0.9,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: 'Material Date : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryDarkColor,
                                fontSize: 12,
                                letterSpacing: 0.9,
                              ),
                              children: [
                                TextSpan(
                                    text: materialDate,
                                    style: cardSubHeadTextStyle().copyWith(
                                      color: kPrimaryDarkColor.withOpacity(0.6),
                                      fontSize: 12,
                                      letterSpacing: 0.9,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 10,
                            text: TextSpan(
                              text: 'Material Description : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryDarkColor,
                                fontSize: 12,
                                letterSpacing: 0.9,
                              ),
                              children: [
                                TextSpan(
                                  text: materialDesc,
                                  style: cardSubHeadTextStyle().copyWith(
                                    color: kPrimaryDarkColor.withOpacity(0.6),
                                    fontSize: 12,
                                    letterSpacing: 0.9,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 7),
                child: InkWell(
                  onTap: () => {},
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 25, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fileName,
                                maxLines: 2,
                                overflow:TextOverflow.ellipsis,
                                style: cardTitleTextStyle().copyWith(
                                  fontSize: 16,
                                  color: kPrimaryDarkColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewNewPdf(pdfUrl:fileUrl)));

                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
                                child: Text(
                                  'View',
                                  style: GoogleFonts.montserrat(fontSize: 16, color: kPrimaryDarkColor),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: kPrimaryLightColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 7),
                child: InkWell(
                  onTap: () => {},
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 25, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                invoiceName,
                                maxLines: 1,
                                overflow:TextOverflow.ellipsis,
                                style: cardTitleTextStyle().copyWith(
                                  fontSize: 16,
                                  color: kPrimaryDarkColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewNewPdf(pdfUrl:invoiceUrl)));
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
                                child: Text(
                                  'View',
                                  style: GoogleFonts.montserrat(fontSize: 16, color: kPrimaryDarkColor),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: kPrimaryLightColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
