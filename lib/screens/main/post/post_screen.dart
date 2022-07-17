import 'dart:io';
import 'dart:typed_data';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_redesign_ui/const.dart';
import 'package:instagram_redesign_ui/screens/main/post/add_post.dart';
import 'package:photo_manager/photo_manager.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Widget> _mediaList = [];
  int currentPage = 0;
  int lastPage;
  Uint8List picked;

  File imageFile;
  String imageData;
  String imagePath;

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  Future pickImage() async {
    try {
      var image = await ImagePicker()
          .getImage(source: ImageSource.gallery, imageQuality: 50);
      if (image == null) return;

      setState(() {
        imagePath = image.path;
        imageFile = File(image.path);
        picked = imageFile.readAsBytesSync();
      });
      // print(imageData);
      print(imageFile);
      return imageFile;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker()
          .getImage(source: ImageSource.camera, imageQuality: 50);

      if (image == null) return;

      setState(() {
        imageFile = File(image.path);
        picked = imageFile.readAsBytesSync();
        // picked =
      });
      // imageData = base64Encode(imageFile.readAsBytesSync());
      return imageData;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  // @override
  // void dispose() {
  //   _fetchNewMedia().dispose();
  //   print('Dispose used');
  //   super.dispose();
  // }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      print(albums);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(currentPage, 10);
      print(media);
      List<Widget> temp = [];
      for (var asset in media) {
        if (asset.type == AssetType.image) {
          temp.add(FutureBuilder(
            future: asset.thumbDataWithSize(400, 400),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitFadingCube(
                    size: 20,
                    color: Colors.black.withOpacity(0.2),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  return snapshot.data.isEmpty
                      ? Center(child: Text("No Data"))
                      : Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () {
                                  // log("Pick");
                                  // log(snapshot.data.toString());
                                  setState(() {
                                    picked = snapshot.data;
                                  });
                                },
                                child: Image.memory(
                                  snapshot.data,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        );
                } else {
                  return Text('Empty data');
                }
              } else {
                return Container();
              }
            },
          ));
        }
      }
      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      PhotoManager.openSetting();
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        _handleScrollEvent(scroll);
        return;
      },
      child: Scaffold(
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
          automaticallyImplyLeading: false,
          leading: PopupMenuButton(
              // icon: IconIcons.menu),
              child: Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: Icon(
                    Icons.menu,
                    color: Colors.black.withOpacity(0.8),
                  )),
              itemBuilder: (context) => [
                    PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              FluentIcons.camera_20_filled,
                              color: Colors.black54,
                              // size: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Camera")
                          ],
                        ),
                        value: 'camera'),
                    PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              FluentIcons.image_20_filled,
                              color: Colors.black54,
                              // size: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Galery")
                          ],
                        ),
                        value: 'galery')
                  ],
              onSelected: (val) {
                if (val == 'camera') {
                  pickImageC();
                } else if (val == "galery") {
                  pickImage();
                }
              }),
          actions: [
            InkWell(
              // borderRadius: BorderRadius.circular(80),
              onTap: () {
                if (picked != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPost(image: picked),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: picked != null
                      ? Colors.black
                      : Colors.black.withOpacity(0.3),
                  size: 20,
                ),
              ),
            )
          ],
          // leading: Text,
        ),
        body: Column(
          children: [
            Container(
              height: 10,
              color: CustColors.primaryWhite,
            ),
            Container(
                color: CustColors.primaryWhite,
                height: height / 2.4,
                width: width,
                child: (picked != null)
                    ? Image.memory(
                        picked,
                        fit: BoxFit.contain,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SpinKitFadingCube(
                              size: 20,
                              color: Colors.black.withOpacity(0.2),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                "Pick a Image",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.2),
                                    fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      )
                //   child: Text(
                //   "Pick Image",
                //   style: TextStyle(
                //     fontFamily: "Proxima",
                //     fontSize: 12,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black.withOpacity(0.5),
                //   ),
                // )),
                ),
            Container(
              height: 10,
              color: CustColors.primaryWhite,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(0, -2),
                      blurRadius: 2)
                ]),
                child: GridView.builder(
                    itemCount: _mediaList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return _mediaList[index];
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
