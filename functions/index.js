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
    admin.firestore().collection('trendingLike').doc(postId).set(snapshot.data())
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
    const trendingLikeRef = admin
        .firestore()
        .collection('trendingLike')
      const trendingLikeDoc = await trendingLikeRef.doc(postId).get();
      if (trendingLikeDoc.exists) {
        trendingLikeDoc.ref.update(newPostData);
      }
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
      avatar = userDoc.get("profileImageUrl");
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
          image: avatar,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
        type: 'chat',
        senderUid: senderUid,
        receiverUid: receiverUid
      }
  }
  if (token !== '') {
    return admin.messaging().sendToDevice(token, payload);
  }
  return;
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
    var postImage = activity["postImageUrl"];
    const payload = {
      notification: {
          title: fromUserName + action + " your post" ,
          body: "Click to see",
          image: postImage,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
          type:'post',
          postId: activity['postId'],
      }
  }
  if (token !== '') {
    return admin.messaging().sendToDevice(token, payload);
  }
  return;
  });

exports.sendNotifiVideoCall = functions.region("asia-northeast1").firestore
  .document("/call/{userId}")
  .onCreate(async (snapshot, context) => {
    const call = snapshot.data();
    var receiverUid;
    if (call['callerId'] === context.params.userId && call['hasDialled']) {
      receiverUid = call['receiverId'];
    }
    const callerName = call['callerName'];
    var token;
    const avatar = call['callerPic'];
    const type = call['type'] + ' Call';
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
          title: callerName + " is calling you.",
          body: 'Click to answer',
          image: avatar,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      data: {
        type: type,
      }
  }
  if (token !== '') {
    return admin.messaging().sendToDevice(token, payload);
  }
  return;
  });

exports.onUpdateLocation = functions.region("asia-northeast1").firestore
.document("/location/{userId}")
.onUpdate(async (snapshot, context) => {
  const location = snapshot.after.data();
  const userID = context.params.userId;
  const distanceRef = admin
    .firestore()
    .collection('distance')
    .doc(userID)
    .collection('userDistances');
  const locationRef = admin
  .firestore()
  .collection('location');
  const loactionSnapshot = await locationRef.get();
  loactionSnapshot.forEach(async (doc) => {
    const locationOther = doc.data();
      const latitude1 = location['latitude'];
      const latitude2 = locationOther['latitude'];
      const longitude1 = location['longitude'];
      const longitude2 = locationOther['longitude'];
      const distance = calculateDistance(latitude1, longitude1, latitude2, longitude2);
    if (doc.exists) {
      if (doc.id !== userID) {
        if (!distanceRef.doc(doc.id).exists) {
          const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(doc.id).get();
          distanceRef.doc(doc.id).set({
            'name': userDoc.get('name'),
            'bio': userDoc.get('bio'),
            'email': userDoc.get('email'),
            'profileImageUrl': userDoc.get('profileImageUrl'),
            'isActive': userDoc.get('isActive'),
            'type': userDoc.get('type'),
            'distance': distance,
          });
        } else {
          distanceRef.doc(doc.id).update({
            'distance': distance,
          });
        }
      }
    }
  });
});

function calculateDistance(lat1, lon1, lat2, lon2){
  var p = 0.017453292519943295;
  var a = 0.5 - Math.cos((lat2 - lat1) * p)/2 +
  Math.cos(lat1 * p) * Math.cos(lat2 * p) *
  (1 - Math.cos((lon2 - lon1) * p))/2;
  return 12742 * Math.asin(Math.sqrt(a));
  }