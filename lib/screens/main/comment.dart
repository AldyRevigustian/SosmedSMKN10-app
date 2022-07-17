import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:instagram_redesign_ui/constant.dart';
import 'package:instagram_redesign_ui/models/api_response.dart';
import 'package:instagram_redesign_ui/models/comment.dart';
import 'package:instagram_redesign_ui/screens/login_screen.dart';
import 'package:instagram_redesign_ui/services/comment_service.dart';
import 'package:instagram_redesign_ui/services/user_service.dart';

class CommentScreen extends StatefulWidget {
  final int postId;

  CommentScreen({this.postId});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<dynamic> _commentsList = [];
  bool _loading = true;
  int userId = 0;
  int _editCommentId = 0;
  TextEditingController _txtCommentController = TextEditingController();

  // Get comments
  Future<void> _getComments() async {
    userId = await getUserId();
    ApiResponse response = await getComments(widget.postId ?? 0);

    if (response.error == null) {
      setState(() {
        _commentsList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
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

  // create comment
  void _createComment() async {
    ApiResponse response =
        await createComment(widget.postId ?? 0, _txtCommentController.text);

    if (response.error == null) {
      _txtCommentController.clear();
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
    } else {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // edit comment
  void _editComment() async {
    ApiResponse response =
        await editComment(_editCommentId, _txtCommentController.text);

    if (response.error == null) {
      _editCommentId = 0;
      _txtCommentController.clear();
      _getComments();
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

  // Delete comment
  void _deleteComment(int commentId) async {
    ApiResponse response = await deleteComment(commentId);

    if (response.error == null) {
      _getComments();
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
    _getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.only(top: 5),
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
            : Column(children: [
                Expanded(
                    child: RefreshIndicator(
                        color: Colors.black,
                        onRefresh: () {
                          return _getComments();
                        },
                        child: ListView.builder(
                            itemCount: _commentsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              Comment comment = _commentsList[index];
                              return Container(
                                padding: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black26, width: 1))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  image: comment.user.image !=
                                                          null
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                              baseURLMobile +
                                                                  '${comment.user.image}'),
                                                          fit: BoxFit.cover)
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.blueGrey),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              '${comment.user.name}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17),
                                            )
                                          ],
                                        ),
                                        comment.user.id == userId
                                            ? PopupMenuButton(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                    )),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                      child: Text('Delete'),
                                                      value: 'delete')
                                                ],
                                                onSelected: (val) {
                                                  // if (val == 'edit') {
                                                  //   setState(() {
                                                  //     _editCommentId =
                                                  //         comment.id ?? 0;
                                                  //     _txtCommentController.text =
                                                  //         comment.comment ?? '';
                                                  //   });
                                                  if (val == 'delete') {
                                                    _deleteComment(
                                                        comment.id ?? 0);
                                                  }
                                                },
                                              )
                                            : SizedBox()
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      '${comment.comment}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              );
                            }))),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, -2),
                        blurRadius: 2)
                  ]),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: kInputDecoration('Comment'),
                          controller: _txtCommentController,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          FluentIcons.send_20_filled,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        onPressed: () {
                          if (_txtCommentController.text.isNotEmpty) {
                            setState(() {
                              _loading = true;
                            });
                            if (_editCommentId > 0) {
                              _editComment();
                            } else {
                              _createComment();
                            }
                          }
                        },
                      )
                    ],
                  ),
                )
              ]),
      ),
    );
  }
}
