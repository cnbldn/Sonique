import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> postReview({
    required String uid,
    required String username,
    required String albumId,
    required String albumName,
    required double rating,
    required String comment,
    required DateTime listenedDate,
    required bool isRelisten,
    required String coverUrl,
    required String artist
  }) async {
    final _db = FirebaseFirestore.instance;

    final reviewId = _db.collection('reviews').doc().id; // 🔥 generate once

    final reviewData = {
      'id': reviewId, // optional: store the ID in the data
      'userId': uid,
      'username': username,
      'albumId': albumId,
      'albumName': albumName,
      'rating': rating,
      'comment': comment,
      'listenedDate': listenedDate,
      'isRelisten': isRelisten,
      'coverUrl': coverUrl,
      'artist': artist,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount'   : 0,
      'commentsCount': 0,
    };

    final batch = _db.batch();

    final userReviewRef = _db
        .collection('users')
        .doc(uid)
        .collection('reviews')
        .doc(reviewId);

    final globalReviewRef = _db
        .collection('reviews')
        .doc(reviewId);

    batch.set(userReviewRef, reviewData);
    batch.set(globalReviewRef, reviewData);

    await batch.commit();
  }

  Future<void> followUser(String currentUid, String targetUid) async{
    final batch = _db.batch();

    final followingRef = _db
      .collection('users')
      .doc(currentUid)
      .collection('following')
      .doc(targetUid);

    final followerRef = _db
      .collection('users')
      .doc(targetUid)
      .collection('followers')
      .doc(currentUid);

    batch.set(followingRef, {'followedAt': FieldValue.serverTimestamp()});
    batch.set(followerRef, {'followedAt': FieldValue.serverTimestamp()});

    batch.update(_db.collection('users').doc(currentUid),{
      'followingCount': FieldValue.increment(1),
    });
    batch.update(_db.collection('users').doc(targetUid),{
      'followersCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async{
    final batch = _db.batch();

    final followingRef = _db
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);

    final followerRef = _db
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(currentUid);

    batch.delete(followingRef);
    batch.delete(followerRef);

    batch.update(_db.collection('users').doc(currentUid),{
      'followingCount': FieldValue.increment(-1),
    });
    batch.update(_db.collection('users').doc(targetUid),{
      'followersCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Future<bool> isFollowing(String targetUid, String currentUid) async{
    final doc = await _db
      .collection('users')
      .doc(currentUid)
      .collection('following')
      .doc(targetUid)
      .get();

    return doc.exists;
  }

}