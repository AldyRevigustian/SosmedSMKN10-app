import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smkn10sosmed/models/stories.dart';
import 'package:smkn10sosmed/screens/add_story.dart';
import 'package:smkn10sosmed/screens/main/post/comment.dart';
import 'package:smkn10sosmed/screens/main/search/search.dart';
import 'package:smkn10sosmed/screens/main/view_story.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/post.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/post/comment.dart';
import 'package:smkn10sosmed/screens/main/profile/profile.dart';
import 'package:smkn10sosmed/services/post_service.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import 'package:smkn10sosmed/widget/readmore.dart';
import 'package:like_button/like_button.dart';
import 'package:numeral/fun.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' as intl;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isHeartAnimated = false;
  // final fifteenAgo = DateTime.now().subtract(Duration(minutes: 15));
  User user;

  Future listPost;
  List<dynamic> _postList = [];
  List<dynamic> _storyList = [];
  int userId = 0;

  bool _loading = true;

  final formatter = intl.NumberFormat.decimalPattern();

  bool liked = false;

  String firstHalf;
  String secondHalf;
  bool flag = true;

  Uint8List picked;

  File imageFile;
  String imageData;
  String imagePath;

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
      kErrorSnackbar(context, '${response.error}');
    }
  }

  Future<void> retrieveStories() async {
    userId = await getUserId();
    ApiResponse response = await getStories();

    if (response.error == null) {
      setState(() {
        _storyList = response.data as List<dynamic>;
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
      retrievePosts();
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

  _handleView(int story) async {
    ApiResponse response = await viewedStory(story);

    if (response.error == null) {
      retrievePosts();
      retrieveStories();
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

  _handlePostLike(int postId) async {
    ApiResponse response = await likePost(postId);
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

  Future pickImageC() async {
    try {
      final image = await ImagePicker()
          .getImage(source: ImageSource.camera, imageQuality: 70);

      if (image == null) return;

      setState(() {
        imageFile = File(image.path);
        picked = imageFile.readAsBytesSync();
        // picked =
      });

      if (picked != null) {
        final tempDir = await getTemporaryDirectory();
        File decodedimgfile =
            await File("${tempDir.path}/image.png").writeAsBytes(picked);
        File croppedFile = await ImageCropper().cropImage(
            sourcePath: decodedimgfile.path,
            maxHeight: 700,
            maxWidth: 700,
            // compressQuality: 90,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              // CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              // CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
            androidUiSettings: AndroidUiSettings(
              // hideBottomControls: true,
              lockAspectRatio: false,
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.white,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              backgroundColor: CustColors.primaryWhite,
              activeControlsWidgetColor: CustColors.primaryBlue,
            ),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            ));

        if (croppedFile != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddStory(image: croppedFile.readAsBytesSync()),
            ),
          );
        }
      }

      // imageData = base64Encode(imageFile.readAsBytesSync());
      return imageData;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
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
    retrieveStories();
    getUser();

    super.initState();
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Search(),
                              ),
                            );
                          },
                          child: CircleAvatar(
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
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: RefreshIndicator(
                        color: Colors.black,
                        displacement: 10,
                        // edgeOffset: 10,
                        onRefresh: () {
                          retrievePosts();
                          return retrieveStories();
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
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            "Please Wait",
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
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 10, bottom: 0),
                                          child: Container(
                                              height: 90,
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      pickImageC();
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 7),
                                                      child: Column(
                                                        children: [
                                                          GestureDetector(
                                                            child: Stack(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              children: [
                                                                Container(
                                                                  height: 65,
                                                                  width: 65,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      border: Border.all(
                                                                          width:
                                                                              2.5,
                                                                          color:
                                                                              Colors.blue[400])),
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      imageUrl:
                                                                          baseURLMobile +
                                                                              user.image,
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              Center(
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ClipOval(
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                        .white,
                                                                    child: Icon(
                                                                      FluentIcons
                                                                          .add_circle_20_filled,
                                                                      color: Colors
                                                                              .blue[
                                                                          400],
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            "New Story",
                                                            style: TextStyle(
                                                                fontSize: 0),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                      // primary: false,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          _storyList.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        Story story =
                                                            _storyList[index];
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      7),
                                                          child: Container(
                                                            width: 65,
                                                            child: Column(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ViewStory(
                                                                          user_id: story
                                                                              .user
                                                                              .id,
                                                                          image: story
                                                                              .user
                                                                              .image,
                                                                          name: story
                                                                              .user
                                                                              .name,
                                                                        ),
                                                                      ),
                                                                    );
                                                                    viewedStory(
                                                                        story
                                                                            .id);
                                                                    setState(
                                                                        () {
                                                                      story.selfViewed =
                                                                          true;
                                                                    });
                                                                  },
                                                                  child: story.selfViewed ==
                                                                          true
                                                                      ? Container(
                                                                          height:
                                                                              65,
                                                                          width:
                                                                              65,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(100),
                                                                          ),
                                                                          child:
                                                                              ClipOval(
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              fit: BoxFit.cover,
                                                                              width: 100,
                                                                              height: 100,
                                                                              imageUrl: baseURLMobile + story.user.image,
                                                                              placeholder: (context, url) => Center(
                                                                                child: Container(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Icon(
                                                                                Icons.error,
                                                                                color: Colors.black.withOpacity(0.8),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          height:
                                                                              65,
                                                                          width:
                                                                              65,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(100),
                                                                              border: Border.all(width: 2.5, color: Colors.blue[400])),
                                                                          child:
                                                                              ClipOval(
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              fit: BoxFit.cover,
                                                                              width: 100,
                                                                              height: 100,
                                                                              imageUrl: baseURLMobile + story.user.image,
                                                                              placeholder: (context, url) => Center(
                                                                                child: Container(
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Icon(
                                                                                Icons.error,
                                                                                color: Colors.black.withOpacity(0.8),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  story.user
                                                                      .name,
                                                                  // "asdasdasdasdasdasdasdsa",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          0),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              )),
                                        ),
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
                                                                        .black
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
                                                        GestureDetector(
                                                          onDoubleTap: () {
                                                            setState(() {
                                                              post.selfLiked =
                                                                  true;
                                                            });
                                                            _handlePostLike(
                                                                post.id);
                                                          },
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
                                                                          .cover,
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
                                                                            .withOpacity(0.3),
                                                                      ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(0.8),
                                                                      ),
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
                                                                          onDoubleTap:
                                                                              () {
                                                                            log("OKE");
                                                                          },
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
                                              );
                                            }),
                                        Container(
                                          height: height / 6,
                                        )
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 10, bottom: 0),
                                          child: Container(
                                              height: 90,
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      pickImageC();
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 7),
                                                      child: Column(
                                                        children: [
                                                          GestureDetector(
                                                            child: Stack(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              children: [
                                                                Container(
                                                                  height: 65,
                                                                  width: 65,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      border: Border.all(
                                                                          width:
                                                                              2.5,
                                                                          color:
                                                                              Colors.blue[400])),
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                      imageUrl:
                                                                          baseURLMobile +
                                                                              user.image,
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              Center(
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(0.8),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ClipOval(
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                        .white,
                                                                    child: Icon(
                                                                      FluentIcons
                                                                          .add_circle_20_filled,
                                                                      color: Colors
                                                                              .blue[
                                                                          400],
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            "New Story",
                                                            style: TextStyle(
                                                                fontSize: 0),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                      // primary: false,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          _storyList.length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        Story story =
                                                            _storyList[index];
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      7),
                                                          child: Container(
                                                            width: 65,
                                                            child: Column(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ViewStory(
                                                                          user_id: story
                                                                              .user
                                                                              .id,
                                                                          image: story
                                                                              .user
                                                                              .image,
                                                                          name: story
                                                                              .user
                                                                              .name,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 65,
                                                                    width: 65,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                100),
                                                                        border: Border.all(
                                                                            width:
                                                                                2.5,
                                                                            color:
                                                                                Colors.blue[400])),
                                                                    child:
                                                                        ClipOval(
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width:
                                                                            100,
                                                                        height:
                                                                            100,
                                                                        imageUrl:
                                                                            baseURLMobile +
                                                                                story.user.image,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                Center(
                                                                          child:
                                                                              Container(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Icon(
                                                                          Icons
                                                                              .error,
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.8),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  story.user
                                                                      .name,
                                                                  // "asdasdasdasdasdasdasdsa",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black87,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          0),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              )),
                                        ),
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
                                                        GestureDetector(
                                                          onDoubleTap: () {
                                                            setState(() {
                                                              post.selfLiked =
                                                                  true;
                                                            });
                                                            _handlePostLike(
                                                                post.id);
                                                          },
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
                                                                    // color:
                                                                    //     Colors.white,
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
                                                                          .cover,
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
                                                                            .withOpacity(0.3),
                                                                      ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(0.8),
                                                                      ),
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
                                                                          onDoubleTap:
                                                                              () {
                                                                            log("POKE");
                                                                          },
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
                                              );
                                            }),
                                      ],
                                    ),
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
