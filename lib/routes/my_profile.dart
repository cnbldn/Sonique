import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonique/routes/review_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sonique/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sonique/routes/welcome.dart';

class myProfile extends StatefulWidget {
  const myProfile({super.key});

  @override
  State<myProfile> createState() => _myProfileState();
}

class _myProfileState extends State<myProfile> {
  int _selectedIndex = 0;
  String? _userLink;
  final TextEditingController _linkController = TextEditingController();

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

  String? _username;
  String? _displayName;
  String? _bio;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  String? _profilePicUrl;
  int _followersCount = 0;
  int _followingCount = 0;
  int _ratingsCount = 0;

  Future<void> pickAndLoadImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && uid != null) {
      final file = pickedFile.readAsBytes();
      final ref = FirebaseStorage.instance.ref().child('profile_pics/$uid.jpg');

      await ref.putData(await file);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePic': downloadUrl,
      });

      setState(() {
        _profilePicUrl = downloadUrl;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();

      final reviewsQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('reviews')
              .where('isDeleted', isNotEqualTo: true) // Add this filter
              .get();

      setState(() {
        _username = data?['username'] ?? "User";
        _displayName = data?['displayName'] ?? _username;
        _bio = data?['bio'] ?? "Hey, I'm a Sonique user!";
        _profilePicUrl = data?['profilePic'];
        _followersCount = (data?['followersCount'] ?? 0);
        _followingCount = (data?['followingCount'] ?? 0);
        _ratingsCount =
            reviewsQuery.size; // This will now only count non-deleted reviews
        _isLoading = false;
      });
    }
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40), // spacer to balance layout

                        Text(
                          _isLoading ? "Loading..." : "$_username",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),

                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => Welcome()),
                                (route) => false,
                              );
                            }
                          },
                          color: AppColors.cardBackground,
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          itemBuilder:
                              (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'logout',
                                  child: Text(
                                    'Log out',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),

                    SizedBox(height: 33),
                    Row(
                      children: [
                        Container(
                          width: 79,
                          height: 79,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 39.5,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                _profilePicUrl != null
                                    ? NetworkImage(_profilePicUrl!)
                                    : AssetImage('assets/default_pfp.png')
                                        as ImageProvider,
                          ),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            Text(
                              _isLoading ? "" : _ratingsCount.toString(),
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
                              _followersCount.toString(),
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
                              _followingCount.toString(),
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
                      _isLoading ? "" : _displayName ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      _isLoading ? "" : _bio ?? "",
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
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          print(
                            "have not implemented the edit profile page yet",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.button,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
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
                  children: [HomePageView(), RatingsPageView()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageView extends StatefulWidget {
  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  List<Map<String, dynamic>> _recentReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentReviews();
  }

  Future<void> _fetchRecentReviews() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('reviews')
            .where('isDeleted', isNotEqualTo: true) // Add this filter
            .orderBy('listenedDate', descending: true)
            .limit(3)
            .get();

    final reviews =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "docId": doc.id,
            "data": data,
            "title": data['albumName'] ?? '',
            "artist": data['artist'] ?? '',
            "image": data['coverUrl'] ?? '',
            "rating": data['rating']?.toDouble() ?? 0.0,
          };
        }).toList();

    setState(() {
      _recentReviews = reviews;
      _isLoading = false;
    });
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17.0),
          child: Column(
            children: [
              Column(
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
                    child: Card(
                      color: AppColors.buttonSelected,
                      shadowColor: Color(0x00000000),
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
                  ),
                ],
              ),
              SizedBox(height: 22),
              Align(
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
              SizedBox(height: 6),
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : _recentReviews.isEmpty
                        ? Center(
                          child: Text(
                            "No recent activity yet",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _recentReviews.length,
                          itemBuilder: (context, index) {
                            final album = _recentReviews[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ReviewPage(
                                          review: album["data"],
                                          reviewId: album["docId"],
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: Container(
                                  color: AppColors.cardBackground,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              album["title"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              album["artist"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            RatingBarIndicator(
                                              rating: album["rating"],
                                              itemBuilder:
                                                  (context, _) => Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                              itemCount: 5,
                                              itemSize: 18,
                                              direction: Axis.horizontal,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          album["image"],
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    height: 70,
                                                    width: 70,
                                                    color: Colors.grey[900],
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

class RatingsPageView extends StatefulWidget {
  @override
  State<RatingsPageView> createState() => _RatingsPageViewState();
}

class _RatingsPageViewState extends State<RatingsPageView> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _ratedAlbums = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final cover =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('reviews')
            .where('isDeleted', isNotEqualTo: true) // Add this filter
            .orderBy('listenedDate', descending: true)
            .get();

    final reviews =
        cover.docs.map((doc) {
          final data = doc.data();
          return {
            "docId": doc.id,
            "data": data,
            "title": data['albumName'] ?? '',
            "artist": data['artist'] ?? '',
            "image": data['coverUrl'] ?? '',
            "rating": data['rating'] ?? 0.0,
          };
        }).toList();

    setState(() {
      _ratedAlbums = reviews;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredAlbums {
    if (_searchQuery.isEmpty) return _ratedAlbums;
    return _ratedAlbums.where((album) {
      final title = album['title'].toLowerCase();
      final artist = album['artist'].toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || artist.contains(query);
    }).toList();
  }

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
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : _filteredAlbums.isEmpty
                        ? Center(
                          child: Text(
                            "No reviews yet",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        : GridView.builder(
                          itemCount: _filteredAlbums.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.71,
                              ),
                          itemBuilder: (context, index) {
                            final album = _filteredAlbums[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ReviewPage(
                                          review: album["data"],
                                          reviewId: album["docId"],
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,

                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      album["image"]!,
                                      height: 183,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 183,
                                                color: Colors.grey[900],
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white,
                                                ),
                                              ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  RatingBarIndicator(
                                    rating: album["rating"]!,
                                    itemBuilder:
                                        (context, index) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
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
                              ),
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
