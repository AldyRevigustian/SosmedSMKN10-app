import 'package:flutter/material.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/screens/loading.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
