import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/screens/jobs/add_new_job.dart';
import 'package:acesteels/screens/jobs/jobdescpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference jobRef = FirebaseFirestore.instance.collection('jobs');


class JobPage extends StatefulWidget {
  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {

  final int countCard = 4;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
          body: Padding(
        padding:
            const EdgeInsets.only(top: 40.0, right: 20, left: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Works',style: headTextStyle(),),
                SizedBox(height: 20,),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: jobRef.doc(firebaseAuth.currentUser.uid).collection("ongoing").orderBy("timeStamp").snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                      if(!snapshot.hasData){
                        return SpinKitDoubleBounce(
                          color: Color(0xFFC850C0),
                          size: 100.0,
                        );
                      }
                      int count = 0;
                      int num = snapshot.data.size;

                      List<DocumentSnapshot> jobs = [];

                      snapshot.data.docs.map((e) {
                        if(e["isDeleted"] == false){
                          jobs.add(e);
                        }
                      }).toList();


                      return ListView.builder(
                        itemCount: jobs.length + 1,
                        itemBuilder: (context, pos) {
                          if(pos == jobs.length)
                            return AddNewJobCard();
                          return JobCard(
                            jobTitle: jobs[pos]["jobTitle"],
                            colorBg: cardColorsHome[
                            pos % cardColorsHome.length][1],
                            colorText: cardColorsHome[pos % cardColorsHome.length][0],
                            jobId: jobs[pos]["jobId"],
                            jobDesc: jobs[pos]["jobDesc"],
                            date: jobs[pos]["startDate"] + " - "+ jobs[pos]["endDate"],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      )),
    );
  }
}

class AddNewJobCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddNewJob()),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 10,top: 5,),
        child: DottedBorder(
          color: kPrimaryDarkColor,
          strokeWidth: 1,
          strokeCap: StrokeCap.round,
          dashPattern: [4, 8],
          borderType: BorderType.RRect,
          radius: Radius.circular(12),
          child: Container(
            height: 120,
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
                  'Add New Task',
                  style: subHeadTextStyle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({
    @required this.jobTitle,
    @required this.colorBg,
    @required this.colorText,
    @required this.jobId,
    @required this.jobDesc,
    @required this.date,
  });

  final String jobTitle;
  final String jobDesc;
  final String date;
  final String jobId;
  final Color colorBg;
  final Color colorText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder:(context)=>JobDescPage(jobId: jobId, colorBg: colorBg, colorText: colorText, jobTitle: jobTitle, jobDesc: jobDesc, jobDate: date)));
      },
      child: Padding(
        padding: const EdgeInsets.only(top:5.0,bottom: 7),
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 8, top: 25, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorBg,
            boxShadow: [
              BoxShadow(
                offset: const Offset(3.0, 3.0),
                color: Colors.grey.shade500.withOpacity(0.1),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
              BoxShadow(
                offset: const Offset(-3.0, -3.0),
                color: Colors.white.withOpacity(0.5),
                blurRadius: 6.0,
                spreadRadius: 3.0,
              ),
            ]
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: cardTitleTextStyle().copyWith(fontSize: 22,color: colorText,),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date,
                        style: cardSubHeadTextStyle().copyWith(
                          color: colorText.withOpacity(0.8),
                          fontSize: 14,
                        )),
                        SizedBox(
                          height: 2,
                        ),
                        Text(jobDesc,
                            style: cardSubHeadTextStyle().copyWith(
                              color: colorText.withOpacity(0.6),
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
              InkWell(
                onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNewJob(
                        jobData: {
                          "jobId": jobId,
                          "jobName": jobTitle,
                          "jobDesc": jobDesc,
                          "startDate": date.split(" - ")[0].toString(),
                          "endDate": date.split(" - ")[0].toString(),
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    CupertinoIcons.pen,
                    color: colorText,
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
