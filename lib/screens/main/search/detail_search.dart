import 'dart:collection';
import 'dart:developer';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smkn10sosmed/models/search.dart';
import 'package:smkn10sosmed/screens/loading.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/post.dart';
import 'package:smkn10sosmed/models/post_single.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/profile/edit_profile.dart';
import 'package:smkn10sosmed/screens/main/profile/view_post_screen.dart';
import 'package:smkn10sosmed/screens/main/search/view_search_post.dart';
import 'package:smkn10sosmed/services/post_service.dart';
import 'package:smkn10sosmed/services/user_service.dart';

import '../../../widget/constant.dart';

class DetailSearch extends StatefulWidget {
  final int id;

  const DetailSearch({Key key, this.id}) : super(key: key);
  @override
  State<DetailSearch> createState() => _DetailSearchState();
}

class _DetailSearchState extends State<DetailSearch> {
  List<dynamic> user;
  bool loading = true;
  List<dynamic> _postList = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtNameController = TextEditingController();

  Future<void> retrievePostsPerId() async {
    int userId = widget.id;
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
      kErrorSnackbar(context, '${response.error}');
    }
  }

  // get user detail
  void getUserPerId() async {
    int userId = widget.id;
    ApiResponse response = await getUserDetailId(userId);
    if (response.error == null) {
      setState(() {
        user = response.data as List<dynamic>;
        loading = false;
        // txtNameController.text = user.name ?? '';
      });
      // log(user.toString());
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

  void refresh() {
    getUserPerId();
    retrievePostsPerId();
    setState(() {});
  }

  @override
  void initState() {
    getUserPerId();
    retrievePostsPerId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      child: Scaffold(
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
            )),
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
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 160,
                      height: 160,
                      imageUrl: baseURLMobile + user[0].image,
                      placeholder: (context, url) => Center(
                        child: Image.asset('assets/images/user0.png'),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
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
                        height: height / 2.5,
                        // color: Colors.red,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 80,
                                child: Stack(
                                  children: [
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: 200,
                                        height: 200,
                                        imageUrl: baseURLMobile + user[0].image,
                                        placeholder: (context, url) => Center(
                                          child: Image.asset(
                                              'assets/images/user0.png'),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: 190,
                                    // minHeight: 20,
                                    maxWidth: 300),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100)),

                                  // width: width / 1,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 10, 30, 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          user[0].fullname,
                                          // "koaskdosakdoas okasodksaod okoaskdoaskd kasodkasodk",
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  Colors.black.withOpacity(1)),
                                        ),
                                        Text(
                                          "@" + user[0].name,
                                          // "koaskdosakdoas okasodksaod okoaskdoaskd kasodkasodk",
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black
                                                  .withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   height: 5,
                      // ),
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
                                  offset: Offset(0, -3),
                                  blurRadius: 2)
                            ]),
                        child: _postList.length == 0
                            ? Center(
                                child: Text(
                                  "No post",
                                  style: TextStyle(color: Colors.black45),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(13, 13, 13, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                  child: NotificationListener<
                                      OverscrollIndicatorNotification>(
                                    onNotification:
                                        (OverscrollIndicatorNotification
                                            overscroll) {
                                      overscroll.disallowGlow();
                                      return;
                                    },
                                    child: GridView.builder(
                                        itemCount: _postList.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                mainAxisSpacing: 5,
                                                crossAxisSpacing: 5,
                                                crossAxisCount: 3),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          PostSingle post = _postList[index];
                                          // log("Masul");
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewSearchPost(
                                                            func: refresh,
                                                            id: post.id,
                                                          ))).then((value) {
                                                setState(() {
                                                  refresh();
                                                });
                                              });
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl:
                                                    baseURLMobile + post.image,
                                                placeholder: (context, url) =>
                                                    SpinKitFadingCube(
                                                  size: 30,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                      )),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
