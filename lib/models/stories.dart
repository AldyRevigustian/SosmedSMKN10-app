import 'user.dart';

class Story {
  int id;
  User user;
  String createdAt;
  bool selfViewed;

  Story({
    this.id,
    this.user,
    this.createdAt,
    this.selfViewed,
  });

// map json to Story model

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      createdAt: json['created_at'],
      selfViewed: json['view'].length > 0,
      user: User(
          id: json['user']['id'],
          name: json['user']['name'],
          image: json['user']['image']),
    );
  }
}
