import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smkn10sosmed/const.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/main/home_screen.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/navbar.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FocusNode node = new FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController(),
      fullnameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController();

  File _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _registerUser() async {
    ApiResponse response = await register(
        nameController.text,
        fullnameController.text,
        emailController.text,
        passwordController.text,
        getStringImage(_imageFile));
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = !loading;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // Save and redirect to home
  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Navbar()), (route) => false);
  }

  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    node.addListener(() {
      if (!node.hasFocus) {
        formatNickname();
      }
    });
    super.initState();
  }

  String dropdownValue;

  void formatNickname() {
    nameController.text = nameController.text.replaceAll(" ", "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   height: 30,
                  // ),
                  // Text(
                  //   "REGISTER",
                  //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  // ),
                  SizedBox(
                    height: 30,
                  ),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _imageFile == null
                        ? AssetImage("assets/images/user0.png")
                        : FileImage(_imageFile ?? File('')),
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                CustColors.primaryBlue.withOpacity(1),
                            child: Icon(
                              Icons.camera,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                        //allow upper and lower case alphabets and space
                        return "Enter Correct Full Name";
                      } else {
                        return null;
                      }
                    },
                    controller: fullnameController,
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.person)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r'^[A-Za-z][A-Za-z0-9_]{7,29}$')
                              .hasMatch(value)) {
                        //allow upper and lower case alphabets and space
                        return "Enter Correct Username";
                      } else {
                        return null;
                      }
                    },
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Username",
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.alternate_email)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                        //allow upper and lower case alphabets and space
                        return "Enter Correct Full Name";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.email)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    validator: (val) =>
                        val.length < 6 ? 'Required at least 6 chars' : null,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.vpn_key_sharp)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passwordConfirmController,
                    obscureText: true,
                    validator: (val) => val != passwordController.text
                        ? 'Confirm password does not match'
                        : null,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.vpn_key_sharp)),
                    ),
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  const SizedBox(
                    height: 50,
                  ),
                  MaterialButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        if (_imageFile != null) {
                          setState(() {
                            loading = false;
                          });
                          _registerUser();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Please add profile picture"),
                          ));
                        }
                      }
                    },
                    minWidth: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: loading
                          ? SpinKitFadingCube(
                              size: 17,
                              color: Colors.white.withOpacity(0.5),
                            )
                          : Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Lato",
                              ),
                            ),
                    ),
                    color: CustColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text(
                          'Already have an account?',
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        ),
                        child: Container(
                          child: const Text(
                            ' Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
