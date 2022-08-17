import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/helper/get_helper.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/post.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/comment.dart';
import 'package:smkn10sosmed/screens/main/profile.dart';
import 'package:smkn10sosmed/services/post_service.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import 'package:smkn10sosmed/widget/readmore.dart';
import 'package:like_button/like_button.dart';
import 'package:numeral/fun.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = ScrollController();
  User user;

  Future listPost;
  List<dynamic> items = [];
  bool hasMore = true;
  int userId = 0;
  int page = 1;
  bool isLoading = false;

  bool _loading = true;

  final formatter = intl.NumberFormat.decimalPattern();

  bool liked = false;

  String firstHalf;
  String secondHalf;
  bool flag = true;
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    super.initState();
    // listPost = GetHelper().getAllFeed();
    // retrievePosts();
    getUser();

    fetch();

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  Future fetch() async {
    if (isLoading) return;
    isLoading = true;

    ApiResponse apiResponse = ApiResponse();
    const limit = 5;
    try {
      String token = await getToken();
      final response = await http
          .get(Uri.parse(postsURL + "?page=$page" + "&limit=$limit"), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          final List newPosts = jsonDecode(response.body)['posts'];
          setState(() {
            page++;
            isLoading = false;

            if (newPosts.length < limit) {
              hasMore = false;
            }

            items.addAll(newPosts.map((p) => Post.fromJson(p)).toList());
          });
          // we get list of posts, so we need to map each item to post model

          break;
        case 401:
          apiResponse.error = unauthorized;
          break;
        default:
          apiResponse.error = somethingWentWrong;
          break;
      }
    } catch (e) {
      apiResponse.error = serverError;
    }
    return apiResponse;
  }

  _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      // retrievePosts();
      return true;
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

  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        _loading = _loading ? !_loading : _loading;
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

  Future refresh() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 1;
      items.clear();
    });
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: _loading
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
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            'Home',
                            style: TextStyle(
                              fontFamily: 'Billabong',
                              fontSize: 30.0,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 17,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: 160,
                              height: 160,
                              imageUrl: baseURLMobile + user.image,
                              placeholder: (context, url) => Center(
                                // child: Image.asset('assets/images/user0.png'),
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: items.length == 0
                          ? ConstrainedBox(
                              constraints:
                                  BoxConstraints(minHeight: height / 1.4),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // SpinKitFadingCube(
                                    //   size: 30,
                                    //   color: Colors.black.withOpacity(0.2),
                                    // ),
                                    // Icon(
                                    //   Icons.error,
                                    //   size: 40,
                                    //   color: Colors.black.withOpacity(0.2),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Text(
                                        "No Post Available",
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            fontSize: 15),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              color: Colors.black,
                              displacement: 10,
                              onRefresh: refresh,
                              child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics()),
                                  controller: controller,
                                  // primary: false,
                                  shrinkWrap: true,
                                  itemCount: items.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < items.length) {
                                      Post post = items[index];
                                      if (items.length == 1) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.0, 0.0, 10.0, 15.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color: Colors.white,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  child: Column(
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: Container(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black45,
                                                                offset: Offset(
                                                                    0.0, 2.0),
                                                                blurRadius: 6.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: CircleAvatar(
                                                            child: ClipOval(
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: 100,
                                                                height: 100,
                                                                imageUrl:
                                                                    baseURLMobile +
                                                                        post.user
                                                                            .image,
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        Center(
                                                                  // child: Image.asset(
                                                                  //     'assets/images/user0.png'),
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                errorWidget:
                                                                    (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.8),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        title: Text(
                                                          post.user.name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          timeago
                                                              .format(DateTime
                                                                  .parse(
                                                                post.createdAt,
                                                              ))
                                                              .toString(),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        // onDoubleTap: () {
                                                        //   setState(() {
                                                        //     post.selfLiked = true;
                                                        //   });
                                                        //   _handlePostLikeDislike(
                                                        //       post.id);
                                                        // },
                                                        onTap: () {},
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    15,
                                                                    10,
                                                                    15,
                                                                    5),
                                                            child:
                                                                ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                minHeight: 200,
                                                                minWidth: double
                                                                    .infinity,
                                                              ),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  // color:
                                                                  //     Colors.white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .black38,
                                                                      offset: Offset(
                                                                          0.0,
                                                                          8.0),
                                                                      blurRadius:
                                                                          8.0,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    imageUrl:
                                                                        baseURLMobile +
                                                                            post.image,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            SpinKitFadingCube(
                                                                      size: 30,
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.3),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(
                                                                      Icons
                                                                          .error,
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.8),
                                                                    ),
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                ),
                                                              ),
                                                            )),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 10.0,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              20,
                                                                          top:
                                                                              5),
                                                                      child:
                                                                          GestureDetector(
                                                                        child:
                                                                            LikeButton(
                                                                          onTap:
                                                                              (isLiked) async {
                                                                            /// send your request here
                                                                            final bool
                                                                                success =
                                                                                await _handlePostLikeDislike(post.id);

                                                                            /// if failed, you can do nothing
                                                                            return success
                                                                                ? !isLiked
                                                                                : isLiked;
                                                                          },
                                                                          size:
                                                                              30,
                                                                          circleColor: CircleColor(
                                                                              start: Colors.red.shade50,
                                                                              end: Colors.red.shade500),
                                                                          bubblesColor:
                                                                              BubblesColor(
                                                                            dotPrimaryColor:
                                                                                Colors.red.withOpacity(0.8),
                                                                            dotSecondaryColor:
                                                                                Colors.red,
                                                                          ),
                                                                          likeBuilder:
                                                                              (bool isLiked) {
                                                                            return Icon(
                                                                              post.selfLiked ? FluentIcons.heart_20_filled : FluentIcons.heart_20_regular,
                                                                              color: post.selfLiked ? Colors.red : Colors.black,
                                                                              size: 30,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              0,
                                                                          top:
                                                                              5),
                                                                      child:
                                                                          kComment(
                                                                        FluentIcons
                                                                            .chat_20_regular,
                                                                        Colors
                                                                            .black87,
                                                                        () {
                                                                          Navigator.of(context).push(MaterialPageRoute(
                                                                              builder: (context) => CommentScreen(
                                                                                    postId: post.id,
                                                                                  )));
                                                                        },
                                                                        post.commentsCount ??
                                                                            0,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 15,
                                                                      top: 5),
                                                              child: Text(
                                                                numeral(post.likesCount ??
                                                                        0) +
                                                                    " Suka",

                                                                // intl.NumberFormat.decimalPattern().format(100000),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Readmore(
                                                              user: post
                                                                  .user.name,
                                                              // user: post.user.name,
                                                              caption:
                                                                  post.body,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height / 6,
                                            )
                                          ],
                                        );
                                      }
                                      return Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 0.0, 10.0, 15.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0),
                                            child: Column(
                                              children: <Widget>[
                                                ListTile(
                                                  leading: Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black45,
                                                          offset:
                                                              Offset(0.0, 2.0),
                                                          blurRadius: 6.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child: CircleAvatar(
                                                      child: ClipOval(
                                                        child:
                                                            CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          width: 100,
                                                          height: 100,
                                                          imageUrl:
                                                              baseURLMobile +
                                                                  post.user
                                                                      .image,
                                                          placeholder:
                                                              (context, url) =>
                                                                  Center(
                                                            // child: Image.asset(
                                                            //     'assets/images/user0.png'),
                                                            child: Container(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(
                                                            Icons.error,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    post.user.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    timeago
                                                        .format(DateTime.parse(
                                                          post.createdAt,
                                                        ))
                                                        .toString(),
                                                  ),
                                                ),
                                                InkWell(
                                                  // onDoubleTap: () {
                                                  //   setState(() {
                                                  //     post.selfLiked = true;
                                                  //   });
                                                  //   _handlePostLikeDislike(
                                                  //       post.id);
                                                  // },
                                                  onTap: () {},
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          15, 10, 15, 5),
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          minHeight: 200,
                                                          minWidth:
                                                              double.infinity,
                                                        ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            // color:
                                                            //     Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black38,
                                                                offset: Offset(
                                                                    0.0, 8.0),
                                                                blurRadius: 8.0,
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            child:
                                                                CachedNetworkImage(
                                                              fit: BoxFit.cover,
                                                              imageUrl:
                                                                  baseURLMobile +
                                                                      post.image,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  SpinKitFadingCube(
                                                                size: 30,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.3),
                                                              ),
                                                              errorWidget:
                                                                  (context, url,
                                                                          error) =>
                                                                      Icon(
                                                                Icons.error,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.8),
                                                              ),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            20,
                                                                        top: 5),
                                                                child:
                                                                    GestureDetector(
                                                                  child:
                                                                      LikeButton(
                                                                    onTap:
                                                                        (isLiked) async {
                                                                      /// send your request here
                                                                      final bool
                                                                          success =
                                                                          await _handlePostLikeDislike(
                                                                              post.id);

                                                                      /// if failed, you can do nothing
                                                                      return success
                                                                          ? !isLiked
                                                                          : isLiked;
                                                                    },
                                                                    size: 30,
                                                                    circleColor: CircleColor(
                                                                        start: Colors
                                                                            .red
                                                                            .shade50,
                                                                        end: Colors
                                                                            .red
                                                                            .shade500),
                                                                    bubblesColor:
                                                                        BubblesColor(
                                                                      dotPrimaryColor: Colors
                                                                          .red
                                                                          .withOpacity(
                                                                              0.8),
                                                                      dotSecondaryColor:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                    likeBuilder:
                                                                        (bool
                                                                            isLiked) {
                                                                      return Icon(
                                                                        post.selfLiked
                                                                            ? FluentIcons.heart_20_filled
                                                                            : FluentIcons.heart_20_regular,
                                                                        color: post.selfLiked
                                                                            ? Colors.red
                                                                            : Colors.black,
                                                                        size:
                                                                            30,
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left: 0,
                                                                        top: 5),
                                                                child: kComment(
                                                                  FluentIcons
                                                                      .chat_20_regular,
                                                                  Colors
                                                                      .black87,
                                                                  () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(
                                                                            builder: (context) => CommentScreen(
                                                                                  postId: post.id,
                                                                                )));
                                                                  },
                                                                  post.commentsCount ??
                                                                      0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 15,
                                                                top: 5),
                                                        child: Text(
                                                          numeral(post.likesCount ??
                                                                  0) +
                                                              " Suka",

                                                          // intl.NumberFormat.decimalPattern().format(100000),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      Readmore(
                                                        user: post.user.name,
                                                        // user: post.user.name,
                                                        caption: post.body,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                          child: Center(
                                            child: hasMore
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: SpinKitFadingCube(
                                                      size: 30,
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                    ),
                                                  )
                                                : Center(),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10));
                                    }
                                  }),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
