import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/main/home_screen.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/navbar.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:image_picker/image_picker.dart';
import 'package:username_validator/username_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FocusNode node = new FocusNode();

  bool _isObscure = true;
  bool isDoubleTap = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController(),
      fullnameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController();

  // passwordConfirmController = TextEditingController();

  File _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      // setState(() {
      //   _imageFile = File(pickedFile.path);
      // });
      File croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          maxHeight: 300,
          maxWidth: 300,
          // compressQuality: 80,
          // compressQuality: 80,
          // aspectRatioPresets: [
          //   CropAspectRatioPreset.square,
          // ],
          // cropStyle: CropStyle.rectangle,
          androidUiSettings: AndroidUiSettings(
            // hideBottomControls: true,
            // lockAspectRatio: false,
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            backgroundColor: CustColors.primaryWhite,
            activeControlsWidgetColor: CustColors.primaryBlue,
          ),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      if (croppedFile != null) {
        setState(() {
          _imageFile = croppedFile;
        });
      }
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
      kErrorSnackbar(context, '${response.error}');
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
                  // CircleAvatar(
                  //   radius: 110,
                  //   backgroundImage: _imageFile == null
                  //       ? AssetImage("assets/images/user0.png")
                  //       : FileImage(_imageFile ?? File('')),
                  //   child: Stack(children: [
                  //     Align(
                  //       alignment: Alignment.bottomRight,
                  //       child: GestureDetector(
                  //         onTap: () {
                  //           getImage();
                  //         },
                  //         child: CircleAvatar(
                  //           radius: 18,
                  //           backgroundColor:
                  //               CustColors.primaryBlue.withOpacity(1),
                  //           child: Icon(
                  //             Icons.camera,
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ]),
                  // ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDoubleTap = !isDoubleTap;
                      });
                    },
                    // onTap: () {
                    //   getImage();
                    // },
                    child: CircleAvatar(
                      radius: 100,
                      child: isDoubleTap
                          ? ClipOval(
                              child: _imageFile == null
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isDoubleTap = !isDoubleTap;
                                        });
                                        getImage();
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/user0.png',
                                            fit: BoxFit.cover,
                                            width: 250,
                                            height: 250,
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            colorBlendMode: BlendMode.darken,
                                          ),
                                          Icon(
                                            Icons.add_photo_alternate,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            size: 60,
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        getImage();
                                        setState(() {
                                          isDoubleTap = !isDoubleTap;
                                        });
                                      },
                                      // _imageFile ?? File('')
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.file(
                                            _imageFile ?? File(''),
                                            fit: BoxFit.cover,
                                            width: 250,
                                            height: 250,
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            colorBlendMode: BlendMode.darken,
                                          ),
                                          Icon(
                                            Icons.add_photo_alternate,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            size: 60,
                                          ),
                                        ],
                                      ),
                                    ),
                            )
                          : ClipOval(
                              child: _imageFile == null
                                  ? Image.asset(
                                      'assets/images/user0.png',
                                      fit: BoxFit.cover,
                                      width: 250,
                                      height: 250,
                                    )
                                  : Image.file(
                                      _imageFile ?? File(''),
                                      fit: BoxFit.cover,
                                      width: 250,
                                      height: 250,
                                    ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  // TextFormField(
                  // validator: (value) {
                  //   if (value.isEmpty ||
                  //       !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                  //     //allow upper and lower case alphabets and space
                  //     return "Enter Correct Full Name";
                  //   } else {
                  //     return null;
                  //   }
                  // },
                  //   controller: fullnameController,
                  //   decoration: InputDecoration(
                  //     hintText: "Full Name",
                  //     prefixIcon: Padding(
                  //         padding: EdgeInsets.only(right: 10),
                  //         child: Icon(Icons.person)),
                  //   ),
                  // ),
                  TextFormField(
                    controller: fullnameController,
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                        //allow upper and lower case alphabets and space
                        return "Enter Correct Full Name";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.person),
                      ),
                      fillColor: CustColors.primaryWhite,
                      hintText: "Full Name",
                      // hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // TextFormField(
                  // validator: (value) {
                  //   bool basic = UValidator.validateThis(username: value);
                  //   if (value.isEmpty || !basic) {
                  //     //allow upper and lower case alphabets and space
                  //     return "Enter Correct Username";
                  //   } else {
                  //     return null;
                  //   }
                  // },
                  //   controller: nameController,
                  //   decoration: InputDecoration(
                  //     hintText: "Username",
                  //     prefixIcon: Padding(
                  //         padding: EdgeInsets.only(right: 10),
                  //         child: Icon(Icons.alternate_email)),
                  //   ),
                  // ),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      bool basic = UValidator.validateThis(username: value);
                      if (value.isEmpty || !basic) {
                        //allow upper and lower case alphabets and space
                        return "Enter Correct Username";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.alternate_email),
                      ),
                      fillColor: CustColors.primaryWhite,
                      hintText: "Username",
                      // hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                        //allow upper and lower case alphabets and space
                        return "Enter Correct Email";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.email),
                      ),
                      fillColor: CustColors.primaryWhite,
                      hintText: "Email",
                      // hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    obscureText: _isObscure,
                    controller: passwordController,
                    validator: (val) =>
                        val.length < 6 ? 'Required at least 6 chars' : null,
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: IconButton(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: _isObscure
                              ? Icon(
                                  Icons.visibility,
                                  color: Colors.black54,
                                )
                              : Icon(
                                  Icons.visibility_off,
                                  color: Colors.black54,
                                ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.lock),
                      ),
                      fillColor: CustColors.primaryWhite,
                      hintText: "Password",
                      // hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: CustColors.primaryWhite)),
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                    ),
                    keyboardType: TextInputType.name,
                  ),

                  // SizedBox(
                  //   height: 20,
                  // ),
                  const SizedBox(
                    height: 50,
                  ),
                  MaterialButton(
                    onPressed: () {
                      log("Oke");
                      if (formKey.currentState.validate()) {
                        if (_imageFile != null) {
                          setState(() {
                            loading = false;
                          });
                          _registerUser();
                        } else {
                          kErrorSnackbar(context, "Please add profile picture");
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
