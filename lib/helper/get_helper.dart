import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:instagram_redesign_ui/models/feed_model.dart';

class GetHelper {
  Future<List<Feed>> getAllFeed() async {
    final response = await http.get(
        Uri.parse("https://6268a04eaa65b5d23e77f552.mockapi.io/instagram"));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      log("Masok");
      return jsonResponse.map((job) => new Feed.fromJson(job)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // return ;
      throw Exception('Failed to load Feed');
    }
  }

  Future postFeed(String authorName, String authorImageUrl, String imageUrl,
      String type, String caption) async {
    var authorName = "Aldy";
    var authorImageUrl =
        "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cGVyc29ufGVufDB8MnwwfHw%3D&auto=format&fit=crop&w=500&q=60";
    var timeAgo = "5 min";
    var imageUrl =
        "https://images.unsplash.com/photo-1655097775175-f6718e1395d8?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60";
    var like = "100000";
    var comment = "1000";

    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST',
        Uri.parse('https://6268a04eaa65b5d23e77f552.mockapi.io/instagram'));
    request.bodyFields = {
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'timeAgo': timeAgo,
      'imageUrl': imageUrl,
      'caption': caption,
      'like': like,
      'comment': comment,
      'type': type,
      'id': ''
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      return true;
      // print(await response.stream.bytesToString());
    } else {
      return false;
      // print(response.reasonPhrase);
    }
  }
}
