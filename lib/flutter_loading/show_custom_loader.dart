import 'package:acesteels/flutter_loading/set_custom_loader.dart';
import 'package:flutter/cupertino.dart';

import 'custom_loader_widget.dart';


class AnimatedLoader{

  final BuildContext context;
  final height;
  final width;
  bool isDismissable = true;
  bool isPoped = false;


  static final String basketBall = 'assets/basket_ball.json';

  AnimatedLoader({this.isDismissable,this.context,this.height,this.width});

  void showDialog(String assets){
    SetCustomLoader customDialog = new SetCustomLoader(
        context: context,
        customAlertDialog: CustomLoaderWidget(
          assets:assets,
          height: height,
          width: width,
          onTap: isDismissable == null || isDismissable ? (){isPoped = true;Navigator.of(context).pop();}:(){},
        )
    );
    customDialog.setDialog();
  }

  void removeDialog(){

    if(isPoped){
    }else{
      Navigator.of(context).pop();
    }

  }
}