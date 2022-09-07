import 'dart:developer';
import 'dart:typed_data';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/navbar.dart';
import 'package:smkn10sosmed/services/post_service.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import 'package:photo_manager/photo_manager.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key key, this.image}) : super(key: key);

  final Uint8List image;

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  TextEditingController caption = new TextEditingController(); // th
  final _formKey = GlobalKey<FormState>();

  void _createPost() async {
    String image =
        widget.image == null ? null : getStringImageByte(widget.image);
    ApiResponse response = await createPost(caption.text, image);
    if (response.error == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Navbar()), (route) => false);
      // Navigator.of(context).pop();

    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
    } else {
      kErrorSnackbar(context, '${response.error}');

      // setState(() {
      //   _loading = !_loading;
      // });
    }
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
    super.initState();
  }

  String _value;
  String errorText;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: Offset(0, -2),
                  blurRadius: 2)
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: BottomAppBar(
              child: Container(
                // decoration: BoxDecoration(
                //   color: Colors.white,
                // ),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        minWidth: 40,
                        onPressed: () {
                          // setState(() {
                          //   curentScreen = HomeScreen();
                          //   curent = 0;
                          // });
                        },
                        // minWidth: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentIcons.home_20_filled,
                              size: 25,
                              color: Colors.grey,
                            ),
                            // Text(
                            //   "Home",
                            //   style: TextStyle(
                            //     fontSize: 10,
                            //     color: Colors.grey,
                            //   ),
                            // )
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: FlatButton(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // color: Color(0xFF23B66F),
                        color: CustColors.primaryBlue.withOpacity(0.9),
                        onPressed: () {},
                        child: Icon(
                          Icons.add_box_rounded,
                          size: 35.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    MaterialButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          setState(() {});
                        },
                        minWidth: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FluentIcons.person_20_filled,
                              color: Colors.grey,
                              size: 25,
                            ),
                            // Text(
                            //   "Profile",
                            //   style: TextStyle(
                            //     fontSize: 10,
                            //     color: Colors.grey,
                            //   ),
                            // )
                          ],
                        )),
                  ],
                ),
              ),
            )),
      ),
      // backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
        actions: [
          InkWell(
            // borderRadius: BorderRadius.circular(80),
            onTap: () async {
              if (caption.text != null) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => AddPost(image: picked),
                //   ),
                // );
                if (_formKey.currentState.validate()) {
                  showLoadingProgress(context);
                  _createPost();
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                FluentIcons.send_20_filled,
                color: caption.text != null
                    ? Colors.black.withOpacity(0.8)
                    : Colors.black.withOpacity(0.3),
                size: 20,
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            "Post",
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: CustColors.primaryWhite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SizedBox(
              //   height: 20,
              // ),
              Container(
                height: 10,
                color: CustColors.primaryWhite,
              ),
              Container(
                color: CustColors.primaryWhite,
                // color: Colors.black,
                height: height / 2.4,
                width: width,
                child: (widget.image != null)
                    ? Container(
                        child: Center(child: Image.memory(widget.image)),
                        height: height / 2,
                      )
                    : Container(
                        // child: Center(child: Image.memory(widget.image)),
                        height: height / 2,
                      ),
              ),
              Container(
                height: 10,
                color: CustColors.primaryWhite,
              ),
              // SizedBox(
              //   height: 20,
              // ),
              Expanded(
                child: Container(
                  width: width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, -3),
                            blurRadius: 2)
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: width / 1.15,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Caption",
                            style: TextStyle(
                                color: Colors.black.withOpacity(1),
                                fontSize: 18),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              // autofocus: true,
                              // minLines: 10,
                              maxLines: 20,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                              controller: caption,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black.withOpacity(0.8)),
                              decoration: InputDecoration(
                                fillColor: Colors.white.withOpacity(0.6),
                                filled: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 0, 20, 20),
                                hintText: "Write a caption ...",
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.3),
                                    fontSize: 15),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Expanded(child: C)
              // SizedBox(
              //   height: 40,
              // ),
              // MaterialButton(
              //   onPressed: () async {
              //     if (_formKey.currentState.validate()) {
              //       _createPost();
              //     }
              //   },
              //   minWidth: width / 1.15,
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 15, bottom: 15),
              //     child: Text(
              //       'Post',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontFamily: "Lato",
              //       ),
              //     ),
              //   ),
              //   color: CustColors.primaryBlue,
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20)),
              // ),
              // SizedBox(
              //   height: 30,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
