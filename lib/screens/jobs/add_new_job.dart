import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/widgettree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:slider_button/slider_button.dart';
import 'package:uuid/uuid.dart';


final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference newMaterialRef = FirebaseFirestore.instance.collection('material');
CollectionReference jobRef = FirebaseFirestore.instance.collection('jobs');

class AddNewJob extends StatefulWidget {
  Map<String, String> jobData;

  AddNewJob({this.jobData});

  @override
  _AddNewJobState createState() => _AddNewJobState();
}

class _AddNewJobState extends State<AddNewJob> {
  Uuid _uuid = Uuid();

  String jobTitle = "", jobDesc = "", startDate = "Start Date", endDate = "End Date";

  TextEditingController clearJobDesc = TextEditingController();
  TextEditingController clearJobName = TextEditingController();

  updateJobName() async {
    var materialListData = await newMaterialRef.doc(firebaseAuth.currentUser.uid).collection("ongoing").get();
    var materialListNode = newMaterialRef.doc(firebaseAuth.currentUser.uid).collection("ongoing");

    materialListData.docs.forEach((element) async {
      if (element.data()["jobId"].toString().compareTo(widget.jobData["jobId"]) == 0)
        await materialListNode.doc(element.data()["materialId"]).update({"jobName": jobTitle});
    });
  }

  void getBasicDetails() async {
    animatedLoader.showDialog(AnimatedLoader.basketBall);
    if (jobTitle.isEmpty || jobDesc.isEmpty || startDate.isEmpty || endDate.isEmpty) {
      final snackBar = SnackBar(content: Text('Enter all the Details Correctly!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      animatedLoader.removeDialog();
    } else {
      if (start.isBefore(end)) {
        final String jobId = _uuid.v4();

        var userSiteAddress = {
          'jobId': jobId,
          'jobTitle': jobTitle,
          'jobDesc': jobDesc,
          'startDate': startDate,
          'isDeleted':false,
          'endDate': endDate,
          'timeStamp': DateTime.now(),
        };

        if (widget.jobData != null) {
          userSiteAddress.update("jobId", (value) => widget.jobData["jobId"]);
          await updateJobName();
          await jobRef
              .doc(firebaseAuth.currentUser.uid)
              .collection("ongoing")
              .doc(widget.jobData["jobId"])
              .update(userSiteAddress)
              .whenComplete(() {
            final snackBar = SnackBar(content: Text('Successfully Updated a Job'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pop(context);
            animatedLoader.removeDialog();
          });
        } else {
          await jobRef
              .doc(firebaseAuth.currentUser.uid)
              .collection("ongoing")
              .doc(jobId)
              .set(userSiteAddress)
              .whenComplete(() {
            final snackBar = SnackBar(content: Text('Successfully Added a Job'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pop(context);
            animatedLoader.removeDialog();
          });
        }
      } else {
        final snackBar = SnackBar(content: Text('Select valid Dates'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        animatedLoader.removeDialog();
      }
    }
  }

  getJobData() {
    if (widget.jobData.length != 0) {
      setState(() {
        clearJobDesc.text = widget.jobData["jobDesc"];
        clearJobName.text = widget.jobData["jobName"];
        jobTitle = widget.jobData["jobName"];
        jobDesc = widget.jobData["jobDesc"];
        startDate = widget.jobData["startDate"];
        endDate = widget.jobData["endDate"];
      });
    }
  }

  DateTime selectedDate = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked =
        await showDatePicker(context: context, initialDate: end, firstDate: DateTime.now(), lastDate: DateTime(2101));
    if (picked != null && picked != start)
      setState(() {
        start = picked;
        startDate = DateFormat.yMEd().format(start);
        FocusScope.of(context).unfocus();
      });
  }

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime picked =
        await showDatePicker(context: context, initialDate: start, firstDate: start, lastDate: DateTime(2101));
    if (picked != null && picked != end)
      setState(() {
        end = picked;
        endDate = DateFormat.yMEd().format(end);
        FocusScope.of(context).unfocus();
      });
  }

  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) getJobData();
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
            'New Job',
            style: GoogleFonts.montserrat(
              color: kPrimaryDarkColor,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          leading: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                CupertinoIcons.chevron_back,
                color: kPrimaryDarkColor,
                size: 22,
              )),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextFormField(
                  controller: clearJobName,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => {clearJobName.clear()},
                    ),
                    hintText: 'Job Title',
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
                    jobTitle = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextFormField(
                  controller: clearJobDesc,
                  maxLines: 7,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => {clearJobDesc.clear()},
                    ),
                    hintText: 'Job Description',
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
                    jobDesc = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Color(0xffF5F5F6), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              FeatherIcons.calendar,
                              color:  Colors.grey,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              startDate,
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
                    InkWell(
                      onTap: () {
                        if (startDate != "Start Date") _selectDate1(context);
                        if (startDate == "Start Date") {
                          final snackBar = SnackBar(content: Text('Select Start Date First!'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Color(0xffF5F5F6), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              FeatherIcons.calendar,
                              color:  Colors.grey,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              endDate,
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
}
