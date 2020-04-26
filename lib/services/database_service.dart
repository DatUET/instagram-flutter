import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_v2/models/activity_model.dart';
import 'package:instagram_v2/models/comment_model.dart';
import 'package:instagram_v2/models/message_model.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/utilities/constants.dart';

class DatabaseService {
  static void updateUser(User user) {
    usersRef.document(user.id).updateData({
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'bio': user.bio,
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) {
    Future<QuerySnapshot> users =
        usersRef.where('name', isEqualTo: name).getDocuments();
    return users;
  }

  static void createPost(Post post) {
    postsRef.document(post.authorId).collection('userPosts').add({
      'imageUrl': post.imageUrl,
      'caption': post.caption,
      'likeCount': post.likeCount,
      'authorId': post.authorId,
      'timestamp': post.timestamp,
      'location': post.location,
    });
  }

  static void followUser({String currentUserId, String userId}) {
    // Add user to current user's following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(userId)
        .setData({});
    // Add current user to user's followers collection
    followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
  }

  static void unfollowUser({String currentUserId, String userId}) {
    // Remove user from current user's following collection
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // Remove current user from user's followers collection
    followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isFollowingUser(
      {String currentUserId, String userId}) async {
    DocumentSnapshot followingDoc = await followersRef
        .document(userId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    return followingDoc.exists;
  }

  static Future<int> numFollowing(String userId) async {
    QuerySnapshot followingSnapshot = await followingRef
        .document(userId)
        .collection('userFollowing')
        .getDocuments();
    return followingSnapshot.documents.length;
  }

  static Future<int> numFollowers(String userId) async {
    QuerySnapshot followersSnapshot = await followersRef
        .document(userId)
        .collection('userFollowers')
        .getDocuments();
    return followersSnapshot.documents.length;
  }

  static Future<List<Post>> getFeedPosts(String userId) async {
    QuerySnapshot feedSnapshot = await feedsRef
        .document(userId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        feedSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await postsRef
        .document(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
        userPostsSnapshot.documents.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  static Future<User> getUserWithId(String userId) async {
    DocumentSnapshot userDocSnapshot = await usersRef.document(userId).get();
    if (userDocSnapshot.exists) {
      return User.fromDoc(userDocSnapshot);
    }
    return User();
  }

  static void likePost({String currentUserId, Post post}) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection('userPosts')
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount + 1});
      likesRef
          .document(post.id)
          .collection('postLikes')
          .document(currentUserId)
          .setData({});
      addActivityItem(currentUserId: currentUserId, post: post, comment: null);
    });
  }

  static void unlikePost({String currentUserId, Post post}) {
    DocumentReference postRef = postsRef
        .document(post.authorId)
        .collection('userPosts')
        .document(post.id);
    postRef.get().then((doc) {
      int likeCount = doc.data['likeCount'];
      postRef.updateData({'likeCount': likeCount - 1});
      likesRef
          .document(post.id)
          .collection('postLikes')
          .document(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
  }

  static Future<bool> didLikePost({String currentUserId, Post post}) async {
    DocumentSnapshot userDoc = await likesRef
        .document(post.id)
        .collection('postLikes')
        .document(currentUserId)
        .get();
    return userDoc.exists;
  }

  static void commentOnPost({String currentUserId, Post post, String comment}) {
    commentsRef.document(post.id).collection('postComments').add({
      'content': comment,
      'authorId': currentUserId,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
    addActivityItem(currentUserId: currentUserId, post: post, comment: comment);
  }

  static void addActivityItem(
      {String currentUserId, Post post, String comment}) {
    if (currentUserId != post.authorId) {
      activitiesRef.document(post.authorId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'postId': post.id,
        'postImageUrl': post.imageUrl,
        'comment': comment,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .document(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Activity> activity = userActivitiesSnapshot.documents
        .map((doc) => Activity.fromDoc(doc))
        .toList();
    return activity;
  }

  static Future<Post> getUserPost(String userId, String postId) async {
    DocumentSnapshot postDocSnapshot = await postsRef
        .document(userId)
        .collection('userPosts')
        .document(postId)
        .get();
    return Post.fromDoc(postDocSnapshot);
  }

  static Stream<List<Message>> getAllMessage(
      String fromUserId, String toUserId) async* {
    await for (QuerySnapshot snap in messageRef
        .where("groupId",
            isEqualTo: getUniqueId(
              fromUserId,
              toUserId,
            ))
        .orderBy('timestamp', descending: true)
        .snapshots()) {
      try {
        List<Message> chats =
            snap.documents.map((doc) => Message.fromMap(doc)).toList();
        yield chats;
      } catch (e) {
        print(e);
      }
    }
  }

  static Future<bool> sendMessage(Message message) async {
    try {
      String id = getUniqueId(message.senderUid, message.receiverUid);
      message.groupId = id;
      messageRef.add(message.toMap());
      await saveRecentChat(message);
      return true;
    } catch (e) {
      print("Exception $e");
      return false;
    }
  }

  static Future saveRecentChat(Message message) async {
    List<String> ids = [message.senderUid, message.receiverUid];
    for (String id in ids) {
      Query query = recentChatRef.document(id).collection("history").where(
          "groupId",
          isEqualTo: getUniqueId(message.senderUid, message.receiverUid));
      QuerySnapshot documents = await query.getDocuments();
      if (documents.documents.length != 0) {
        DocumentSnapshot documentSnapshot = documents.documents[0];
        documentSnapshot.reference.setData(message.toMap());
      } else {
        recentChatRef.document(id).collection("history").add(message.toMap());
      }
    }
  }

  static Stream<List<Message>> getAllRecentChat(String userId) async* {
    await for (QuerySnapshot snap in recentChatRef
        .document(userId)
        .collection("history")
        .orderBy('timestamp', descending: true)
        .snapshots()) {
      try {
        List<Message> recentChats =
            snap.documents.map((doc) => Message.fromMap(doc)).toList();
        yield recentChats;
      } catch (e) {
        print(e);
      }
    }
  }

  static Future<void> updateIsSeen(
      String currentUserId, String chatWithUserId) async {
    QuerySnapshot recentChatQuery = await recentChatRef
        .document(currentUserId)
        .collection('history')
        .where('groupId', isEqualTo: getUniqueId(currentUserId, chatWithUserId))
        .getDocuments();
    if (recentChatQuery.documents.length != 0) {
      String docId = recentChatQuery.documents[0].documentID;
      await recentChatRef
          .document(currentUserId)
          .collection('history')
          .document(docId)
          .updateData({'isSeen': true});
    }
  }

  static Future<void> deleteMessage(
      String messageId, String currentUserId, String chatWithUserId) async {
    QuerySnapshot deleteMessageSnapshot =
        await messageRef.where('id', isEqualTo: messageId).getDocuments();
    if (deleteMessageSnapshot.documents.isNotEmpty) {
      String docId = deleteMessageSnapshot.documents[0].documentID;
      await messageRef.document(docId).updateData({
        'message': 'This message was deleted',
        'type': 'delete',
        'photoUrl': ''
      });
    }
    deleteRecentChat(messageId, currentUserId, chatWithUserId);
  }

  static Future<void> deleteRecentChat(
      String messageId, String currentUserId, String chatWithUserId) async {
    List<String> ids = [currentUserId, chatWithUserId];
    for (String id in ids) {
      QuerySnapshot recentChatQuery = await recentChatRef
          .document(id)
          .collection('history')
          .where('id', isEqualTo: messageId)
          .getDocuments();
      if (recentChatQuery.documents.length != 0) {
        String docId = recentChatQuery.documents[0].documentID;
        await recentChatRef
            .document(id)
            .collection('history')
            .document(docId)
            .updateData({
          'message': 'This message was deleted',
          'type': 'delete',
          'photoUrl': ''
        });
      }
    }
  }

  static String getUniqueId(String i1, String i2) {
    if (i1.compareTo(i2) <= -1) {
      return i1 + i2;
    } else {
      return i2 + i1;
    }
  }

  static Future<void> updateToken(String currentUserId, String token) async {
    await tokenRef.document(currentUserId).setData({currentUserId: token});
  }

  static void updateActive(String userId, bool isActive) {
    usersRef.document(userId).updateData({
      'isActive': isActive,
    });
  }

  static Future<bool> checkIsSeenAll(String userId) async {
    QuerySnapshot checkIsSeenAllSnapshot = await recentChatRef
        .document(userId)
        .collection('history')
        .where('isSeen', isEqualTo: false)
        .where('receiverUid', isEqualTo: userId)
        .getDocuments();
    print(checkIsSeenAllSnapshot.documents.isEmpty);
    return checkIsSeenAllSnapshot.documents.isNotEmpty;
  }
}
