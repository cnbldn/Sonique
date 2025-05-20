import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sonique/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sonique/services/firestore_service.dart';


class Profile extends StatefulWidget {
  final String uid;

  const Profile({Key? key, required this.uid}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 0;
  String? _userLink;
  final TextEditingController _linkController = TextEditingController();
  Map<String, dynamic>? _userData;
  bool _isFollowing = false;
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;


  void _showLinkDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.dialogBoxBackground,
          title: Text("Enter your link", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _linkController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "https://linksomethingidk.com",
              hintStyle: TextStyle(color: AppColors.text),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: AppColors.text)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userLink = _linkController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text("Save", style: TextStyle(color: AppColors.linkBlue)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkIfFollowing();
  }

  Future<void> _fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (doc.exists) {
      setState(() {
        _userData = doc.data();
      });
    }
  }

  Future<void> _checkIfFollowing() async {
    if (_currentUid == widget.uid) return;
    final result = await FirestoreService().isFollowing(widget.uid, _currentUid);
    setState(() {
      _isFollowing = result;
    });
  }

  void _toggleFollow() async {
    final firestore = FirebaseFirestore.instance;
    final currentUserRef = firestore.collection('users').doc(_currentUid);
    final targetUserRef = firestore.collection('users').doc(widget.uid);

    final followingRef = currentUserRef.collection('following').doc(widget.uid);
    final followerRef = targetUserRef.collection('followers').doc(_currentUid);

    final batch = firestore.batch();

    if (_isFollowing) {
      // Unfollow
      batch.delete(followingRef);
      batch.delete(followerRef);

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(-1),
      });
      batch.update(targetUserRef, {
        'followersCount': FieldValue.increment(-1),
      });
    } else {
      // Follow
      batch.set(followingRef, {'followedAt': FieldValue.serverTimestamp()});
      batch.set(followerRef, {'followedAt': FieldValue.serverTimestamp()});

      batch.update(currentUserRef, {
        'followingCount': FieldValue.increment(1),
      });
      batch.update(targetUserRef, {
        'followersCount': FieldValue.increment(1),
      });
    }

    await batch.commit();

    setState(() {
      _isFollowing = !_isFollowing;
    });

    _fetchUserData();
  }



  Widget build(BuildContext context) {
    final BorderRadiusGeometry homeButtonRadius =
    _selectedIndex == 0
        ? BorderRadius.circular(6) // Fully rounded when selected
        : BorderRadius.only(
      topLeft: Radius.circular(6),
      bottomLeft: Radius.circular(6),
    );

    final BorderRadiusGeometry ratingsButtonRadius =
    _selectedIndex == 1
        ? BorderRadius.circular(6)
        : BorderRadius.only(
      topRight: Radius.circular(6),
      bottomRight: Radius.circular(6),
    );

    return Scaffold(
      body: Container(
        color: AppColors.cardBackground,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),


                    Center(
                      child: Text(
                        _userData?['username'] ?? 'username',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 33),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 39.5,
                          backgroundImage: _userData?['photoUrl'] != null
                              ? NetworkImage(_userData!['photoUrl'])
                              : AssetImage('assets/default_pfp.jpg') as ImageProvider,
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              "24",
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Ratings",
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              (_userData?['followersCount'] ?? 0).toString(),
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Followers",
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              (_userData?['followingCount'] ?? 0).toString(),
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Following",
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      _userData?['displayName'] ?? 'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      _userData?['bio'] ?? 'No bio',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 9),
                    GestureDetector(
                      onTap: () {
                        if (_userLink != null) {
                          launchUrl(
                            Uri.parse(_userLink!),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          _showLinkDialog();
                        }
                      },
                      child: Row(
                        children: [
                          Transform.rotate(
                            angle: -45,
                            child: Icon(
                              Icons.link,
                              color: AppColors.linkBlue,
                              size: 18,
                            ),
                          ),
                          Text(
                            _userLink ?? "Add Link...",
                            style: TextStyle(
                              color: AppColors.linkBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              decoration:
                              _userLink != null
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),

              if (_currentUid != widget.uid)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing ? Colors.grey[700] : AppColors.button,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size(double.infinity, 36),
                    ),
                    child: Text(
                      _isFollowing ? "Following" : "Follow",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            _selectedIndex == 0
                                ? AppColors.buttonSelected
                                : AppColors.button,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: homeButtonRadius,
                            ),
                          ),
                          child: Text(
                            "Home",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            _selectedIndex == 0
                                ? AppColors.button
                                : AppColors.buttonSelected,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: ratingsButtonRadius,
                            ),
                          ),
                          child: Text(
                            "Ratings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 21),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    HomePageView(), // <- Replace with your actual home content widget
                    RatingsPageView(), // <- Replace with your actual ratings content widget
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> favoriteAlbums = [
      {
        "title": "Goodbye Yellow Brick Road",
        "artist": "Elton John",
        "image": "assets/goodbye_yellow_brick_road.jpg",
      },
      {"title": "brat", "artist": "Charli xcx", "image": "assets/brat.png"},
      {"title": "Dummy", "artist": "Portishead", "image": "assets/dummy.jpg"},
      {
        "title": "Underground",
        "artist": "Thelonious Monk",
        "image": "assets/underground.png",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.buttonSelected,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17.0),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Favorite Albums",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 177,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favoriteAlbums.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 17),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  favoriteAlbums[index]["image"]!,
                                  height: 110,
                                  width: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 11),
                              SizedBox(
                                width: 110,
                                child: Text(
                                  favoriteAlbums[index]["title"]!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  favoriteAlbums[index]["artist"]!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            Expanded(
              child: Container(
                color: AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "When The Pawn...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Fiona Apple",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            RatingBarIndicator(
                              rating: 5,
                              itemBuilder:
                                  (context, index) =>
                                  Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 18,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/when_the_pawn.jpg',
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingsPageView extends StatefulWidget {
  @override
  State<RatingsPageView> createState() => _RatingsPageViewState();
}

class _RatingsPageViewState extends State<RatingsPageView> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> ratedAlbums = [
    {
      "title": "When The Pawn...",
      "artist": "Fiona Apple",
      "image": "assets/when_the_pawn.jpg",
      "rating": 5.0,
    },
    {
      "title": "brat",
      "artist": "Charli XCX",
      "image": "assets/brat.png",
      "rating": 5.0,
    },
    {
      "title": "Dummy",
      "artist": "Portishead",
      "image": "assets/dummy.jpg",
      "rating": 4.5,
    },
    {
      "title": "Underground",
      "artist": "Thelonious Monk",
      "image": "assets/underground.png",
      "rating": 4.0,
    },
    {
      "title": "Goodbye Yellow Brick Road",
      "artist": "Elton John",
      "image": "assets/goodbye_yellow_brick_road.jpg",
      "rating": 5.0,
    },
  ];

  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredAlbums {
    if (_searchQuery.isEmpty) return ratedAlbums;
    return ratedAlbums.where((album) {
      final title = album['title']!.toLowerCase();
      final artist = album['artist']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonSelected,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              SizedBox(height: 25),
              Container(
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12.5),
                    Icon(Icons.search, color: AppColors.text, size: 21),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search in ratings...",
                          hintStyle: TextStyle(color: AppColors.text),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Expanded(
                child: GridView.builder(
                  itemCount: _filteredAlbums.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.71,
                  ),
                  itemBuilder: (context, index) {
                    final album = _filteredAlbums[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            album["image"]!,
                            height: 183,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 16),
                        RatingBarIndicator(
                          rating: album["rating"]!,
                          itemBuilder:
                              (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 18,
                          direction: Axis.horizontal,
                        ),
                        Text(
                          album["title"]!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          album["artist"]!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
