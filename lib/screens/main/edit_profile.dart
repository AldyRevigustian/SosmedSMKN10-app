import 'dart:developer';
import 'dart:io';

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
  TextEditingController nameController = TextEditingController();

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
        loading = false;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
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

  void updateProfile() async {
    ApiResponse response =
        await updateUser(nameController.text, getStringImage(_imageFile));
    setState(() {
      loading = false;
    });
    if (response.error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.data}')));
      Navigator.pop(context);
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            "Profile",
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
        ),
        centerTitle: true,
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
      ),
      body: Center(
        child: loading
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
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   height: 30,
                        // ),
                        // Text(
                        //   "REGISTER",
                        //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        // ),
                        // SizedBox(
                        //   height: height / 10,
                        // ),
                        // CircleAvatar(
                        //   radius: 80,
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
                        Center(
                          child: CircleAvatar(
                            radius: 80,
                            child: Stack(
                              children: [
                                ClipOval(
                                  child: _imageFile != null
                                      ? Image.file(
                                          _imageFile,
                                          fit: BoxFit.cover,
                                          width: 200,
                                          height: 200,
                                        )
                                      : CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          width: 200,
                                          height: 200,
                                          imageUrl: baseURLMobile + user.image,
                                          placeholder: (context, url) => Center(
                                            child: Image.asset(
                                                'assets/images/user0.png'),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      getImage();
                                      // Navigator.pop(context);
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
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height / 10,
                        ),
                        TextFormField(
                          validator: (value) {
                            bool basic =
                                UValidator.validateThis(username: value);
                            if (value.isEmpty || !basic || value == user.name) {
                              //allow upper and lower case alphabets and space
                              return "Enter Correct Username";
                            } else {
                              return null;
                            }
                          },
                          controller: nameController,
                          decoration: InputDecoration(
                            label: Text("Enter new username"),
                            hintText: user.name,
                            hintStyle:
                                TextStyle(color: Colors.black.withOpacity(0.5)),
                            prefixIcon: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.alternate_email)),
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
                                  loading = !loading;
                                });
                                updateProfile();
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
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
                                    'Edit',
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
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
