import 'package:acesteels/constants/constants.dart';
import 'package:acesteels/screens/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }


  Widget _buildImage(String assetName, [double width = 250]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('flutter.png', 100),
          ),
        ),
      ),
      pages: [
        PageViewModel(
          titleWidget: Text(" "),
          bodyWidget: ViewPageElement(imageName: 'img1.jpg',title: "Live your life smarter\nwith us!",description: "Manage all your site work at your finger tips.",imageNegativeMargin: -50,index: 0,),
        ),
        PageViewModel(
          title: " ",
          bodyWidget: ViewPageElement(imageName: 'img2.jpg',title: "Live your life smarter\nwith us!",description: "Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.",imageNegativeMargin: -30,index: 1,),
        ),
        PageViewModel(
          title: " ",
          bodyWidget: ViewPageElement(imageName: 'img3.jpg',title: "Live your life smarter\nwith us!",description: "Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.",imageNegativeMargin: -30,index: 2,),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip',textAlign: TextAlign.start,style: TextStyle(color: Color(0xff3D3270)),),
      next: const Icon(Icons.arrow_forward,color:Color(0xff3D3270) ,),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3D3270),)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeColor: Color(0xff3D3270),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

class ViewPageElement extends StatefulWidget {
  final String imageName;
  final String title;
  final String description;
  final double imageNegativeMargin;
  final int index;

  const ViewPageElement({@required this.imageName, @required this.title, @required this.description,@required this.imageNegativeMargin, this.index});

  @override
  _ViewPageElementState createState() => _ViewPageElementState();
}

class _ViewPageElementState extends State<ViewPageElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(10.0,30.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            transform: Matrix4.translationValues(widget.imageNegativeMargin, 0.0, 0.0),
            child: Image(
              image: AssetImage(
                'assets/${widget.imageName}',
              ),
              height: 300.0,
              width: 300.0,
              alignment: Alignment.centerLeft,
            ),
          ),
          SizedBox(height: 30.0),
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'CM Sans Serif',
              fontSize: 26.0,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15.0),
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: Text(
              widget.description,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}