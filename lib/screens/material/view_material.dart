import 'dart:convert';
import 'dart:io';

import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/screens/bottom_nav_pages/homepage.dart';
import 'package:acesteels/widgettree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';

import '../homeWithBn.dart';
import '../viewNewPdf.dart';

CollectionReference materialRef = FirebaseFirestore.instance.collection("material");
CollectionReference tokenRef = FirebaseFirestore.instance.collection("users");
CollectionReference adminOrderRef = FirebaseFirestore.instance.collection('admin').doc("orders").collection("ongoing");


class ViewMaterial extends StatefulWidget {
  final String materialId;
  final String userId;
  final String jobId;
  final Color colorBg;
  final Color colorText;

  const ViewMaterial({this.materialId, this.userId, this.jobId,this.colorBg,this.colorText});

  @override
  _ViewMaterialState createState() => _ViewMaterialState();
}

class _ViewMaterialState extends State<ViewMaterial> {
  String materialDesc = "";
  String materialName = "";
  String jobName = "";
  String materialQuantity = "";
  String materialDate = "";
  String fileNameNew = "Attach a Document (PDF)";
  File file;
  String fileUrl = "";
  String tokenId = "";
  String date = "";
  String pdfName = "PDF NAME";

  @override
  void initState() {
    super.initState();
    getDate();
  }

  getDate() async {
    var materialData = await materialRef.doc(widget.userId).collection("ongoing").doc(widget.materialId).get();
    var userRef = await tokenRef.doc(widget.userId).get();
    setState(() {
      date = materialData.data()["startDate"];
      materialName = materialData.data()["materialName"];
      jobName = materialData.data()["jobName"];
      materialDesc = materialData.data()["materialDesc"];
      materialDate = DateFormat.yMEd().format(DateTime.parse(materialData.data()["startDate"]));
      materialQuantity = materialData.data()["quantity"];
      fileUrl = materialData.data()["pdfUrl"];
      pdfName = materialData.data()["pdfName"];
      tokenId = userRef.data()["tokenId"];
    });
  }


  orderQuote() async{
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    var materialData = await materialRef.doc(FirebaseAuth.instance.currentUser.uid).collection("ongoing").doc(widget.materialId).get();
    await adminOrderRef.doc(widget.materialId).set({"materialId":widget.materialId,
      "jobId":materialData["jobId"],
      "userId":FirebaseAuth.instance.currentUser.uid,
      "timeStamp":DateTime.now(),
      "materialName":materialName,
      "startDate":date,
    }).whenComplete((){
      animatedLoader.removeDialog();
      Navigator.pop(context);
    });

    Future<Response> sendNotification(List<String> tokenIdList, String contents, String heading) async{

      return await post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>
        {
          "app_id": kAppId,
          "include_player_ids": tokenIdList,
          "android_accent_color":"FF9976D2",
          "small_icon":"ic_stat_onesignal_default",
          "large_icon":"https://www.filepicker.io/api/file/zPloHSmnQsix82nlj9Aj?filename=name.jpg",
          "contents": {"en": contents},
          "headings": {"en": heading},
        }),
      );
    }

    sendNotification(adminTokenIdList, materialData["materialName"], "Your Order is Submitted" );
    await materialRef.doc(userId).collection("ongoing").doc(widget.materialId).update({"status":"Ordered",'variableTimeStamp': DateTime.now(),});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, right: 12, left: 12, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, right: 25),
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      color: widget.colorText,
                    ))),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 7),
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:widget.colorBg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      materialName,
                      style: cardTitleTextStyle().copyWith(
                        fontSize: 26,
                        color: widget.colorText,
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
                              color: widget.colorText,
                              fontSize: 12,
                              letterSpacing: 0.9,
                            ),
                            children: [
                              TextSpan(
                                  text: jobName,
                                  style: cardSubHeadTextStyle().copyWith(
                                    color: widget.colorText.withOpacity(0.6),
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
                              color: widget.colorText,
                              fontSize: 12,
                              letterSpacing: 0.9,
                            ),
                            children: [
                              TextSpan(
                                  text: materialName,
                                  style: cardSubHeadTextStyle().copyWith(
                                    color: widget.colorText.withOpacity(0.6),
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
                              color: widget.colorText,
                              fontSize: 12,
                              letterSpacing: 0.9,
                            ),
                            children: [
                              TextSpan(
                                  text: materialQuantity,
                                  style: cardSubHeadTextStyle().copyWith(
                                    color: widget.colorText.withOpacity(0.6),
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
                              color: widget.colorText,
                              fontSize: 12,
                              letterSpacing: 0.9,
                            ),
                            children: [
                              TextSpan(
                                  text: materialDate,
                                  style: cardSubHeadTextStyle().copyWith(
                                    color: widget.colorText.withOpacity(0.6),
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
                              color: widget.colorText,
                              fontSize: 12,
                              letterSpacing: 0.9,
                            ),
                            children: [
                              TextSpan(
                                text: materialDesc,
                                style: cardSubHeadTextStyle().copyWith(
                                  color: widget.colorText.withOpacity(0.6),
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
                    color: widget.colorBg,
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
                              pdfName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: cardTitleTextStyle().copyWith(
                                fontSize: 16,
                                color: widget.colorText,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final url = fileUrl;
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewNewPdf(pdfUrl:fileUrl)));

                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
                              child: Text(
                                'View',
                                style: GoogleFonts.montserrat(fontSize: 16, color: widget.colorText),
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
              height: 70,
            ),
            Center(
              child: SliderButton(
                height: 55,
                buttonSize: 50,
                vibrationFlag: true,
                alignLabel: Alignment.center,
                shimmer: true,
                dismissible: false,
                action: () => orderQuote(),
                label: Text(
                  'Place Order',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: widget.colorText),
                  textAlign: TextAlign.center,
                ),
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red,
                ),
                backgroundColor: Colors.red[500].withOpacity(0.2),
                boxShadow: BoxShadow(
                  color: Colors.red[500].withOpacity(0.4),
                  blurRadius: 4,
                ),
                baseColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
