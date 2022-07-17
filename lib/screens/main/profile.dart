import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_redesign_ui/const.dart';
import 'package:instagram_redesign_ui/loading.dart';
import 'package:instagram_redesign_ui/models/api_response.dart';
import 'package:instagram_redesign_ui/models/post.dart';
import 'package:instagram_redesign_ui/models/post_single.dart';
import 'package:instagram_redesign_ui/models/user.dart';
import 'package:instagram_redesign_ui/screens/login_screen.dart';
import 'package:instagram_redesign_ui/screens/main/view_post_screen.dart';
import 'package:instagram_redesign_ui/services/post_service.dart';
import 'package:instagram_redesign_ui/services/user_service.dart';

import '../../constant.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User user;
  bool loading = true;
  List<dynamic> _postList = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtNameController = TextEditingController();

  Future<void> retrievePostsPerId() async {
    int userId = await getUserId();
    ApiResponse response = await getPostsPeruserId(userId);

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        // _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    }
  }

  // get user detail
  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
        txtNameController.text = user.name ?? '';
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

  void refresh() {
    getUser();
    retrievePostsPerId();
    setState(() {});
  }

  @override
  void initState() {
    getUser();
    retrievePostsPerId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Post post = _postList[0];
    // log(post.user.id.toString());
    // log(_postList[1].toString());
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      child: Scaffold(
        // backgroundColor: Colors.white,
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
          actions: [
            GestureDetector(
              onTap: () {
                logout().then((value) => {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (route) => false)
                    });
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.logout,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            )
          ],
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
            : Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Container(
                    height: height / 3,
                    // color: Colors.red,
                    child: Stack(
                      children: [
                        ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: Image.network(
                              baseURLMobile + user.image,
                              fit: BoxFit.cover,
                            )),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: new ClipRect(
                              child: new BackdropFilter(
                                filter: new ImageFilter.blur(
                                    sigmaX: 10.0, sigmaY: 10.0),
                                child: new Container(
                                  // width: 200.0,
                                  // height: 200.0,
                                  decoration: new BoxDecoration(
                                      color: Colors.grey.shade200
                                          .withOpacity(0.3)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 80,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 160,
                                    height: 160,
                                    imageUrl: baseURLMobile + user.image,
                                    placeholder: (context, url) => Center(
                                      child: Image.asset(
                                          'assets/images/user0.png'),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: 100, minHeight: 30),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100)),

                                  // width: width / 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      user.name,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black.withOpacity(0.7)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                        color: CustColors.primaryWhite,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, -2),
                              blurRadius: 2)
                        ]),
                    child: _postList.length == 0
                        ? Center(
                            child: Text(
                              "No post",
                              style: TextStyle(color: Colors.black45),
                            ),
                          )
                        : GridView.builder(
                            itemCount: _postList.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (BuildContext context, int index) {
                              PostSingle post = _postList[index];
                              // log("Masul");
                              return GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => ViewPostScreen(
                                  //       id: post.id,
                                  //     ),
                                  //   ),
                                  // );

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewPostScreen(
                                                func: refresh,
                                                id: post.id,
                                              ))).then((value) {
                                    setState(() {
                                      refresh();
                                    });
                                  });

                                  log(post.id.toString());
                                },
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: baseURLMobile + post.image,
                                  placeholder: (context, url) =>
                                      SpinKitFadingCube(
                                    size: 30,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              );
                            }),
                  )),
                ],
              ),
      ),
    );
  }
}
