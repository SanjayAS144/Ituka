import 'package:flutter/material.dart';

import 'custom_loader_widget.dart';

class SetCustomLoader {

  final CustomLoaderWidget customAlertDialog;
  final BuildContext context;

  SetCustomLoader({this.context, this.customAlertDialog,});

  Future<void> setDialog() {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return customAlertDialog;
        });
  }

}