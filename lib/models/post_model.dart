import 'message_model.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String userId;
  final String username;
  int likes;
  List<String> likedUsers;
  int views;
  List<String> viewedUsers;

  final String imageUrl;
  final bool isPublic;
  final bool isMe;
  List<Message> comments;
  final DateTime createdAt;

  Post({
    this.isMe = false,
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.username,
    required this.likes,
    required this.likedUsers,
    required this.views,
    required this.viewedUsers,
    required this.imageUrl,
    required this.isPublic,
    required this.createdAt,
    required this.comments,
  });

  factory Post.fromJson(Map<String, Object?> json, {bool isMe = false}) {
    return Post(
      id: json["id"] as String,
      title: json["title"] as String,
      content: json["content"] as String,
      userId: json["userId"] as String,
      username: json["username"] as String,
      likes: json["likes"] as int,
      likedUsers: json["likedUsers"] != null
          ? (json["likedUsers"] as List).map((e) => e as String).toList()
          : [],
      views: json["views"] as int,
      viewedUsers: json["viewedUsers"] != null
          ? (json["viewedUsers"] as List).map((e) => e as String).toList()
          : [],
      imageUrl: json["imageUrl"] as String,
      isPublic: json["isPublic"] as bool,
      createdAt: DateTime.parse(json["createdAt"] as String),
      isMe: isMe,
      comments: json["comments"] != null
          ? (json["comments"] as List)
              .map((item) => Message.fromJson(item as Map<String, Object?>))
              .toList()
          : [],
    );
  }

  Map<String, Object?> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "userId": userId,
        "username": username,
        "likes": likes,
        "likedUsers": likedUsers,
        "views": views,
        "viewedUsers": viewedUsers,
        "imageUrl": imageUrl,
        "isPublic": isPublic,
        "comments": comments.map((e) => e.toJson()).toList(),
        "createdAt": createdAt.toIso8601String()
      };
}
