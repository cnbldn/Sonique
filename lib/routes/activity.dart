import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sonique/routes/review_page.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  int _selectedIndex = 0;

  String _fmt(Timestamp ts) {
    final d = DateTime.now().difference(ts.toDate());
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return 'now';
  }

  Widget _img(
    String path, {
    double? w,
    double? h,
    double r = 0,
    BoxFit fit = BoxFit.cover,
  }) {
    final i =
        path.startsWith('http')
            ? Image.network(path, width: w, height: h, fit: fit)
            : Image.asset(path, width: w, height: h, fit: fit);
    return ClipRRect(borderRadius: BorderRadius.circular(r), child: i);
  }

  // Add this to your _ActivityState class
  Stream<QuerySnapshot>? _friendsReviewsStream;

  @override
  void initState() {
    super.initState();
    _initFriendsStream();
  }

  Future<void> _initFriendsStream() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get list of friend IDs
    final following =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('following')
            .get();

    final friendIds = following.docs.map((doc) => doc.id).toList();

    if (friendIds.isEmpty) {
      // Return empty stream if no friends
      _friendsReviewsStream = Stream.empty();
    } else {
      _friendsReviewsStream =
          FirebaseFirestore.instance
              .collection('reviews')
              .where('userId', whereIn: friendIds)
              .where('isDeleted', isNotEqualTo: true)
              .orderBy('createdAt', descending: true)
              .snapshots();
    }

    setState(() {});
  }

  Widget _friendsTab() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Expanded(
        child: Center(
          child: Text(
            'Not signed in',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _friendsReviewsStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No activity from friends yet',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: docs.length,
            separatorBuilder:
                (_, __) => const Divider(height: 1, color: Color(0xFF0E0F11)),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewPage(review: d, reviewId: doc.id),
                    ),
                  );
                },
                child: _rateCard(
                  docId: doc.id,
                  canDelete: false, // Friends' reviews can't be deleted by you
                  username: d['username'] ?? 'User',
                  album: d['albumName'] ?? '',
                  artist: d['artist'] ?? '',
                  rating: (d['rating'] ?? 0).toDouble(),
                  comment: d['comment'] ?? '',
                  coverUrl: d['coverUrl'] ?? 'assets/placeholder_album.png',
                  profilePic: d['profilePic'] ?? 'assets/default_pfp.png',
                  timeAgo:
                      d['createdAt'] is Timestamp ? _fmt(d['createdAt']) : '',
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _youTab() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Expanded(
        child: Center(
          child: Text(
            'Not signed in',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('reviews')
                .where('userId', isEqualTo: uid)
                .where('isDeleted', isNotEqualTo: true)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Your activity will show up here',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: docs.length,
            separatorBuilder:
                (_, __) => const Divider(height: 1, color: Color(0xFF0E0F11)),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ReviewPage(
                            review:
                                d, // the map of fields you passed in _rateCard
                            reviewId: doc.id, // the document ID
                          ),
                    ),
                  );
                },
                child: _rateCard(
                  docId: doc.id,
                  canDelete: d['userId'] == uid,
                  username: d['username'] ?? 'You',
                  album: d['albumName'] ?? '',
                  artist: d['artist'] ?? '',
                  rating: (d['rating'] ?? 0).toDouble(),
                  comment: d['comment'] ?? '',
                  coverUrl: d['coverUrl'] ?? 'assets/placeholder_album.png',
                  profilePic: d['profilePic'] ?? 'assets/default_pfp.png',
                  timeAgo:
                      d['createdAt'] is Timestamp ? _fmt(d['createdAt']) : '',
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _rateCard({
    required String docId,
    required bool canDelete,
    required String username,
    required String album,
    required String artist,
    required double rating,
    required String comment,
    required String coverUrl,
    required String profilePic,
    required String timeAgo,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF242527),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _img(profilePic, w: 28, h: 28, r: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "$username ",
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                      const TextSpan(
                        text: "rated",
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: () async {
                    final yes = await showDialog<bool>(
                      context: context,
                      builder:
                          (c) => AlertDialog(
                            backgroundColor: const Color(0xFF181A1C),
                            title: const Text(
                              'Delete review?',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'This will hide your review from others',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.pop(c, false),
                              ),
                              TextButton(
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () => Navigator.pop(c, true),
                              ),
                            ],
                          ),
                    );

                    if (yes == true) {
                      try {
                        final uid = FirebaseAuth.instance.currentUser?.uid;

                        // Update main reviews collection
                        await FirebaseFirestore.instance
                            .collection('reviews')
                            .doc(docId)
                            .update({'isDeleted': true});

                        // Update user's reviews subcollection
                        if (uid != null) {
                          print(
                            'Attempting to update user review: users/$uid/reviews/$docId',
                          );

                          // Check if the document exists first
                          final userReviewDoc =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('reviews')
                                  .doc(docId)
                                  .get();

                          if (userReviewDoc.exists) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('reviews')
                                .doc(docId)
                                .update({'isDeleted': true});
                            print('Successfully updated user review');
                          } else {
                            print('User review document does not exist');
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to delete review: ${e.toString()}',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: _img('assets/delete.png', w: 12, h: 14),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star,
                          size: 18,
                          color:
                              i < rating.round()
                                  ? const Color(0xFFD7CE7C)
                                  : const Color(0xFFD9D9D9),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _img(coverUrl, w: 70, h: 70, r: 10),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              timeAgo,
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    final friendsOn = _selectedIndex == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF0E0F11),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _selectedIndex = 0),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  backgroundColor:
                      friendsOn ? const Color(0xFF242527) : Colors.transparent,
                ),
                child: const Text(
                  'Friends',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                style: TextButton.styleFrom(
                  backgroundColor:
                      !friendsOn ? const Color(0xFF242527) : Colors.transparent,
                ),
                child: const Text(
                  'You',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 131,
            color: const Color(0xFF181A1C),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _tabs(),
              ],
            ),
          ),
          _selectedIndex == 0 ? _friendsTab() : _youTab(),
        ],
      ),
    );
  }
}
