import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/colors.dart';
import 'review_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// signed-in user
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Stream
  Stream<QuerySnapshot<Map<String, dynamic>>> _popularStream =
      const Stream.empty();

  Stream<QuerySnapshot<Map<String, dynamic>>> _friendsStream =
      const Stream.empty();

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  Future<void> _initStreams() async {
    // POPULAR THIS WEEK
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    _popularStream =
        FirebaseFirestore.instance
            .collection('reviews')
            .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
            .where('isDeleted', isEqualTo: false)
            .snapshots();

    //  FRIENDS STREAM
    final userRef = FirebaseFirestore.instance.collection('users').doc(_uid);

    //   try array field first
    final userSnap = await userRef.get();
    List<String> friendIds = [];
    final data = userSnap.data();
    if (data?['following'] is List) {
      friendIds = List<String>.from(data!['following']);
    }

    //   if array absent, read sub-collection /following
    if (friendIds.isEmpty) {
      final sub = await userRef.collection('following').get();
      friendIds = sub.docs.map((d) => d.id).toList();
    }

    if (friendIds.isEmpty) {
      // point at a query that is guaranteed to return **0 docs**
      _friendsStream =
          FirebaseFirestore.instance
              .collection('reviews')
              .where('userId', isEqualTo: '__none__') // dummy value
              .limit(1)
              .snapshots();
    } else {
      _friendsStream =
          FirebaseFirestore.instance
              .collection('reviews')
              .where('userId', whereIn: friendIds.take(10).toList())
              .where('isDeleted', isEqualTo: false)
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots();
    }

    setState(() {}); // rebuild UI with the real stream
  }

  //  Widgets

  Widget _albumTile(Map<String, dynamic> r) {
    final String raw = r['albumName'] ?? '';
    final String name = raw.length > 12 ? '${raw.substring(0, 12)}…' : raw;

    return SizedBox(
      width: 130,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              r['coverUrl'],
              width: 130,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.clip, // no second line ever
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.16168,
            ),
          ),
          Text(
            r['artist'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.16168,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewBox({required Map<String, dynamic> r, required String docId}) {
    return GestureDetector(
      onTap: () => _openReview(r, docId, false),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF151618),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // album header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title / artist / stars
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['albumName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.16168,
                        ),
                      ),
                      Text(
                        r['artist'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.16168,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            Icons.star,
                            size: 18,
                            color:
                                i < (r['rating'] as num).round()
                                    ? const Color(0xFFD7CE7C)
                                    : Colors.white,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                // cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    r['coverUrl'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // review text (max 100 chars)
            Text(
              r['comment'] ?? '',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.16168,
              ),
            ),
            const SizedBox(height: 16),

            // profile
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(
                    r['profilePic'] ?? 'https://via.placeholder.com/28',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  r['username'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.16168,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // like / comment buttons
            Row(
              children: [
                /// LIKE
                StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('reviews')
                          .doc(docId)
                          .collection('likes')
                          .doc(_uid)
                          .snapshots(),
                  builder: (_, snap) {
                    final liked = snap.hasData && snap.data!.exists;
                    return GestureDetector(
                      onTap: () => _toggleLike(docId, !liked),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color:
                                liked ? const Color(0xFF7CCE80) : Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                    );
                  },
                ),

                /// COMMENT
                GestureDetector(
                  onTap: () => _openReview(r, docId, true), // focus keyboard
                  child: const Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 15),

                /// counters (live)
                StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('reviews')
                          .doc(docId)
                          .snapshots(),
                  builder: (_, s) {
                    final Map<String, dynamic> data =
                        (s.data?.data() as Map<String, dynamic>?) ?? r;
                    final likes = data['likesCount'] ?? 0;
                    final cmt = data['commentsCount'] ?? 0;
                    return Text(
                      "$likes Likes, $cmt Comments",
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
          ],
        ),
      ),
    );
  }

  void _toggleLike(String docId, bool like) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    final parent = FirebaseFirestore.instance.collection('reviews').doc(docId);
    final likeDoc = parent.collection('likes').doc(uid);

    if (like) {
      await likeDoc.set({'likedAt': FieldValue.serverTimestamp()});
      await parent.update({'likesCount': FieldValue.increment(1)});
    } else {
      await likeDoc.delete();
      await parent.update({'likesCount': FieldValue.increment(-1)});
    }
  }

  void _openReview(
    Map<String, dynamic> review,
    String docId,
    bool startWithKeyboard,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ReviewPage(
              review: review,
              reviewId: docId,
              startWithKeyboard: startWithKeyboard,
            ),
      ),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonSelected,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header (logo centred vertically now) ──
            Container(
              width: double.infinity,
              color: AppColors.w_background,
              padding: const EdgeInsets.only(top: 70, bottom: 25),
              child: Center(
                child: SvgPicture.asset(
                  'assets/sonique.svg',
                  width: 155,
                  height: 22,
                ),
              ),
            ),

            // Popular this week
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Popular This Week',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _popularStream,
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 130,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                // group by albumId -> count
                final docs = snap.data!.docs;
                final Map<String, Map<String, dynamic>> byAlbum = {};
                for (var d in docs) {
                  final data = d.data();
                  final aid = data['albumId'];
                  byAlbum.putIfAbsent(aid, () => {...data, 'count': 0});
                  byAlbum[aid]!['count'] += 1;
                }
                final list =
                    byAlbum.values.toList()..sort((a, b) {
                      final c = (b['count'] as int).compareTo(a['count']);
                      if (c != 0) return c;
                      return (b['createdAt'] as Timestamp).compareTo(
                        a['createdAt'],
                      );
                    });
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (int i = 0; i < list.length; i++) ...[
                        _albumTile(list[i]),
                        if (i != list.length - 1) const SizedBox(width: 17),
                      ],
                    ],
                  ),
                );
              },
            ),

            //  From friends
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 12),
              child: Text(
                'From Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 15),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _friendsStream,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // after first event we are here – even if 0 docs
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Your friends have not reviewed anything yet.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final d in docs) ...[
                      _reviewBox(r: d.data(), docId: d.id),
                      const SizedBox(height: 15),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 70), // bottom padding
          ],
        ),
      ),
    );
  }
}
