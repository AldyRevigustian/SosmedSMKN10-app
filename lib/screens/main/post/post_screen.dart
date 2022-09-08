import 'dart:io';
import 'dart:typed_data';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smkn10sosmed/screens/main/post/add_post.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/screens/main/post/add_post.dart';
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
          .getImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;

      setState(() {
        imagePath = image.path;
        imageFile = File(image.path);
        picked = imageFile.readAsBytesSync();
      });
      return imageFile;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
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
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.1) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }
  // _handleScrollEvent(ScrollNotification scroll) {
  //   if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
  //     if (currentPage != lastPage) {
  //       _fetchNewMedia();
  //     }
  //   }
  // }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(currentPage, 18);
      // List<AssetEntity> media =
      //     await albums[0].getAssetListPaged(currentPage, 15);
      List<Widget> temp = [];
      for (var asset in media) {
        if (asset.type == AssetType.image) {
          temp.add(FutureBuilder(
            future: asset.thumbDataWithSize(500, 500, quality: 70),
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
              onTap: () async {
                if (picked != null) {
                  final tempDir = await getTemporaryDirectory();
                  File decodedimgfile = await File("${tempDir.path}/image.png")
                      .writeAsBytes(picked);
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
                        builder: (_) =>
                            AddPost(image: croppedFile.readAsBytesSync()),
                      ),
                    );
                  }
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
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          picked,
                          fit: BoxFit.contain,
                        ),
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
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, -3),
                          blurRadius: 2)
                    ]),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 13, 13, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowGlow();
                        return;
                      },
                      child: GridView.builder(
                          // padding: EdgeInsets.all(10),
                          itemCount: _mediaList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: _mediaList[index]);
                          }),
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
