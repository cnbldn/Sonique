import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/widgets.dart';

// Models
class Album {
  final String image;
  final String title;
  final String artist;

  Album({required this.image, required this.title, required this.artist});
}

class Review {
  final String title;
  final String artist;
  final String imagePath;
  final String reviewText;
  final String username;
  final String profilePic;
  final int likes;
  final int comments;
  final int starCount;

  Review({
    required this.title,
    required this.artist,
    required this.imagePath,
    required this.reviewText,
    required this.username,
    required this.profilePic,
    required this.likes,
    required this.comments,
    required this.starCount,
  });
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  int _currentNavIndex = 0; // For bottom navigation
  Map<String, bool> _expandedReviews = {};

  // Data
  final List<Album> albums = [
    Album(image: 'assets/gaga.png', title: 'MAYHEM', artist: 'Lady Gaga'),
    Album(
      image: 'assets/doechii.png',
      title: 'Alligator Bites...',
      artist: 'Doechii',
    ),
    Album(
      image: 'assets/gorillaz.png',
      title: 'Plastic Beach',
      artist: 'Gorillaz',
    ),
    Album(
      image: 'assets/billie.png',
      title: 'HIT ME HAR...',
      artist: 'Billie Eilish',
    ),
  ];

  final List<Album> songs = [
    Album(
      image: 'assets/strokes.png',
      title: 'The Adults Ar...',
      artist: 'The Strokes',
    ),
    Album(
      image: 'assets/daft.png',
      title: 'Instant Crush',
      artist: 'Daft Punk',
    ),
    Album(
      image: 'assets/son_feci.png',
      title: '80',
      artist: 'Son Feci Bisiklet',
    ),
    Album(
      image: 'assets/sebnem.png',
      title: 'Mayın Tarlası',
      artist: 'Şebnem Ferah',
    ),
    Album(
      image: 'assets/marias.png',
      title: 'No One Noticed',
      artist: 'The Marías',
    ),
  ];

  final List<Review> albumReviews = [
    Review(
      title: "Melodrama",
      artist: "Lorde",
      imagePath: "assets/lorde.png",
      reviewText: "oh to be a teenager again...",
      username: "scoobydaphne",
      profilePic: "assets/keltos.png",
      likes: 15,
      comments: 3,
      starCount: 5,
    ),
    Review(
      title: "DeBÍ TiRAR MáS FOToS",
      artist: "Bad Bunny",
      imagePath: "assets/dtmf.png",
      reviewText:
          "THE summer album of 2025, manifesting this energy for me and my girlies. Cover photo is so meaningful too i love this album so much omg. Bad Bunny rly created a masterpiece i will be blasting this song all day everyday",
      username: "umaylovesmus1c",
      profilePic: "assets/umay.png",
      likes: 33,
      comments: 8,
      starCount: 4,
    ),
    Review(
      title: "Souvlaki",
      artist: "Slowdive",
      imagePath: "assets/slowdive.png",
      reviewText: "on repeat till i see them live!!!",
      username: "batuhanbaydar",
      profilePic: "assets/batu_pfp.jpeg",
      likes: 2,
      comments: 2,
      starCount: 4,
    ),
  ];

  final List<Review> songReviews = [
    Review(
      title: "Sarah",
      artist: "Alex G",
      imagePath: "assets/alexg.png",
      reviewText:
          "friend told me my shirt looked like the album cover and now i kinda like this song :D",
      username: "masterofmusic",
      profilePic: "assets/can.png",
      likes: 40,
      comments: 6,
      starCount: 5,
    ),
    Review(
      title: "Add Up My Love",
      artist: "Clairo",
      imagePath: "assets/clairo.png",
      reviewText: "hell yeah",
      username: "thisisaras",
      profilePic: "assets/aras.png",
      likes: 6,
      comments: 0,
      starCount: 4,
    ),
  ];

  // Widget builders
  Widget _buildCustomTabs() {
    final BorderRadiusGeometry albumsRadius =
        _selectedIndex == 0
            ? BorderRadius.circular(6)
            : const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            );

    final BorderRadiusGeometry songsRadius =
        _selectedIndex == 1
            ? BorderRadius.circular(6)
            : const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Column(
        children: [
          Container(
            width: 410,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.buttonSelected,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                _buildTabButton(
                  text: "Albums",
                  index: 0,
                  borderRadius: albumsRadius,
                ),
                _buildTabButton(
                  text: "Songs",
                  index: 1,
                  borderRadius: songsRadius,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String text,
    required int index,
    required BorderRadiusGeometry borderRadius,
  }) {
    return Expanded(
      child: SizedBox(
        height: 28,
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedIndex = index),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedIndex == index
                    ? AppColors.button
                    : AppColors.buttonSelected,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemTile(Album album) {
    return SizedBox(
      width: 130,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              album.image,
              width: 130,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            album.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.16168,
            ),
          ),
          Text(
            album.artist,
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

  Widget _buildScrollableRow(List<Album> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildItemTile(items[i]),
            if (i != items.length - 1) const SizedBox(width: 17),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewBox(Review review) {
    final isExpanded = _expandedReviews[review.title] ?? false;
    final displayText =
        isExpanded
            ? review.reviewText
            : (review.reviewText.length > 100
                ? '${review.reviewText.substring(0, 100)}...'
                : review.reviewText);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF151618),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title, artist and album cover
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and artist
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.16168,
                    ),
                  ),
                  Text(
                    review.artist,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.16168,
                    ),
                  ),
                  // Stars
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 18,
                        color:
                            index < review.starCount
                                ? const Color(0xFFD7CE7C)
                                : Colors.white,
                      );
                    }),
                  ),
                ],
              ),
              // Album cover
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  review.imagePath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          // Review text
          const SizedBox(height: 12),
          Text(
            displayText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.16168,
            ),
          ),

          // Read more/less button
          if (review.reviewText.length > 100)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedReviews[review.title] = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isExpanded ? "Read Less" : "Read More...",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.16168,
                  ),
                ),
              ),
            ),

          // Space before profile section
          const SizedBox(height: 16),

          // Profile info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  review.profilePic,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.16168,
                ),
              ),
            ],
          ),

          // Likes and comments
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFF7CCE80), size: 24),
              const SizedBox(width: 15),
              const Icon(Icons.comment, color: Colors.white, size: 22),
              const SizedBox(width: 15),
              Text(
                "${review.likes} Likes, ${review.comments} Comments",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.16168,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAlbumContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Popular This Week"),
        const SizedBox(height: 10),
        _buildScrollableRow(albums),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12),
          child: Text(
            "From Friends",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Build all album reviews
        for (int i = 0; i < albumReviews.length; i++) ...[
          _buildReviewBox(albumReviews[i]),
          const SizedBox(height: 15),
        ],
      ],
    );
  }

  Widget _buildSongContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Popular This Week"),
        const SizedBox(height: 10),
        _buildScrollableRow(songs),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 12),
          child: Text(
            "From Friends",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Build all song reviews
        for (int i = 0; i < songReviews.length; i++) ...[
          _buildReviewBox(songReviews[i]),
          const SizedBox(height: 15),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonSelected,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and tabs
            Container(
              width: double.infinity,
              color: AppColors.w_background,
              padding: const EdgeInsets.only(top: 55, bottom: 0),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/sonique.svg',
                    width: 155,
                    height: 22,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomTabs(),
                ],
              ),
            ),

            // Content based on selected tab
            _selectedIndex == 0 ? _buildAlbumContent() : _buildSongContent(),

            // Add extra padding at the bottom to account for navigation bar
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
