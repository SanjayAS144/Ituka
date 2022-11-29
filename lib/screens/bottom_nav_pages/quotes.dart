import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/screens/homeWithBn.dart';
import 'package:acesteels/screens/material/view_material.dart';
import 'package:badges/badges.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference quoteRef = FirebaseFirestore.instance.collection('material').doc(firebaseAuth.currentUser.uid).collection("ongoing");

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String status = "ongoing";

  setBadgeVal() async {
    await users.doc(firebaseAuth.currentUser.uid).update({"hasAccepted" : "false"});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 40.0, right: 20, left: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Quotes',
                  style: headTextStyle(),
                ),
                SizedBox(height: 20,),
                DefaultTabController(
                  length: 2,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: TabBar(
                      indicator: BubbleTabIndicator(
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                        indicatorHeight: 50.0,
                        indicatorColor: kPrimaryLightColor,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 19.0,
                        letterSpacing: 1.5,
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.bold,
                      ),
                      labelColor: kPrimaryDarkColor,
                      unselectedLabelColor: kPrimaryLightColor,
                      tabs: [
                        Text('Ongoing'),
                        hasAccepted.compareTo("true") == 0 ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Accepted '),
                            Badge(
                              badgeColor: Colors.red.shade300,
                              elevation: 0,
                              position: BadgePosition.topEnd(top: -12, end: -12),
                              badgeContent: Text(
                                '',
                                style: TextStyle(color: Colors.red,),
                              ),

                            )
                          ],
                        ) : Text('Accepted'),
                      ],

                      onTap: (index) {
                         setState(() {
                           if(index == 1){
                             status = "accepted";
                             setState(() {
                               hasAccepted = "false";
                               setBadgeVal();
                             });
                           }else{
                             status = "ongoing";
                           }

                         });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: quoteRef.orderBy("variableTimeStamp",descending: true).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return SpinKitDoubleBounce(
                                color: Color(0xFFC850C0),
                                size: 100.0,
                              );
                            }
                            int count = 0;
                            int num = snapshot.data.size;

                            List<DocumentSnapshot> quotedMaterials = [];
                            List<DocumentSnapshot> acceptedMaterials = [];

                            snapshot.data.docs.map((e) {

                              if(e["status"].toString().compareTo("Quoted") == 0){
                                quotedMaterials.add(e);
                              }else if(e["status"].toString().compareTo("Accepted") == 0){
                                acceptedMaterials.add(e);
                              }

                            }).toList();

                            if(quotedMaterials.isNotEmpty && status.compareTo("ongoing") == 0){

                              return ListView.builder(
                              itemCount:status == "ongoing" ? quotedMaterials.length:acceptedMaterials.length,
                              itemBuilder: (context, pos) {
                                return QuoteCard(
                                  colorBg: cardColorsHome[pos % cardColorsHome.length][1],
                                  colorText: cardColorsHome[pos % cardColorsHome.length][0],
                                  materialName: status == "ongoing" ? quotedMaterials[pos]["materialName"]:acceptedMaterials[pos]["materialName"],
                                  startDate: DateFormat.yMEd().format(DateTime.parse(status == "ongoing" ? quotedMaterials[pos]["startDate"]:acceptedMaterials[pos]["startDate"])),
                                  materialId: status == "ongoing" ? quotedMaterials[pos]["materialId"]:acceptedMaterials[pos]["materialId"],
                                  isAccepted: status == "accepted" ?true:false,
                                  userId: firebaseAuth.currentUser.uid,
                                  jobId: status == "ongoing" ? quotedMaterials[pos]["jobId"]:acceptedMaterials[pos]["jobId"],
                                );
                              },
                            );
                            }

                            else if(acceptedMaterials.isNotEmpty && status.compareTo("accepted") == 0){

                              return ListView.builder(
                                itemCount:status == "ongoing" ? quotedMaterials.length:acceptedMaterials.length,
                                itemBuilder: (context, pos) {
                                  return QuoteCard(
                                    colorBg: cardColorsHome[pos % cardColorsHome.length][1],
                                    colorText: cardColorsHome[pos % cardColorsHome.length][0],
                                    materialName: status == "ongoing" ? quotedMaterials[pos]["materialName"]:acceptedMaterials[pos]["materialName"],
                                    startDate: DateFormat.yMEd().format(DateTime.parse(status == "ongoing" ? quotedMaterials[pos]["startDate"]:acceptedMaterials[pos]["startDate"])),
                                    materialId: status == "ongoing" ? quotedMaterials[pos]["materialId"]:acceptedMaterials[pos]["materialId"],
                                    isAccepted: status == "accepted" ?true:false,
                                    userId: firebaseAuth.currentUser.uid,
                                    jobId: status == "ongoing" ? quotedMaterials[pos]["jobId"]:acceptedMaterials[pos]["jobId"],
                                  );
                                },
                              );
                            }
                            else
                              return EmptyQuote();
                          },
                        ),
                      ),
              ],
            ),
          )),
    );
  }
}

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    @required this.colorBg,
    @required this.colorText,
    @required this.materialName,
    @required this.startDate,
    @required this.materialId,
    @required this.jobId,
    @required this.userId,
    @required this.isAccepted,
  });

  final Color colorBg;
  final Color colorText;
  final String materialName;
  final String startDate;
  final String materialId;
  final String jobId;
  final String userId;
  final bool isAccepted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 7),
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 10),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materialName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: cardTitleTextStyle().copyWith(
                          fontSize: 24,
                          color: colorText,
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(startDate,
                              style: cardSubHeadTextStyle().copyWith(
                                color: colorText.withOpacity(0.8),
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
               isAccepted? InkWell(
                 onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewMaterial(materialId: materialId,jobId: jobId,userId: userId,colorBg: colorBg,colorText: colorText,)));
                 },
                 child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
                    child: Text(
                      'View',
                      style: GoogleFonts.montserrat(fontSize: 16, color: colorText),
                    ),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  ),
               ) : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyQuote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "lib/images/noquotegif.gif",
        ),
        Text(
          'Create a Project and Raise a Quote',
          style: GoogleFonts.montserrat(fontSize: 20, color: kPrimaryDarkColor, fontWeight: FontWeight.w400),
        )
      ],
    );
  }
}
