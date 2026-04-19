import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  //Dùng CupertinoPageRoute để có thể kéo giao diện trên cả Android và IOS
  static Future<T?> pushCupertino<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      CupertinoPageRoute(builder: (_) => page),
    );
  }
}
