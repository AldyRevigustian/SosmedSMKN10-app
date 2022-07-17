import 'package:flutter/material.dart';
import 'package:instagram_redesign_ui/const.dart';
import 'package:instagram_redesign_ui/loading.dart';
import 'package:instagram_redesign_ui/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMKN 10 Social Media',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: CustColors.primaryWhite,
        fontFamily: 'Proxima',
      ),
      home: Loading(),
    );
  }
}
