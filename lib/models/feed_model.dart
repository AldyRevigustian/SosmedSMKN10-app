class Feed {
  String authorName;
  String authorImageUrl;
  String timeAgo;
  String imageUrl;
  String caption;
  String like;
  String comment;
  String type;

  Feed({
    this.authorName,
    this.authorImageUrl,
    this.timeAgo,
    this.imageUrl,
    this.caption,
    this.like,
    this.comment,
    this.type,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      authorName: json['authorName'],
      authorImageUrl: json['authorImageUrl'],
      timeAgo: json['timeAgo'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      like: json['like'].toString(),
      comment: json['comment'].toString(),
      // type: "berita",
      type: json['type'],
    );
  }
}
// final List<Post> posts = [
//   Post(
//       authorName: 'Sam Martin',
//       authorImageUrl:
//           'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cGVyc29ufGVufDB8MnwwfHw%3D&auto=format&fit=crop&w=500&q=60',
//       timeAgo: '5 min',
//       imageUrl:
//           'https://images.unsplash.com/photo-1649859394614-dc4f7290b7f2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
//       caption: "The best view comes after the hardest climb."),
//   Post(
//       authorName: 'Sam Martin',
//       authorImageUrl:
//           'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cGVyc29ufGVufDB8MnwwfHw%3D&auto=format&fit=crop&w=500&q=60',
//       timeAgo: '10 min',
//       imageUrl:
//           'https://images.unsplash.com/photo-1655070025742-628e20d913ba?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1169&q=80',
//       caption:
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer urna eros, dapibus id est nec, pellentesque vulputate elit. Sed efficitur elit ut justo varius pharetra. Integer gravida neque vitae egestas posuere. Ut ut varius nibh. Quisque lorem massa, lobortis ut elit egestas, rhoncus suscipit lorem. Phasellus a arcu auctor, tincidunt nibh ac, laoreet nunc. Sed non iaculis nisi. Sed ultricies dictum quam. Phasellus id blandit ex, vitae commodo ante."),
// ];

