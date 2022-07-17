class PostSingle {
  int id;
  String body;
  String image;
  String createdAt;
  int likesCount;
  int commentsCount;

  PostSingle(
      {this.id,
      this.body,
      this.image,
      this.likesCount,
      this.commentsCount,
      this.createdAt});

// map json to post model

  factory PostSingle.fromJson(Map<String, dynamic> json) {
    return PostSingle(
      id: json['id'],
      body: json['body'],
      image: json['image'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      createdAt: json['created_at'],
    );
  }
}
