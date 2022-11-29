import 'dart:async';
import 'dart:convert';
import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/screens/homeWithBn.dart';
import 'package:acesteels/screens/jobs/add_new_job.dart';
import 'package:acesteels/screens/material/addmaterial.dart';
import 'package:acesteels/screens/material/view_material.dart';
import 'package:acesteels/widgettree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';



final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference materialRef = FirebaseFirestore.instance.collection('material');
CollectionReference userDataRef = FirebaseFirestore.instance.collection('users');

CollectionReference adminQuoteRef = FirebaseFirestore.instance.collection('admin').doc("quotes").collection("ongoing");
CollectionReference adminAcceptedRef = FirebaseFirestore.instance.collection('admin').doc("quotes").collection("accepted");
CollectionReference adminOrderRef = FirebaseFirestore.instance.collection('admin').doc("orders").collection("ongoing");
String playerId="";
String userId = "";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int countCard = 5;
  String userName = "";


  Map<String,String> isValidMAp = {};
  DateTime timeNow = DateTime.now();


  GlobalKey targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final _auth = FirebaseAuth.instance;
    User _user = _auth.currentUser;
    if (_user != null) {
      users.doc(firebaseAuth.currentUser.uid).get().then((doc) {
        if(doc.exists){
          setState(() {
            userId = firebaseAuth.currentUser.uid;
          });
          getPlayerId();
          getUserName();
        }
        // initTarget();
      });

    }
  }

  void getPlayerId() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    playerId = status.subscriptionStatus.userId;
    await users.doc(firebaseAuth.currentUser.uid).update({"tokenId" : playerId});
  }

  getUserName() async{

    DocumentSnapshot snapshot = await userDataRef.doc(firebaseAuth.currentUser.uid).get();
    setState(() {
      userName = snapshot.data()["fName"];
    });


  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 30.0, right: 10, left: 14, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap:()=>getPlayerId(),
                        child: Text(
                          'Hi,' + "$userName",
                          style: headTextStyle(),
                        ),
                      ),
                      SizedBox(
                        height: countCard == 0 ? 30 : 10,
                      ),
                      Container(
                        // key: targetKey,
                        child: Text(
                          countCard == 0 ? '' : 'Materials you\'ll require in \nNext 15 days',
                          style: subHeadTextStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                userId!=""?
                StreamBuilder<QuerySnapshot> (
                  stream:  materialRef.doc(userId).collection("ongoing").snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return SpinKitDoubleBounce(
                        color: Color(0xFFC850C0),
                        size: 100.0,
                      );
                    }


                    List<DocumentSnapshot> materials = [];
                      snapshot.data.docs.map((e)  {
                        DateTime checkTime = DateTime.parse(e["startDate"]);

                        Duration durationFound = checkTime.difference(timeNow);

                        if((durationFound <= Duration(days: 15) || e["status"].toString().compareTo("Quoted") == 0) &&
                            e["status"].toString().compareTo("Ordered") !=0 && e["status"].toString().compareTo("Completed") !=0
                            &&  e["isDeleted"].toString().compareTo("false") == 0){
                          materials.add(e);
                        }

                      }).toList();

                    if(materials.length == 0){
                      // showTutorial();
                      return DottedBorder(
                        color: kPrimaryDarkColor,
                        strokeWidth: 1,
                        strokeCap: StrokeCap.round,
                        dashPattern: [4, 8],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        child: Container(
                          height: 170,
                          width: width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: InkWell(
                                  onTap:()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNewJob())),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: kPrimaryLightColor,
                                    ),
                                    height: 40,
                                    width: 40,
                                    child: Icon(
                                      LineIcons.plus,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Add New Task',
                                style: subHeadTextStyle(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Expanded(
                      child: GridView.builder(
                        itemCount: materials.length,
                        padding: EdgeInsets.only(bottom: 20.0, top: 10.0, left: 6, right: 6),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: width * 0.42 / 180,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return HomeCard(
                            colorBg: cardColorsHome[index % cardColorsHome.length][1],
                            colorText: cardColorsHome[index % cardColorsHome.length][0],
                            materialName: materials[index]["materialName"],
                            jobName: materials[index]["jobName"],
                            isValid: DateTime.parse(materials[index]["startDate"]).difference(timeNow) <= Duration(days: 0),
                            date: DateFormat.yMEd().format(DateTime.parse(materials[index]["startDate"])),
                            materialID: materials[index]["materialId"],
                            status: materials[index]["status"],
                            userId: userId,
                            jobId: materials[index]["jobId"],
                            quantity: materials[index]["quantity"],
                          );
                        },
                      ),
                    );
                  },
                ):Container(),
              ],
            ),
          )),
    );
  }
}

class HomeAddNewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: kPrimaryDarkColor,
      strokeWidth: 1,
      strokeCap: StrokeCap.round,
      dashPattern: [4, 8],
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: kPrimaryLightColor,
                ),
                height: 40,
                width: 40,
                child: Icon(
                  LineIcons.plus,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Add New Job',
              style: subHeadTextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    @required this.colorBg,
    @required this.colorText,
    @required this.materialName,
    @required this.jobName,
    @required this.jobId,
    @required this.date,
    @required this.isValid,
    @required this.materialID,
    @required this.userId,
    @required this.status,
    @required this.quantity,

  });

  final Color colorBg;
  final Color colorText;
  final String materialName;
  final String jobName;
  final String jobId;
  final String date;
  final bool isValid;
  final String userId;
  final String materialID;
  final String status;
  final String quantity;

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

  requestQuote() async{
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    var materialData = await materialRef.doc(userId).collection("ongoing").doc(materialID).get();
    await adminQuoteRef.doc(materialID).set({"materialId":materialID,
      "jobId":materialData["jobId"],
      "userId":firebaseAuth.currentUser.uid,
      "timeStamp":DateTime.now(),
      "materialName":materialData["materialName"],
      "startDate":materialData["startDate"],
    });

      sendNotification(adminTokenIdList, materialData["materialName"], "Your Quotation is Submitted" );
      await materialRef.doc(userId).collection("ongoing").doc(materialID).update({"status":"Quoted",'variableTimeStamp': DateTime.now(),}).whenComplete(()=>animatedLoader.removeDialog());

  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=> status == "added"?Navigator.push(context, MaterialPageRoute(builder: (context)=>AddMaterial(jobId: jobId, jobName: jobName,materialId: materialID,))):(){},
      child: Container(
        padding: EdgeInsets.only(left: 12, right: 8, top: 15, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorBg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    materialName,
                    overflow: TextOverflow.ellipsis,
                    style: cardTitleTextStyle().copyWith(
                      color: colorText,
                    ),

                  ),
                ),
                InkWell(
                  onTap: () async {
                    await adminAcceptedRef.doc(materialID).delete();
                    await materialRef.doc(userId).collection("ongoing").doc(materialID).update({"isDeleted":"true","status":"Deleted"});
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Icon(CupertinoIcons.delete, size: 18, color: Colors.redAccent,),
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: 'Job : ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorText, fontSize: 10, ),
                        children: [
                          TextSpan(
                              text: jobName,
                              style: cardSubHeadTextStyle().copyWith(
                                color: colorText.withOpacity(0.6),
                              ))
                        ])),
                SizedBox(
                  height: 8,
                ),
                RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: 'Date : ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorText, fontSize: 10,),
                        children: [
                          TextSpan(
                              text: date,
                              style: cardSubHeadTextStyle().copyWith(color: colorText.withOpacity(0.6),))
                        ])),
                SizedBox(
                  height: 8,
                ),
                RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: 'Quantity : ',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorText, fontSize: 10,),
                        children: [
                          TextSpan(
                              text: quantity, style: cardSubHeadTextStyle().copyWith(color: colorText.withOpacity(0.6),))
                        ])),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: (){
                    if(isValid){
                      final snackBar = SnackBar(content: Text('Please change your Quote date and try again'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    else if(status.compareTo("added") ==0 ){
                      requestQuote();
                    }else if(status.compareTo("Quoted") ==0){
                      final snackBar = SnackBar(content: Text('Please wait till your Quotation is Accepted'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else if(status.compareTo("Accepted") ==0){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewMaterial(materialId: materialID,jobId: jobId,userId: userId,colorBg: colorBg,colorText: colorText,),),);
                    }
                  },
                  child: Container(
                    height: 30,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        isValid ? "Expired" : status.compareTo("added") == 0 ? "Quote": status.compareTo("Accepted") == 0? "Order" : "Waiting",
                        style: cardSubHeadTextStyle().copyWith(fontSize: 14, color: colorText),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
