import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/post.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/post/comment.dart';
import 'package:smkn10sosmed/screens/main/navbar.dart';
import 'package:smkn10sosmed/services/post_service.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import 'package:smkn10sosmed/widget/readmore.dart';
import 'package:like_button/like_button.dart';
import 'package:numeral/fun.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' as intl;

class ViewSearchPost extends StatefulWidget {
  const ViewSearchPost({
    Key key,
    this.id,
    this.func,
  }) : super(key: key);
  final int id;
  final Function func;

  @override
  _ViewSearchPostState createState() => _ViewSearchPostState();
}

class _ViewSearchPostState extends State<ViewSearchPost> {
  List<dynamic> _postList = [];

  bool _loading = true;

  final formatter = intl.NumberFormat.decimalPattern();

  bool liked = false;

  Future<void> retrievePosts(int id) async {
    // userId = await getUserId();
    ApiResponse response = await getPostsPerId(id.toString());

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
      kErrorSnackbar(context, '${response.error}');
    }
  }

  _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      retrievePosts(postId);
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

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      Navigator.pop(context);
      widget.func;
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

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: CustColors.primaryWhite,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    retrievePosts(widget.id);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              "Post",
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
          ),
          centerTitle: true,
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
        ),
        body: _loading
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
            : Center(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: _postList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Post post = _postList[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 20, 10.0, 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
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
                                          offset: Offset(0.0, 2.0),
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                          imageUrl:
                                              baseURLMobile + post.user.image,
                                          placeholder: (context, url) => Center(
                                            child: Image.asset(
                                                'assets/images/user0.png'),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    post.user.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
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
                                  onTap: () {},
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 10, 15, 5),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: 200,
                                          minWidth: double.infinity,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            // color: Colors.black.withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black38,
                                                offset: Offset(0.0, 8.0),
                                                blurRadius: 8.0,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
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
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 20,
                                                    top: 5),
                                                child: GestureDetector(
                                                  child: LikeButton(
                                                    onTap: (isLiked) async {
                                                      /// send your request here
                                                      final bool success =
                                                          await _handlePostLikeDislike(
                                                              post.id);

                                                      /// if failed, you can do nothing
                                                      return success
                                                          ? !isLiked
                                                          : isLiked;
                                                    },
                                                    size: 30,
                                                    circleColor: CircleColor(
                                                        start:
                                                            Colors.red.shade50,
                                                        end: Colors
                                                            .red.shade500),
                                                    bubblesColor: BubblesColor(
                                                      dotPrimaryColor: Colors
                                                          .red
                                                          .withOpacity(0.8),
                                                      dotSecondaryColor:
                                                          Colors.red,
                                                    ),
                                                    likeBuilder:
                                                        (bool isLiked) {
                                                      return Icon(
                                                        post.selfLiked
                                                            ? FluentIcons
                                                                .heart_20_filled
                                                            : FluentIcons
                                                                .heart_20_regular,
                                                        color: post.selfLiked
                                                            ? Colors.red
                                                            : Colors.black,
                                                        size: 30,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0, top: 5),
                                                child: kComment(
                                                  FluentIcons.chat_20_regular,
                                                  Colors.black87,
                                                  () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CommentScreen(
                                                                  postId:
                                                                      post.id,
                                                                )));
                                                  },
                                                  post.commentsCount ?? 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, top: 5),
                                        child: Text(
                                          numeral(post.likesCount ?? 0) +
                                              " Suka",

                                          // intl.NumberFormat.decimalPattern().format(100000),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Readmore(
                                        user: post.user.name,
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
              ));
  }
}
