import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/flutter_loading/show_custom_loader.dart';
import 'package:acesteels/screens/bottom_nav_pages/homepage.dart';
import 'package:acesteels/screens/bottom_nav_pages/jobpage.dart';
import 'package:acesteels/screens/bottom_nav_pages/orderpage.dart';
import 'package:acesteels/screens/bottom_nav_pages/quotes.dart';
import 'package:acesteels/screens/profilesetup/ProfileAboutSetup.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import '../widgettree.dart';
import 'bottom_nav_pages/profilepage.dart';
import 'login.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference adminTokenRef = FirebaseFirestore.instance.collection('admin').doc("users").collection("data");
CollectionReference quoteRef =
    FirebaseFirestore.instance.collection('material').doc(mAuth.currentUser.uid).collection("ongoing");
int quoteCount;
List<String> adminTokenIdList = [];
String currentUserId = "";
String hasCompleted = "false", hasAccepted = "false";

class HomeWithBN extends StatefulWidget {
  @override
  _HomeWithBNState createState() => _HomeWithBNState();
}

class _HomeWithBNState extends State<HomeWithBN> with WidgetsBindingObserver{


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      users.doc(firebaseAuth.currentUser.uid).get().then((doc) {
        if (!doc.exists){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ProfileAboutSetup(),
            ),
          );
        }else{
          getAdminTokens();
          getNUmberOfQuotes();
          getBadgeDetails();
          setState(() {});
        }

      });

    }

  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getBadgeDetails();
    }
  }


  getNUmberOfQuotes() async {
    quoteCount = 0;
    var user = await users.doc(firebaseAuth.currentUser.uid).get();
    setState(() {
      hasCompleted = user.data()["hasCompleted"];
      hasAccepted = user.data()["hasAccepted"];
    });

    final snapShot = await quoteRef.get();
    if(snapShot.docs.isNotEmpty){
      await quoteRef.snapshots().forEach((e) {
        quoteCount = 0;
        e.docs.forEach((element) {
          if (element.data()["status"].toString().compareTo("Quoted") == 0) {
            quoteCount += 1;
          }
        });
      });

    }

  }

  getBadgeDetails() async {
    var user = await users.doc(firebaseAuth.currentUser.uid).get();
    setState(() {
      hasCompleted = user.data()["hasCompleted"];
      hasAccepted = user.data()["hasAccepted"];
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void getAdminTokens() async {
    await adminTokenRef.snapshots().forEach((element) {
      element.docs.forEach((e) {
        adminTokenIdList.add(e.data()["tokenId"]);
      });
    });
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    JobPage(),
    QuotesPage(),
    OrderPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    getBadgeDetails();
    animatedLoader = new AnimatedLoader(
      context: context,
      height: 100.0,
      width: 100.0,
      isDismissable: false,
    );
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: GNav(
                  iconSize: 24,
                  activeColor: kPrimaryColor,
                  color: kPrimaryDarkColor,
                  gap: 0,
                  curve: Curves.easeInExpo,
                  padding: EdgeInsets.only(left: 15, right: 0, top: 10, bottom: 10),
                  duration: Duration(milliseconds: 200),
                  tabs: [
                    GButton(
                      icon: LineIcons.home,
                    ),
                    GButton(
                      icon: FeatherIcons.barChart2,
                    ),
                    GButton(
                      icon: LineIcons.handHoldingUsDollar,
                      leading: hasAccepted.compareTo("true") == 0 ? Badge(
                        badgeColor: Colors.red.shade400,
                        elevation: 0,
                        position: BadgePosition.topEnd(top: -12, end: -12),
                        badgeContent: Text(
                          '',
                          style: TextStyle(color: Colors.red.shade900,),
                        ),
                        child: Icon(
                          LineIcons.handHoldingUsDollar,
                        ),
                      ) : null,
                    ),
                    GButton(
                      icon: LineIcons.shoppingBag,
                      leading: hasCompleted.compareTo("true") == 0  ? Badge(
                        badgeColor: Colors.red.shade400,
                        elevation: 0,
                        position: BadgePosition.topEnd(top: -12, end: -12),
                        badgeContent: Text(
                          '',
                          style: TextStyle(color: Colors.red.shade900,),
                        ),
                        child: Icon(
                          LineIcons.shoppingBag,
                        ),
                      ) : null,
                    ),
                    GButton(
                      icon: LineIcons.user,
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;


                    });
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
