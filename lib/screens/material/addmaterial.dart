import 'dart:math';

import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/local_notifications/notifications.dart';
import 'package:acesteels/widget/materialdropdown.dart';
import 'package:acesteels/widgettree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference jobRef = FirebaseFirestore.instance.collection('jobs');
CollectionReference newMaterialRef = FirebaseFirestore.instance.collection('material');

class AddMaterial extends StatefulWidget {
  final String jobId;
  final String jobName;
  final String materialId;

  const AddMaterial({@required this.jobId, @required this.jobName, this.materialId = ""});

  @override
  _AddMaterialState createState() => _AddMaterialState();
}

class _AddMaterialState extends State<AddMaterial> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String materialName = "", materialDesc = "Not Provided", startDate = "Start Date", quantity = "";
  DateTime selected;
  String _chosenValue = "";
  String material = "Select a Material";
  TextEditingController quantityController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController materialNameController = TextEditingController();
  String materialDataName = "";
  List<String> materialDropDown = ['Select a Material', 'Steel', 'Cement', 'Sand', 'Others'];

  final Notifications _notifications = Notifications();

  @override
  void initState() {
    super.initState();
    initNotifies();
    getMaterialDate();
  }



  //init notifications
  Future initNotifies() async => flutterLocalNotificationsPlugin = await _notifications.initNotifies(context);
  DateTime setDate = DateTime.now();

  DateTime selectedDate = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  Uuid _uuid = Uuid();

  void getBasicDetails() async {
    FocusScope.of(context).unfocus();
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    if (materialName.isEmpty ||
        startDate.isEmpty ||
        quantity.isEmpty ||
        materialName.compareTo("Others") == 0 ||
        startDate.compareTo("Start Date") == 0) {
      final snackBar = SnackBar(content: Text('Enter all the Details Correctly!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      animatedLoader.removeDialog();
    } else {
      final String materialId = _uuid.v4();

      var userSiteAddress = {
        'materialId': materialId,
        'jobId': widget.jobId,
        'jobName': widget.jobName,
        'materialName': materialName,
        'materialDesc': materialDesc,
        'startDate': startDate,
        'status': "added",
        'isDeleted': "false",
        'quantity': quantity,
        'timeStamp': DateTime.now(),
        'variableTimeStamp': DateTime.now(),
      };



      await jobRef
          .doc(firebaseAuth.currentUser.uid)
          .collection("ongoing")
          .doc(widget.jobId)
          .collection("materials")
          .doc(materialId)
          .set({"materialId": materialId});

      if (start.difference(DateTime.now()) > Duration(days: 3)) {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
        await _notifications.showNotification(
            materialName,
            "Your material for ${widget.jobName} will expire in next 7 days",
            time,
            Random().nextInt(10000000),
            flutterLocalNotificationsPlugin);
      }

      // add a nw material or update the data of the existing material......................

      if (widget.materialId != "") {
        userSiteAddress.update("materialId", (value) => widget.materialId);
        await newMaterialRef
            .doc(firebaseAuth.currentUser.uid)
            .collection("ongoing")
            .doc(widget.materialId)
            .update(userSiteAddress)
            .whenComplete(() {
          final snackBar = SnackBar(content: Text('Successfully Updated a Material'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          animatedLoader.removeDialog();
          Navigator.pop(context);
        });
      }
      else {
        await newMaterialRef
            .doc(firebaseAuth.currentUser.uid)
            .collection("ongoing")
            .doc(materialId)
            .set(userSiteAddress)
            .whenComplete(() {
          final snackBar = SnackBar(content: Text('Successfully Added a Material'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          animatedLoader.removeDialog();
          Navigator.pop(context);
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked =
        await showDatePicker(context: context, initialDate: end, firstDate: DateTime.now(), lastDate: DateTime(2101));
    if (picked != null && picked != start) {
      DateTime newDate = DateTime(
          picked.year,
          picked.month,
          picked.difference(DateTime.now()) <= Duration(days: 7) &&
                  picked.difference(DateTime.now()) > Duration(days: 3)
              ? picked.day - 2
              : picked.day - 7,
          Random().nextInt(12) + 10,
          Random().nextInt(60));
      setState(() {
        start = picked;
        selectedDate = picked;
        setDate = newDate;
        startDate = start.toString();
        FocusScope.of(context).unfocus();
      });
    }
  }

  getMaterialDate() async {
    if (widget.materialId != "") {
      var materialData =
          await newMaterialRef.doc(firebaseAuth.currentUser.uid).collection("ongoing").doc(widget.materialId).get();
      setState(() {

        materialName = materialData.data()["materialName"];
        if(materialDropDown.contains(materialName)){
          material = materialName;
        }else{
          material = "Others";
        }
        materialNameController.text = materialData.data()["materialName"];
        quantityController.text = materialData.data()["quantity"];
        quantity = materialData.data()["quantity"];
        descController.text = materialData.data()["materialDesc"];
        materialDesc = materialData.data()["materialDesc"];
        startDate = materialData.data()["startDate"];
        selectedDate = DateTime.parse(materialData.data()["startDate"]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthDevice = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'New Material',
            style: GoogleFonts.montserrat(
              color: kPrimaryDarkColor,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  padding: EdgeInsets.only(top: 12, bottom: 10, right: 25, left: 15),
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    color: kPrimaryDarkColor,
                  ))),
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 22,
              ),
              MaterialDropDown(
                  materials: ['Select a Material', 'Steel', 'Cement', 'Sand', 'Others'],
                  materialName: material,
                  onChanged: (val) {
                    setState(() {
                      material = val;
                      materialName = val;
                    });
                  }),
              material == 'Others'
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: TextFormField(
                        controller: materialNameController,
                        decoration: InputDecoration(
                          hintText: 'Material Name',
                          hintStyle: GoogleFonts.montserrat(
                            color: kPrimaryDarkColor,
                            letterSpacing: 1.2,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: kPrimaryDarkColor,
                            ),
                          ),
                        ),
                        onChanged: (String value) {
                          materialName = value;
                        },
                      ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: ()=>{
                        quantityController.clear()
                      },
                    ),
                    hintText: 'Quantity',
                    hintStyle: GoogleFonts.montserrat(
                      color: kPrimaryDarkColor,
                      letterSpacing: 1.2,
                    ),
                    fillColor: Colors.redAccent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: kPrimaryDarkColor,
                      ),
                    ),
                  ),
                  onChanged: (String value) {
                    quantity = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextFormField(
                  maxLines: 7,
                  controller: descController,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: ()=>{
                        descController.clear()
                      },
                    ),
                    hintText: 'Weight and Description of Material',
                    hintStyle: GoogleFonts.montserrat(
                      color: kPrimaryDarkColor,
                      letterSpacing: 1.2,
                    ),
                    fillColor: Colors.redAccent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: kPrimaryDarkColor,
                      ),
                    ),
                  ),
                  onChanged: (String value) {
                    materialDesc = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              FeatherIcons.calendar,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              startDate == "Start Date"
                                  ? startDate
                                  : DateFormat.yMEd().format(DateTime.parse(selectedDate.toIso8601String())),
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, color: Color(0xff13182A), fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 3,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Center(
                child: SliderButton(
                  height: 55,
                  buttonSize: 50,
                  vibrationFlag: true,
                  alignLabel: Alignment.center,
                  shimmer: true,
                  dismissible: false,
                  action: getBasicDetails,
                  label: Text(
                    'Slide to add Job',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: kPrimaryDarkColor),
                    textAlign: TextAlign.center,
                  ),
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green,
                  ),
                  backgroundColor: Colors.green[500].withOpacity(0.2),
                  boxShadow: BoxShadow(
                    color: Colors.green[500].withOpacity(0.4),
                    blurRadius: 4,
                  ),
                  baseColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //get time difference
  int get time => setDate.millisecondsSinceEpoch - tz.TZDateTime.now(tz.local).millisecondsSinceEpoch;
}
