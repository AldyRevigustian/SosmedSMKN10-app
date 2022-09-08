import 'user.dart';

class Story {
  int id;
  User user;
  String createdAt;

  Story({
    this.id,
    this.user,
    this.createdAt,
  });

// map json to Story model

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      createdAt: json['created_at'],
      user: User(
          id: json['user']['id'],
          name: json['user']['name'],
          image: json['user']['image']),
    );
  }
}
