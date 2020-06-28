import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final int likeCount;
  final String authorId;
  final Timestamp timestamp;
  final String location;
  final bool enableDownload;
  final bool delete;

  Post(
      {this.id,
      this.imageUrl,
      this.caption,
      this.likeCount,
      this.authorId,
      this.timestamp,
      this.location,
      this.enableDownload,
      this.delete});

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      id: doc.documentID,
      imageUrl: doc['imageUrl'],
      caption: doc['caption'],
      likeCount: doc['likeCount'],
      authorId: doc['authorId'],
      timestamp: doc['timestamp'],
      location: doc['location'],
      enableDownload: doc['enableDownload'],
      delete: doc['delete'],
    );
  }
}
