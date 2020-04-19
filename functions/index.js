const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onFollowUser = functions.region("asia-northeast1").firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onCreate(async (snapshot, context) => {
    console.log(snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const followedUserPostsRef = admin
      .firestore()
      .collection('posts')
      .doc(userId)
      .collection('userPosts');
    const userFeedRef = admin
      .firestore()
      .collection('feeds')
      .doc(followerId)
      .collection('userFeed');
    const followedUserPostsSnapshot = await followedUserPostsRef.get();
    followedUserPostsSnapshot.forEach(doc => {
      if (doc.exists) {
        userFeedRef.doc(doc.id).set(doc.data());
      }
    });
  });

exports.onUnfollowUser = functions.region("asia-northeast1").firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const userFeedRef = admin
      .firestore()
      .collection('feeds')
      .doc(followerId)
      .collection('userFeed')
      .where('authorId', '==', userId);
    const userPostsSnapshot = await userFeedRef.get();
    userPostsSnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

exports.onUploadPost = functions.region("asia-northeast1").firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onCreate(async (snapshot, context) => {
    console.log(snapshot.data());
    const userId = context.params.userId;
    const postId = context.params.postId;
    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach(doc => {
      admin
        .firestore()
        .collection('feeds')
        .doc(doc.id)
        .collection('userFeed')
        .doc(postId)
        .set(snapshot.data());
    });
  });

exports.onUpdatePost = functions.region("asia-northeast1").firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onUpdate(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;
    const newPostData = snapshot.after.data();
    console.log(newPostData);
    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach(async userDoc => {
      const postRef = admin
        .firestore()
        .collection('feeds')
        .doc(userDoc.id)
        .collection('userFeed');
      const postDoc = await postRef.doc(postId).get();
      if (postDoc.exists) {
        postDoc.ref.update(newPostData);
      }
    });
  });

exports.sendNotification = functions.region("asia-northeast1").firestore
  .document('/message/{messageId}')
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();
    const senderUid = messageData['senderUid'];
    const receiverUid = messageData['receiverUid'];
    const message = messageData['message'];
    var senderName;
    const userRef = admin
      .firestore()
      .collection("users");
    const userDoc = await userRef.doc(senderUid).get();
    if (userDoc.exists) {
      senderName = userDoc.get("name");
      console.log(senderName);
    }
    var token;
    const tokenRef = admin
      .firestore()
      .collection("tokens");
      const tokenDoc = await tokenRef.doc(receiverUid).get();
    if (tokenDoc.exists) {
      token = tokenDoc.get(receiverUid);
      console.log(token);
    }
    const payload = {
      notification: {
          title: senderName + " sent you a message.",
          body: message,
          clickAction: "FLUTTER_NOTIFICATION_CLICK"
      },
      data: {
        senderUid: senderUid,
          receiverUid: receiverUid
      }
  }
  return admin.messaging().sendToDevice(token, payload);
  });

exports.sendNotifiActivities = functions.region("asia-northeast1").firestore
  .document("activities/{userId}/userActivities/{activityId}")
  .onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const activity = snapshot.data();
    const fromUserId = activity["fromUserId"];
    var fromUserName;
    const userRef = admin
      .firestore()
      .collection("users");
    const userDoc = await userRef.doc(fromUserId).get();
    if (userDoc.exists) {
      fromUserName = userDoc.get("name");
      console.log(fromUserName);
    }
    var token;
    const tokenRef = admin
      .firestore()
      .collection("tokens");
    const tokenDoc = await tokenRef.doc(userId).get();
    if (tokenDoc.exists) {
      token = tokenDoc.get(userId);
      console.log(token);
    }
    var action = activity["comment"] === null ? " like" : " comment";
    const payload = {
      notification: {
          title: fromUserName + action + " your post" ,
          body: "Click to see",
          clickAction: "FLUTTER_NOTIFICATION_CLICK"
      },
      data: {
          postId: activity['postId']
      }
  }
  return admin.messaging().sendToDevice(token, payload);
  });