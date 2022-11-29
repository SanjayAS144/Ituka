import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/screens/homeWithBn.dart';
import 'package:acesteels/screens/material/delete_material.dart';
import 'package:acesteels/screens/material/view_order.dart';
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
CollectionReference materialRef = FirebaseFirestore.instance.collection('material').doc(firebaseAuth.currentUser.uid).collection("ongoing");
CollectionReference quoteRef = FirebaseFirestore.instance.collection('material').doc(firebaseAuth.currentUser.uid).collection("ongoing");
CollectionReference adminOrderRef = FirebaseFirestore.instance.collection('admin').doc("orders").collection("ongoing");


class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String status = "ordered";

  setBadgeVal() async {
    await users.doc(firebaseAuth.currentUser.uid).update({"hasCompleted" : "false"});
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
                  'Your Orders',
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
                        Text('Ordered'),
                      hasCompleted.compareTo("true") == 0 ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Completed '),
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
                      ) : Text('Completed'),
                      ],
                      onTap: (index) {
                        setState(() {
                          if(index == 1){
                            status = "completed";
                            setState(() {
                              hasCompleted = "false";
                            });
                            setBadgeVal();
                          }else{
                            status = "ordered";
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
                    stream: quoteRef.orderBy("variableTimeStamp",descending: true,).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return SpinKitDoubleBounce(
                          color: Color(0xFFC850C0),
                          size: 100.0,
                        );
                      }
                      int count = 0;
                      int num = snapshot.data.size;

                      List<DocumentSnapshot> orderedMaterialList = [];
                      List<DocumentSnapshot> completedMaterialList = [];

                      snapshot.data.docs.map((e) {
                        if(e["status"].toString().compareTo("Ordered") == 0){
                          orderedMaterialList.add(e);
                        }else if(e["status"].toString().compareTo("Completed") == 0){
                          completedMaterialList.add(e);
                        }

                      }).toList();

                      if(orderedMaterialList.isNotEmpty && status.compareTo("ordered") == 0)
                      {

                      return ListView.builder(
                        itemCount:status == "ordered" ? orderedMaterialList.length:completedMaterialList.length,
                        itemBuilder: (context, pos) {
                          return OrderCard(
                            colorBg: cardColorsHome[pos % cardColorsHome.length][1],
                            colorText: cardColorsHome[pos % cardColorsHome.length][0],
                            materialName: status == "ordered" ? orderedMaterialList[pos]["materialName"]:completedMaterialList[pos]["materialName"],
                            startDate: DateFormat.yMEd().format(DateTime.parse(status == "ordered" ? orderedMaterialList[pos]["startDate"]:completedMaterialList[pos]["startDate"])),
                            materialId: status == "ordered" ? orderedMaterialList[pos]["materialId"]:completedMaterialList[pos]["materialId"],
                            isCompleted: status == "completed" ?true:false,
                            jobId:orderedMaterialList[pos]["jobId"],
                          );
                        },
                        );
                      }

                      else if(completedMaterialList.isNotEmpty && status.compareTo("completed") == 0)
                      {

                        return ListView.builder(
                          itemCount:status == "ordered" ? orderedMaterialList.length:completedMaterialList.length,
                          itemBuilder: (context, pos) {
                            return OrderCard(
                              colorBg: cardColorsHome[pos % cardColorsHome.length][1],
                              colorText: cardColorsHome[pos % cardColorsHome.length][0],
                              materialName: status == "ordered" ? orderedMaterialList[pos]["materialName"]:completedMaterialList[pos]["materialName"],
                              startDate: DateFormat.yMEd().format(DateTime.parse(status == "ordered" ? orderedMaterialList[pos]["startDate"]:completedMaterialList[pos]["startDate"])),
                              materialId: status == "ordered" ? orderedMaterialList[pos]["materialId"]:completedMaterialList[pos]["materialId"],
                              isCompleted: status == "completed" ?true:false,
                              jobId:status == "ordered" ? orderedMaterialList[pos]["jobId"]:completedMaterialList[pos]["jobId"],
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

class OrderCard extends StatelessWidget {
  const OrderCard({
    @required this.colorBg,
    @required this.colorText,
    @required this.materialName,
    @required this.startDate,
    @required this.materialId,
    @required this.isCompleted,
    @required this.jobId,
  });

  final Color colorBg;
  final Color colorText;
  final String materialName;
  final String startDate;
  final String materialId;
  final String jobId;
  final bool isCompleted;

  deleteOrder()async {
    await materialRef.doc(materialId).update({"isDeleted":"true","status": "Deleted"});
    await adminOrderRef.doc(materialId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 7),
      child: InkWell(
        onTap: (){
          if(isCompleted){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewOrder(materialId:materialId)));
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context)=>DeleteOrder(materialId: materialId,jobId: jobId,userId: userId,colorBg: colorBg,colorText: colorText,)));
          }
        },
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
                  isCompleted ? Container() : InkWell(
                    onTap: deleteOrder,
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Icon(CupertinoIcons.delete, size: 18, color: Colors.redAccent,),
                      ),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          'Create a Project and make an order',
          style: GoogleFonts.montserrat(fontSize: 20, color: kPrimaryDarkColor, fontWeight: FontWeight.w400),
        )
      ],
    );
  }
}
