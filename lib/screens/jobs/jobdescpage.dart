import 'dart:convert';
import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/screens/bottom_nav_pages/homepage.dart';
import 'package:acesteels/screens/material/addmaterial.dart';
import 'package:acesteels/widgettree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../homeWithBn.dart';

List<String> quotedMaterials = [];
List<String> deletedMaterials = [];

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference materialRef =
    FirebaseFirestore.instance.collection('material').doc(firebaseAuth.currentUser.uid).collection("ongoing");
CollectionReference quoteRef =
    FirebaseFirestore.instance.collection('quotes').doc(firebaseAuth.currentUser.uid).collection("ongoing");
CollectionReference adminQuoteRef = FirebaseFirestore.instance.collection('admin').doc("quotes").collection("ongoing");
CollectionReference adminRef = FirebaseFirestore.instance.collection('admin');
CollectionReference jobRef = FirebaseFirestore.instance.collection('jobs').doc(firebaseAuth.currentUser.uid).collection("ongoing");

CollectionReference adminAcceptedRef =
    FirebaseFirestore.instance.collection('admin').doc("quotes").collection("accepted");

class JobDescPage extends StatefulWidget {
  JobDescPage({
    @required this.jobId,
    @required this.colorBg,
    @required this.colorText,
    @required this.jobTitle,
    @required this.jobDesc,
    @required this.jobDate,
  });

  final String jobId;
  final String jobTitle;
  final String jobDesc;
  final String jobDate;
  final Color colorBg;
  final Color colorText;

  @override
  _JobDescPageState createState() => _JobDescPageState();
}

class _JobDescPageState extends State<JobDescPage> {
  bool isChecked = false;
  int countCard = 10;
  String jobName = "";

  Map<String, String> allMaterialId = {};
  openAlertDialog() {
    Alert(
      context: context,
      title: "Are you Sure",
      type: AlertType.warning,
      desc: "You want to delete This Job.",
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [Color.fromRGBO(116, 116, 191, 1.0), Color.fromRGBO(52, 138, 199, 1.0)]),
        ),
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => deleteJob(),
          color: Colors.red,
        )
      ],
    ).show();
  }

  deleteJob() async{
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    deletedMaterials = allMaterialId.values.toList();
    for(var materialId in deletedMaterials){
      await materialRef.doc(materialId).delete();
      print(materialId);
    }
    await jobRef.doc(widget.jobId).update({"isDeleted":true});
    animatedLoader.removeDialog();
    Navigator.pop(context);
    Navigator.pop(context);
   // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route) => false);
  }

  Future<Response> sendNotification(List<String> tokenIdList, String contents, String heading) async {
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id": kAppId,
        "include_player_ids": tokenIdList,
        "android_accent_color": "FF9976D2",
        "small_icon": "ic_stat_onesignal_default",
        "large_icon": "https://www.filepicker.io/api/file/zPloHSmnQsix82nlj9Aj?filename=name.jpg",
        "contents": {"en": contents},
        "headings": {"en": heading},
      }),
    );
  }

  showAlert() {
    return Alert(
      context: context,
      title: "Can Not Quote",
      desc: "Select a Material to Request Quote.",
      buttons: [
        DialogButton(
          child: Text(
            "Select",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  requestQuote() async {
    if (quotedMaterials.isEmpty) {
      showAlert();
    } else {
      for (String materialId in quotedMaterials) {
        var materialData = await materialRef.doc(materialId).get();
        await adminQuoteRef.doc(materialId).set({
          "materialId": materialId,
          "jobId": widget.jobId,
          "userId": firebaseAuth.currentUser.uid,
          "timeStamp": DateTime.now(),
          "materialName": materialData["materialName"],
          "startDate": materialData["startDate"],
        });
        sendNotification(adminTokenIdList, materialData["materialName"], "Your Quotation is Submitted");
        await materialRef.doc(materialId).update({
          "status": "Quoted",
          'variableTimeStamp': DateTime.now(),
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    jobName = widget.jobTitle;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, right: 25),
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      color: kPrimaryDarkColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => openAlertDialog(),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.colorBg,
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.delete,
                        color: widget.colorText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 7),
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.colorBg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      jobName,
                      style: cardTitleTextStyle().copyWith(
                        fontSize: 24,
                        color: widget.colorText,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.jobDate,
                            style: cardSubHeadTextStyle().copyWith(
                              color: widget.colorText.withOpacity(0.8),
                              fontSize: 14,
                            )),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          widget.jobDesc,
                          style: cardSubHeadTextStyle().copyWith(
                            color: widget.colorText.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Select All',
                  style: GoogleFonts.montserrat(fontSize: 18, color: widget.colorText),
                ),
                Checkbox(
                  value: isChecked,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value;
                      if (isChecked)
                        quotedMaterials = allMaterialId.values.toList();
                      else
                        quotedMaterials = [];
                    });
                  },
                  activeColor: kPrimaryLightColor,
                  checkColor: kPrimaryDarkColor,
                )
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.colorBg,
              ),
              padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Materials Needed',
                    style: cardTitleTextStyle().copyWith(
                      fontSize: 20,
                      color: widget.colorText,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: materialRef.orderBy("status", descending: true).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return SpinKitDoubleBounce(
                            color: Color(0xFFC850C0),
                            size: 100.0,
                          );
                        }

                        List<DocumentSnapshot> materials = [];

                        snapshot.data.docs.map((e) {
                          if (e["jobId"].toString().compareTo(widget.jobId) == 0 &&
                              e["status"].toString().compareTo("Completed") != 0 &&
                              e["status"].toString().compareTo("Ordered") != 0) {
                            materials.add(e);
                            if (e["status"].toString().compareTo("added") == 0) {
                              allMaterialId[e["materialId"]] = e["materialId"];
                            }
                          }
                        }).toList();

                        return ListView.builder(
                          itemCount: materials.length,
                          itemBuilder: (context, pos) {
                            return QuoteCard(
                              colorBg: cardColorsHome[pos % cardColorsHome.length][1],
                              allSelected: isChecked,
                              colorText: cardColorsHome[pos % cardColorsHome.length][0],
                              materialName: materials[pos]["materialName"],
                              startDate: materials[pos]["startDate"],
                              materialId: materials[pos]["materialId"],
                              status: materials[pos]["status"],
                              quantity: materials[pos]["quantity"],
                              jobId: widget.jobId,
                              jobName: jobName,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => requestQuote(),
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
                          child: Text(
                            'Request Quote',
                            style: GoogleFonts.montserrat(fontSize: 16, color: widget.colorText),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.redAccent, width: 0.7),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddMaterial(
                                        jobId: widget.jobId,
                                        jobName: widget.jobTitle,
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            CupertinoIcons.plus,
                            color: widget.colorText,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuoteCard extends StatefulWidget {
  QuoteCard({
    @required this.colorBg,
    @required this.colorText,
    this.allSelected,
    this.isCheckedNew = false,
    @required this.materialName,
    @required this.startDate,
    @required this.materialId,
    @required this.status,
    @required this.quantity,
    @required this.jobId,
    @required this.jobName,
  });

  final Color colorBg;
  final Color colorText;
  final bool allSelected;
  bool isCheckedNew;

  final String materialName;
  final String startDate;
  final String materialId;
  final String status;
  final String quantity;
  final String jobId;
  final String jobName;

  @override
  _QuoteCardState createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {


  openAlertDialog() {
    Alert(
      context: context,
      title: "Are you Sure",
      type: AlertType.warning,
      desc: "You want to delete This Material.",
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [Color.fromRGBO(116, 116, 191, 1.0), Color.fromRGBO(52, 138, 199, 1.0)]),
        ),
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => deleteMaterial(),
          color: Colors.red,
        )
      ],
    ).show();
  }

  deleteMaterial() async {
    Navigator.pop(context);
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    await adminAcceptedRef.doc(widget.materialId).delete();
    await adminQuoteRef.doc(widget.materialId).delete();
    await materialRef.doc(widget.materialId).delete();
    animatedLoader.removeDialog();

  }



  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.status == "added"
          ? Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddMaterial(
                        jobId: widget.jobId,
                        jobName: widget.jobName,
                        materialId: widget.materialId,
                      )))
          : () {},
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 7),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.colorText.withOpacity(0.7),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.materialName,
                              overflow: TextOverflow.ellipsis,
                              style: cardTitleTextStyle().copyWith(
                                fontSize: 20,
                                color: widget.colorText,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.quantity,
                                    style: cardSubHeadTextStyle().copyWith(
                                      color: widget.colorText.withOpacity(0.8),
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                      widget.status.toString().compareTo("added") == 0
                          ? Checkbox(
                              value: widget.allSelected ? true : widget.isCheckedNew,
                              onChanged: (value) {
                                setState(() {
                                  widget.isCheckedNew = value;
                                  quotedMaterials.add(widget.materialId);
                                });
                              },
                              activeColor: Colors.white,
                              checkColor: widget.colorText,
                            )
                          : Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Text(widget.status),
                            ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  openAlertDialog();
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                    CupertinoIcons.delete,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
