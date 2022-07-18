import 'dart:developer';
import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smkn10sosmed/const.dart';
import 'package:smkn10sosmed/constant.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/main/home_screen.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/navbar.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController();

  File _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
      body: SingleChildScrollView(
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
                  height: height / 10,
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
                  height: height / 5,
                ),
                TextFormField(
                  validator: (val) => val.isEmpty ? 'Invalid name' : null,
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Username",
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please add profile picture"),
                        ));
                      }
                    }
                  },
                  minWidth: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      'Update',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
