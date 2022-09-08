class ImageStory {
  int id;
  String image;
  String createdAt;

  ImageStory({this.id, this.image, this.createdAt});

// map json to Story model

  factory ImageStory.fromJson(Map<String, dynamic> json) {
    return ImageStory(
      id: json['id'],
      image: json['image'],
      createdAt: json['created_at'],
    );
  }
}
