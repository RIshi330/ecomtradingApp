class Comment {
  final String username;
  final String userImage;
  final String text;
  final String timeAgo;
  int likes;

  Comment({
    required this.username,
    required this.userImage,
    required this.text,
    required this.timeAgo,
    required this.likes,
  });
}

class Post {
  final String id;
  final String username;
  final String userImage;
  final List<String> postImages;
  int likes;
  final String caption;
  final String timeAgo;
  int comments;
  final int shares;
  final List<Comment> commentsList;
  bool isLiked;
  bool isBookmarked;

  Post({
    required this.id,
    required this.username,
    required this.userImage,
    required this.postImages,
    required this.likes,
    required this.caption,
    required this.timeAgo,
    required this.comments,
    required this.shares,
    required this.commentsList,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  void addComment(Comment comment) {
    commentsList.add(comment);
  }
}

List<Post> globalPosts = [];
