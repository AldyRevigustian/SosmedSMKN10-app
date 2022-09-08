import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/services/post_service.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';

class ViewStory extends StatefulWidget {
  final user_id;
  final name;
  final image;
  const ViewStory({Key key, this.user_id, this.name, this.image})
      : super(key: key);

  @override
  State<ViewStory> createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  StoryController controller = StoryController();

  List<dynamic> _storyList = [];

  Future<void> retrieveStories() async {
    ApiResponse response = await getStoryImage(widget.user_id);

    if (response.error == null) {
      setState(() {
        _storyList = response.data as List<dynamic>;
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

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    retrieveStories();
  }

  //  List<StoryItem> storyItems = [
  //   StoryItem.pageImage(url: url, controller: controller)
  // ]; // your li
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              child: ClipOval(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  imageUrl: baseURLMobile + widget.image,
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
            SizedBox(
              width: 13,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Text(
                widget.name,
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            )
          ],
        ),
      ),
      body: StoryView(
          onVerticalSwipeComplete: (direction) {
            if (direction == Direction.down) {
              Navigator.pop(context);
            }
          },
          onComplete: () {
            Navigator.pop(context);
          },
          controller: controller,
          storyItems: _storyList
              .map((p) => StoryItem.pageImage(
                  url: baseURLMobile + p.image, controller: controller))
              .toList()),
    );
  }
}
