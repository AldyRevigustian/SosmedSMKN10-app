import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
import 'package:smkn10sosmed/widget/textfield.dart';
import 'package:username_validator/username_validator.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  User user;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = true;
  TextEditingController usernameController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();

  File _imageFile;
  final _picker = ImagePicker();

  // Future getImage() async {
  //   final pickedFile = await _picker.getImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = loading = loading ? !loading : loading;
        if (!loading) {
          fullnameController.text = user.fullname;
          usernameController.text = user.name;
        } else {
          fullnameController.text = " ";
          usernameController.text = " ";
        }
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
    } else {
      kErrorSnackbar(context, '${response.error}');
    }
  }

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

  updateProfile() async {
    ApiResponse response = await updateUser(usernameController.text,
        getStringImage(_imageFile), fullnameController.text);
    setState(() {
      loading = false;
    });
    if (response.error == null) {
      kSuccessSnackbar(context, '${response.data}');

      Navigator.pop(context);
      return true;
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
      return false;
    } else {
      kErrorSnackbar(context, '${response.error}');

      return false;
    }
  }
  // Save and redirect to home

  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    getUser();
    super.initState();
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          // borderRadius: BorderRadius.circular(100),
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        title: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            "Profile",
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCube(
                    size: 30,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Please wait ...",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.2), fontSize: 15),
                    ),
                  )
                ],
              ),
            )
          : Stack(
              children: [
                ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: height / 2, minWidth: width),
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        )
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: 160,
                          height: 160,
                          imageUrl: baseURLMobile + user.image,
                          placeholder: (context, url) => Center(
                            child: Image.asset('assets/images/user0.png'),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: new ClipRect(
                      child: new BackdropFilter(
                        filter:
                            new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                  children: [
                    Container(
                      height: height / 2.3,
                      // color: Colors.red,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(
                            //   height: 30,
                            // ),
                            GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: CircleAvatar(
                                radius: 110,
                                child: Stack(
                                  children: [
                                    ClipOval(
                                      child: _imageFile != null
                                          ? Image.file(
                                              _imageFile,
                                              fit: BoxFit.cover,
                                              width: 250,
                                              height: 250,
                                            )
                                          : CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              width: 250,
                                              height: 250,
                                              imageUrl:
                                                  baseURLMobile + user.image,
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: Image.asset(
                                                    'assets/images/user0.png'),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, -2),
                                blurRadius: 2)
                          ]),
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification:
                            (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowGlow();
                          return;
                        },
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Full name'),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty ||
                                          !RegExp(r'^[a-z A-Z]+$')
                                              .hasMatch(value)) {
                                        return "Enter Correct Full Name";
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: fullnameController,
                                    // initialValue: user.fullname,
                                    decoration: InputDecoration(
                                      hintText: user.fullname,
                                      hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5)),
                                      prefixIcon: Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Icon(Icons.person)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: CustColors.primaryWhite)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: CustColors.primaryWhite)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: CustColors.primaryWhite)),
                                      filled: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          20, 8, 8, 8),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Username'),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      bool basic = UValidator.validateThis(
                                          username: value);
                                      if (value.isEmpty ||
                                          !basic ||
                                          value == user.name) {
                                        //allow upper and lower case alphabets and space
                                        return "Enter Correct Username";
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                      // label: Text("Enter new username"),
                                      hintText: user.name,
                                      hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5)),
                                      prefixIcon: Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Icon(Icons.alternate_email)),

                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: CustColors.primaryWhite)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: CustColors.primaryWhite)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: CustColors.primaryWhite)),
                                      filled: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          20, 8, 8, 8),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      // showLoadingProgress(context);
                                      updateProfile();
                                    },
                                    minWidth: double.infinity,
                                    // height: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, bottom: 15),
                                      child: loading
                                          ? SpinKitFadingCube(
                                              size: 17,
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                            )
                                          : Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Lato",
                                              ),
                                            ),
                                    ),
                                    color: CustColors.primaryBlue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
    );
  }
}
