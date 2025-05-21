// lib/routes/review_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> review;   // whole Firestore doc data
  final String reviewId;               // doc id

  const ReviewPage({
    super.key,
    required this.review,
    required this.reviewId,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _commentCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;

  late Stream<DocumentSnapshot<Map<String, dynamic>>> _likeStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _reviewStream;

  @override
  void initState() {
    super.initState();
    final uid = _auth.currentUser?.uid ?? '';
    _likeStream = FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.reviewId)
        .collection('likes')
        .doc(uid)
        .snapshots();

    _reviewStream =
        FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).snapshots();
  }

  Future<void> _toggleLike(bool liked) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final parent =
    FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId);
    final likeDoc = parent.collection('likes').doc(uid);

    if (liked) {
      await likeDoc.set({'likedAt': FieldValue.serverTimestamp()});
      await parent.update({'likesCount': FieldValue.increment(1)});
    } else {
      await likeDoc.delete();
      await parent.update({'likesCount': FieldValue.increment(-1)});
    }
  }

  Future<void> _addComment() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _commentCtrl.text.trim().isEmpty) return;

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final username = userDoc['username'] ?? 'anonymous';

    final parent =
    FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId);

    await parent.collection('comments').add({
      'uid': uid,
      'username': username,
      'text': _commentCtrl.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await parent.update({'commentsCount': FieldValue.increment(1)});

    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;

    return Scaffold(
      backgroundColor: AppColors.buttonSelected,
      appBar: AppBar(
        backgroundColor: AppColors.w_background,
        centerTitle: true,
        title: const Text(
          'Rating',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
          child: Column(
            children: [
              // HEADER ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // left side: profile + album details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // profile pic + username (aligned horizontally)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(
                                  r['profilePic'] ?? 'https://via.placeholder.com/32'),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r['username'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          r['albumName'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          r['artist'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RatingBarIndicator(
                          rating: (r['rating'] ?? 0).toDouble(),
                          itemCount: 5,
                          itemSize: 32,
                          unratedColor: AppColors.starUnrated,
                          itemBuilder: (_, __) =>
                          const Icon(Icons.star, color: Colors.amber),
                        ),
                        const SizedBox(height: 15),
                        // date + like btn + counters
                        Row(
                          children: [
                            // LIKE button (left of date)
                            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              stream: _likeStream,
                              builder: (_, likeSnap) {
                                final liked =
                                    likeSnap.hasData && likeSnap.data!.exists;
                                return GestureDetector(
                                  onTap: () => _toggleLike(!liked),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color: liked
                                            ? const Color(0xFF7CCE80)
                                            : AppColors.text,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 15),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // DATE
                            Text(
                              DateFormat('EEEE, MMM d yyyy').format(
                                  (r['listenedDate'] as Timestamp).toDate()),
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // likes / comments counters
                        const SizedBox(height: 4),
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: _reviewStream,
                          builder: (_, snap) {
                            final data = snap.data?.data() ?? r;
                            final likes = data['likesCount'] ?? 0;
                            final comments = data['commentsCount'] ?? 0;
                            return Text(
                              "$likes Likes, $comments Comments",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.16168,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // right side: album cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      r['coverUrl'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              // review text
              if ((r['comment'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.w_background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r['comment'],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // "Comments" heading
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Comments",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //  COMMENTS LIST 
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .doc(widget.reviewId)
                      .collection('comments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No comments yet',
                          style:
                          TextStyle(color: AppColors.text, fontSize: 16),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.w_background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['username'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d['text'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // ADD COMMENT ROW
              const SizedBox(height: 10), // slightly higher off the bottom
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Add a comment…',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppColors.w_background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sonique_purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
