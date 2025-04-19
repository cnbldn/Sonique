
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  Map<String, bool> _expandedReviews = {};

  final List<Map<String, String>> albums = [
    {
      'image': 'assets/gaga.png',
      'title': 'MAYHEM',
      'artist': 'Lady Gaga',
    },
    {
      'image': 'assets/doechii.png',
      'title': 'Alligator Bites...',
      'artist': 'Doechii',
    },
    {
      'image': 'assets/gorillaz.png',
      'title': 'Plastic Beach',
      'artist': 'Gorillaz',
    },
    {
      'image': 'assets/billie.png',
      'title': 'HIT ME HAR...',
      'artist': 'Billie Eilish',
    },
  ];

  final List<Map<String, String>> songs = [
    {
      'image': 'assets/strokes.png',
      'title': 'The Adults Ar...',
      'artist': 'The Strokes',
    },
    {
      'image': 'assets/daft.png',
      'title': 'Instant Crush',
      'artist': 'Daft Punk',
    },
    {
      'image': 'assets/son_feci.png',
      'title': '80',
      'artist': 'Son Feci Bisiklet',
    },
    {
      'image': 'assets/sebnem.png',
      'title': 'Mayın Tarlası',
      'artist': 'Şebnem Ferah',
    },
    {
      'image': 'assets/marias.png',
      'title': 'No One Noticed',
      'artist': 'The Marías',
    },
  ];

  Widget buildCustomTabs() {
    final BorderRadiusGeometry albumsRadius = _selectedIndex == 0
        ? BorderRadius.circular(6)
        : const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6));
    final BorderRadiusGeometry songsRadius = _selectedIndex == 1
        ? BorderRadius.circular(6)
        : const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Column(
        children: [
          Container(
            width: 410,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF0E0F11),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _selectedIndex = 0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == 0
                            ? const Color(0xFF242527)
                            : const Color(0xFF0E0F11),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: albumsRadius),
                      ),
                      child: const Text(
                        "Albums",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Roboto",
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedIndex == 1
                            ? const Color(0xFF242527)
                            : const Color(0xFF0E0F11),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: songsRadius),
                      ),
                      child: const Text(
                        "Songs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Roboto",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildItemTile(String image, String title, String artist) {
    return SizedBox(
      width: 130,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: 130,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Roboto',
              height: 1.16168,
            ),
          ),
          Text(
            artist,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto',
              height: 1.16168,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScrollableRow(List<Map<String, String>> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            buildItemTile(
              items[i]['image']!,
              items[i]['title']!,
              items[i]['artist']!,
            ),
            if (i != items.length - 1) const SizedBox(width: 17),
          ],
        ],
      ),
    );
  }

  Widget buildReviewBox({
    required String title,
    required String artist,
    required String imagePath,
    required String review,
    required String username,
    required String profilePic,
    required int likes,
    required int comments,
    required int starCount,
  }) {
    final isExpanded = _expandedReviews[title] ?? false;
    final displayText = isExpanded ? review : (review.length > 100 ? review.substring(0, 100) + '...' : review);

    return Container(
      width: 428,
      height: isExpanded ? 290 : 270,
      color: const Color(0xFF151618),
      child: Stack(
        children: [
          Positioned(
            top: 19,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
                Text(
                  artist,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            top: 19,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 71,
            left: 20,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 18,
                  color: index < starCount ? const Color(0xFFD7CE7C) : Colors.white,
                );
              }),
            ),
          ),

          Positioned(
            top: 103,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedReviews[title] = !isExpanded;
                    });
                  },
                  child: Text(
                    isExpanded ? "Read Less" : "Read More...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Roboto",
                      height: 1.16168,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 57,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                profilePic,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 52,
            child: Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 13,
            child: const Icon(Icons.favorite, color: Color(0xFF7CCE80), size: 24),
          ),
          Positioned(
            bottom: 19,
            left: 52,
            child: const Icon(Icons.comment, color: Colors.white, size: 22),
          ),
          Positioned(
            bottom: 24,
            left: 91,
            child: Text(
              "$likes Likes, $comments Comments",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildAlbumReview2() {
    return Container(
      width: 428,
      height: 215,
      color: const Color(0xFF151618),
      child: Stack(
        children: [
          Positioned(
            top: 19,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Melodrama",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
                Text(
                  "Lorde",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 19,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/lorde.png",
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 71,
            left: 20,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 18,
                  color: index < 5 ? const Color(0xFFD7CE7C) : const Color(0xFFD9D9D9),
                );
              }),
            ),
          ),
          Positioned(
            top: 103,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "oh to be a teenager again...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 57,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                "assets/keltos.png",
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 52,
            child: const Text(
              "scoobydaphne",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 13,
            child: Icon(
              Icons.favorite,
              color: Color(0xFF7CCE80),
              size: 24,
            ),
          ),
          Positioned(
            bottom: 19,
            left: 52,
            child: Icon(
              Icons.comment,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 91,
            child: const Text(
              "15 Likes, 3 Comments",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAlbumReview3() {
    return Container(
      width: 428,
      height: 215,
      color: const Color(0xFF151618),
      child: Stack(
        children: [
          Positioned(
            top: 19,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Souvlaki",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
                Text(
                  "Slowdive",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 19,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/slowdive.png",
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 71,
            left: 20,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 18,
                  color: index < 4 ? const Color(0xFFD7CE7C) : const Color(0xFFD9D9D9),
                );
              }),
            ),
          ),
          Positioned(
            top: 103,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "on repeat till i see them live!!!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 57,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                "assets/batu_pfp.jpeg",
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 52,
            child: const Text(
              "batuhanbaydar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 13,
            child: Icon(
              Icons.favorite,
              color: Color(0xFF7CCE80),
              size: 24,
            ),
          ),
          Positioned(
            bottom: 19,
            left: 52,
            child: Icon(
              Icons.comment,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 91,
            child: const Text(
              "2 Likes, 2 Comments",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSongReview() {
    return Container(
      width: 428,
      height: 230,
      color: const Color(0xFF151618),
      child: Stack(
        children: [
          Positioned(
            top: 19,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Sarah",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
                Text(
                  "Alex G",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 19,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/alexg.png",
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 71,
            left: 20,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 18,
                  color: index < 5 ? const Color(0xFFD7CE7C) : const Color(0xFFD9D9D9),
                );
              }),
            ),
          ),
          Positioned(
            top: 103,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "friend told me my shirt looked like the album cover and now i kinda like this song :D",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 57,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                "assets/can.png",
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 52,
            child: const Text(
              "masterofmusic",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 13,
            child: Icon(
              Icons.favorite,
              color: Color(0xFF7CCE80),
              size: 24,
            ),
          ),
          Positioned(
            bottom: 19,
            left: 52,
            child: Icon(
              Icons.comment,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 91,
            child: const Text(
              "40 Likes, 6 Comments",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSongReview2() {
    return Container(
      width: 428,
      height: 215,
      color: const Color(0xFF151618),
      child: Stack(
        children: [
          Positioned(
            top: 19,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Add Up My Love",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
                Text(
                  "Clairo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 19,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/clairo.png",
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 71,
            left: 20,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 18,
                  color: index < 4 ? const Color(0xFFD7CE7C) : const Color(0xFFD9D9D9),
                );
              }),
            ),
          ),
          Positioned(
            top: 103,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "hell yeah",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Roboto",
                    height: 1.16168,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 57,
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                "assets/aras.png",
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 64,
            left: 52,
            child: const Text(
              "thisisaras",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 13,
            child: Icon(
              Icons.favorite,
              color: Color(0xFF7CCE80),
              size: 24,
            ),
          ),
          Positioned(
            bottom: 19,
            left: 52,
            child: Icon(
              Icons.comment,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 91,
            child: const Text(
              "6 Likes, 0 Comments",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                height: 1.16168,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 428,
              height: 131,
              color: const Color(0xFF181A1C),
              child: Column(
                children: [
                  const SizedBox(height: 55),
                  SvgPicture.asset('assets/sonique.svg', width: 155, height: 22),
                  const SizedBox(height: 12),
                  buildCustomTabs(),
                ],
              ),
            ),

            if (_selectedIndex == 0) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  "Popular This Week",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildScrollableRow(albums),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 12),
                child: Text(
                  "From Friends",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 15),
              buildAlbumReview2(),
              const SizedBox(height: 15),
              buildReviewBox(
                title: "DeBÍ TiRAR MáS FOToS",
                artist: "Bad Bunny",
                imagePath: "assets/dtmf.png",
                review: "THE summer album of 2025, manifesting this energy for me and my girlies. Cover photo is so meaningful too i love this album so much omg. Bad Bunny rly created a masterpiece i will be blasting this song all day everyday",
                username: "umaylovesmus1c",
                profilePic: "assets/umay.png",
                likes: 33,
                comments: 8,
                starCount: 4,
              ),

              const SizedBox(height: 15),
              buildAlbumReview3(),
              const SizedBox(height: 15),
            ],

            if (_selectedIndex == 1) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  "Popular This Week",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              buildScrollableRow(songs),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 12),
                child: Text(
                  "From Friends",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 15),
              buildSongReview(),
              const SizedBox(height: 15),
              buildSongReview2(),
              const SizedBox(height: 15),
            ],
          ],
        ),
      ),
    );
  }
}
