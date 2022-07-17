import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:instagram_redesign_ui/constant.dart';
import 'package:instagram_redesign_ui/helper/get_helper.dart';
import 'package:instagram_redesign_ui/models/api_response.dart';
import 'package:instagram_redesign_ui/models/post.dart';
import 'package:instagram_redesign_ui/screens/login_screen.dart';
import 'package:instagram_redesign_ui/screens/main/comment.dart';
import 'package:instagram_redesign_ui/services/post_service.dart';
import 'package:instagram_redesign_ui/services/user_service.dart';
import 'package:instagram_redesign_ui/widget/build_post.dart';
import 'package:instagram_redesign_ui/widget/readmore.dart';
import 'package:like_button/like_button.dart';
import 'package:numeral/fun.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' as intl;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final fifteenAgo = DateTime.now().subtract(Duration(minutes: 15));

  Future listPost;
  List<dynamic> _postList = [];
  int userId = 0;

  bool _loading = true;

  final formatter = intl.NumberFormat.decimalPattern();

  bool liked = false;

  String firstHalf;
  String secondHalf;
  bool flag = true;
  // get all posts
  Future<void> retrievePosts() async {
    userId = await getUserId();
    ApiResponse response = await getPosts();

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
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

  _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      retrievePosts();
      return true;
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

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    // listPost = GetHelper().getAllFeed();
    retrievePosts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      'SMKN 10',
                      style: TextStyle(
                        fontFamily: 'Billabong',
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  Container(
                    width: 170,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 2, 2, 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Cari Teman",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          )
                        ],
                      ),
                    ),
                    // color: Colors.white,
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
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
                                    color: Colors.black.withOpacity(0.2),
                                    fontSize: 15),
                              ),
                            )
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.black,
                        displacement: 10,
                        // edgeOffset: 10,
                        onRefresh: () {
                          return retrievePosts();
                        },
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          // primary: false,
                          child: _postList.length == 0
                              ? ConstrainedBox(
                                  constraints:
                                      BoxConstraints(minHeight: height / 1.4),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            "No Post Available",
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                fontSize: 15),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : _postList.length == 1
                                  ? Column(
                                      children: [
                                        ListView.builder(
                                            primary: false,
                                            shrinkWrap: true,
                                            itemCount: _postList.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              Post post = _postList[index];

                                              return Padding(
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
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.0),
                                                    child: Column(
                                                      children: <Widget>[
                                                        ListTile(
                                                          leading: Container(
                                                            width: 50.0,
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black45,
                                                                  offset:
                                                                      Offset(
                                                                          0.0,
                                                                          2.0),
                                                                  blurRadius:
                                                                      6.0,
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
                                                                  imageUrl: baseURLMobile +
                                                                      post.user
                                                                          .image,
                                                                  placeholder:
                                                                      (context,
                                                                              url) =>
                                                                          Center(
                                                                    child: Image
                                                                        .asset(
                                                                            'assets/images/user0.png'),
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            post.user.name,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                                  minHeight:
                                                                      200,
                                                                  minWidth: double
                                                                      .infinity,
                                                                ),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    // color: Colors.black.withOpacity(0.8),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
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
                                                                          .contain,
                                                                      imageUrl:
                                                                          baseURLMobile +
                                                                              post.image,
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              SpinKitFadingCube(
                                                                        size:
                                                                            30,
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(Icons
                                                                              .error),
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
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
                                                                        padding: const EdgeInsets.only(
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
                                                                              final bool success = await _handlePostLikeDislike(post.id);

                                                                              /// if failed, you can do nothing
                                                                              return success ? !isLiked : isLiked;
                                                                            },
                                                                            size:
                                                                                30,
                                                                            circleColor:
                                                                                CircleColor(start: Colors.red.shade50, end: Colors.red.shade500),
                                                                            bubblesColor:
                                                                                BubblesColor(
                                                                              dotPrimaryColor: Colors.red.withOpacity(0.8),
                                                                              dotSecondaryColor: Colors.red,
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
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                0,
                                                                            top:
                                                                                5),
                                                                        child: kComment(
                                                                            FluentIcons
                                                                                .chat_20_regular,
                                                                            Colors.black87,
                                                                            () {
                                                                          Navigator.of(context).push(MaterialPageRoute(
                                                                              builder: (context) => CommentScreen(
                                                                                    postId: post.id,
                                                                                  )));
                                                                        }),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15,
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
                                              );
                                            }),
                                        Container(
                                          height: height / 6,
                                        )
                                      ],
                                    )
                                  : ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      itemCount: _postList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        Post post = _postList[index];

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
                                                            color:
                                                                Colors.black45,
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
                                                            fit: BoxFit.cover,
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
                                                              child: Image.asset(
                                                                  'assets/images/user0.png'),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
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
                                                          .format(
                                                              DateTime.parse(
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
                                                              // color: Colors.black.withOpacity(0.8),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black38,
                                                                  offset:
                                                                      Offset(
                                                                          0.0,
                                                                          8.0),
                                                                  blurRadius:
                                                                      8.0,
                                                                ),
                                                              ],
                                                            ),
                                                            child: ClipRRect(
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .contain,
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
                                                                          0.8),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
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
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 10,
                                                                      right: 20,
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
                                                                            await _handlePostLikeDislike(post.id);

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
                                                                            .withOpacity(0.8),
                                                                        dotSecondaryColor:
                                                                            Colors.red,
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
                                                                  padding: const EdgeInsets
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
                                                                  }),
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
                                      }),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
