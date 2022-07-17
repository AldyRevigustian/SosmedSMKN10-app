import 'user.dart';

class Post {
  int id;
  String body;
  String image;
  int likesCount;
  int commentsCount;
  User user;
  bool selfLiked;
  String createdAt;

  Post(
      {this.id,
      this.body,
      this.image,
      this.likesCount,
      this.commentsCount,
      this.user,
      this.selfLiked,
      this.createdAt});

// map json to post model

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        body: json['body'],
        image: json['image'],
        likesCount: json['likes_count'],
        commentsCount: json['comments_count'],
        selfLiked: json['likes'].length > 0,
        createdAt: json['created_at'],
        user: User(
            id: json['user']['id'],
            name: json['user']['name'],
            image: json['user']['image']));
  }
}
