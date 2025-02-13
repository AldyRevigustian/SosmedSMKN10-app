import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/main/navbar.dart';
import 'package:smkn10sosmed/screens/register_screen.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import 'package:smkn10sosmed/widget/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
      kErrorSnackbar(context, '${response.error}');
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Navbar()), (route) => false);
  }

  showLoadingProgress(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => Center(
                // Aligns the container to center
                child: Container(
              // A simplified version of dialog.
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              width: 100.0,
              height: 100.0,
              child: SpinKitFadingCube(
                size: 30,
                color: Colors.black.withOpacity(0.2),
              ),
            )));
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      // backgroundColor: CustColors.primaryBlue,
      // resizeToAvoidBottomInset: false,
      body: Form(
        key: formkey,
        child: Stack(
          children: [
            ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: height / 2, minWidth: width),
              child: Image.asset(
                'assets/images/kelas.jpg',
                fit: BoxFit.cover,
              ),
              // child: Container(
              //   color: CustColors.primaryBlue,
              // ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: new ClipRect(
                  child: new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: new Container(
                      // width: 180.0,
                      // height: 200.0,
                      decoration: new BoxDecoration(
                          color: Colors.grey.shade200.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: height / 2,
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 35, horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/smk10logorapi.png',
                          width: 120,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "SMKN 10 JAKARTA",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontFamily: "default",
                              fontWeight: FontWeight.w800),
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Text(
                          "Social Media",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: "default",
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  // flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 25, left: 25, right: 25),
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification:
                            (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowGlow();
                          return;
                        },
                        child: SingleChildScrollView(
                          // physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: height / 20,
                              ),
                              TextFieldInput(
                                textEditingController: txtEmail,
                                hintText: 'Email',
                                textInputType: TextInputType.emailAddress,
                                validator: (val) => val.isEmpty
                                    ? 'Invalid email address'
                                    : null,
                                // textEditingController: _emailController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // TextFieldInput(,
                              TextFormField(
                                controller: txtPassword,
                                validator: (val) => val.length < 6
                                    ? 'Required at least 6 chars'
                                    : null,
                                decoration: InputDecoration(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: IconButton(
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      icon: _isObscure
                                          ? Icon(
                                              Icons.visibility,
                                              color: Colors.grey[600],
                                            )
                                          : Icon(
                                              Icons.visibility_off,
                                              color: Colors.grey[600],
                                            ),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      },
                                    ),
                                  ),
                                  fillColor: CustColors.primaryWhite,
                                  // fillColor: Colors.grey.shade200,
                                  hintText: "Password",
                                  // hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: CustColors.primaryWhite)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: CustColors.primaryWhite)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: CustColors.primaryWhite)),
                                  filled: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 8, 8, 8),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                obscureText: _isObscure,
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              MaterialButton(
                                // height: 50,
                                onPressed: () {
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) => Navbar(),
                                  //   ),
                                  // );
                                  if (formkey.currentState.validate()) {
                                    setState(() {
                                      loading = true;
                                      showLoadingProgress(context);
                                      _loginUser();
                                    });
                                  }
                                },
                                minWidth: width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Lato",
                                    ),
                                  ),
                                ),
                                color: CustColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: const Text(
                                      "Don't have an acount?",
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RegisterScreen(),
                                      ),
                                    ),
                                    child: Container(
                                      child: const Text(
                                        ' Register',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   height: 50,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
