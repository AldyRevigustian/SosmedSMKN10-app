class SearchModel {
  int id;
  String name;
  String fullname;
  String image;
  String email;

  SearchModel({this.id, this.name, this.fullname, this.image, this.email});

  // function to convert json data to Search model
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'],
      name: json['name'],
      fullname: json['fullname'],
      image: json['image'],
      email: json['email'],
    );
  }
}
