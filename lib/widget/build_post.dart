import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart' as intl;
import 'package:like_button/like_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:numeral/fun.dart';

class BuildPost extends StatefulWidget {
  const BuildPost({
    Key key,
    this.authorName,
    this.authorImageUrl,
    this.timeAgo,
    this.imageUrl,
    this.caption,
    this.like,
    this.comment,
  }) : super(key: key);
  final String authorName;
  final String authorImageUrl;
  final String timeAgo;
  final String imageUrl;
  final String caption;
  final String like;
  final String comment;

  @override
  State<BuildPost> createState() => _BuildPostState();
}

class _BuildPostState extends State<BuildPost> {
  final formatter = intl.NumberFormat.decimalPattern();

  bool liked = false;

  String firstHalf;
  String secondHalf;
  bool flag = true;

  @override
  void initState() {
    if (widget.caption.length > 90) {
      firstHalf = widget.caption.substring(0, 90);
      secondHalf = widget.caption.substring(50, widget.caption.length);
    } else {
      firstHalf = widget.caption;
      secondHalf = "";
    }
    super.initState();
  }

  // formatText();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
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
                        imageUrl: widget.authorImageUrl,
                        placeholder: (context, url) =>
                            // SpinKitFadingCube(
                            //   size: 30,
                            //   color: Colors.white.withOpacity(0.8),
                            // ),
                            Center(
                          child: Image.asset('assets/images/user0.png'),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.timeAgo,
                ),
              ),
              InkWell(
                onDoubleTap: () => print('Like post'),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => ViewPostScreen(post: posts[widget.index]),
                  //   ),
                  // );
                },
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 200,
                        minWidth: double.infinity,
                      ),
                      child: Container(
                        // constraints: BoxConstraints(
                        //   minHeight: 200,
                        //   minWidth: double.infinity,
                        // ),
                        decoration: BoxDecoration(
                          // color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              offset: Offset(0.0, 8.0),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),

                        // child: SpinKitFadingCube(
                        //   size: 30,
                        //   color: Colors.white.withOpacity(0.8),
                        // ),

                        child: ClipRRect(
                          child: CachedNetworkImage(
                            fit: BoxFit.contain,
                            imageUrl: widget.imageUrl,
                            placeholder: (context, url) => SpinKitFadingCube(
                              size: 30,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        // child: ClipRRect(
                        //   child: Image.asset(posts[widget.index].imageUrl),
                        //   borderRadius: BorderRadius.circular(20),
                        // ),
                      ),
                    )),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            // IconButton(
                            //   icon: liked
                            //       ? Icon(
                            //           Icons.favorite,
                            //           color: Colors.red,
                            //         )
                            //       : Icon(Icons.favorite_border),
                            //   iconSize: 25.0,
                            //   onPressed: () {
                            //     setState(() {
                            //       liked = !liked;
                            //       print(liked);
                            //     });
                            //   },
                            // ),
                            // Text(
                            //   formatter
                            //       .format(int.parse((widget.like)))
                            //       .toString(),
                            //   style: TextStyle(
                            //     fontSize: 14.0,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Row(
                                children: [
                                  LikeButton(
                                    size: 30,
                                    circleColor: CircleColor(
                                        start: Colors.red.shade50,
                                        end: Colors.red.shade500),
                                    bubblesColor: BubblesColor(
                                      dotPrimaryColor:
                                          Colors.red.withOpacity(0.8),
                                      dotSecondaryColor: Colors.red,
                                    ),
                                    likeBuilder: (bool isLiked) {
                                      return Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isLiked ? Colors.red : Colors.black,
                                        size: 30,
                                      );
                                      // },
                                      // likeCount: 2000,
                                      // countBuilder:
                                      //     (int count, bool isLiked, String text) {
                                      //   var color =
                                      //       isLiked ? Colors.black : Colors.black;
                                      //   // Widget result;

                                      //   return Text(
                                      //     numeral(int.parse(text)),
                                      //     style: TextStyle(
                                      //         color: color,
                                      //         fontWeight: FontWeight.bold),
                                      //   );
                                    },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    numeral(int.parse(widget.like)),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 5.0),
                                  IconButton(
                                    icon:
                                        Icon(MdiIcons.commentProcessingOutline),
                                    color: Colors.black,
                                    iconSize: 25.0,
                                    onPressed: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (_) => ViewPostScreen(
                                      //         post: posts[index]),
                                      //   ),
                                      // );
                                    },
                                  ),
                                  // Text(
                                  //   numeral(int.parse(widget.comment)),
                                  //   style: TextStyle(
                                  //     fontSize: 14.0,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5, left: 10, bottom: 10, right: 20),
                      // child: formatText(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Disukai Oleh" +
                          //       " " +
                          //       numeral(int.parse(widget.comment)) +
                          //       " Orang",
                          //   style: TextStyle(
                          //     fontFamily: "Proxima",
                          //     fontSize: 14.0,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 5,
                          // ),
                          // Text("Disukai Oleh"),
                          Container(
                            child: secondHalf.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: new Text(firstHalf,
                                        style: TextStyle(fontSize: 14)),
                                  )
                                : new Column(
                                    children: <Widget>[
                                      new Text(
                                        flag
                                            ? (firstHalf + "...")
                                            : (firstHalf + secondHalf),
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      new InkWell(
                                        child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 5),
                                              child: new Text(
                                                flag
                                                    ? "Baca Selengkapnya"
                                                    : "Lebih Sedikit",
                                                style: new TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            flag = !flag;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
