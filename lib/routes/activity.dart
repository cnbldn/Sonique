import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  int _selectedIndex = 0;
  Map<String, bool> _expandedReviews = {};

  Widget buildFollowRectangle({
    required String username,
    required String followedUser,
    required String timeAgo,
    required String imageAssetPath,
  }) {
    return Container(
      width: 428,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF242527),
        border: Border(bottom: BorderSide(color: Color(0xFF0E0F11), width: 1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              imageAssetPath,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.16168,
                ),
                children: [
                  TextSpan(
                    text: "$username ",
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                  const TextSpan(
                    text: "followed ",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  TextSpan(
                    text: followedUser,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 4),
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

  Widget buildRateRectangle({
    required String username,
    required String album,
    required String artist,
    required double rating,
    required String comment,
    required String imageAssetPath,
    required String profileImage,
    required String timeAgo,
  }) {
    final isExpanded = _expandedReviews[album] ?? false;
    final displayText =
        isExpanded
            ? comment
            : (comment.length > 60
                ? "${comment.substring(0, 60)}..."
                : comment);

    return Container(
      width: 428,
      color: const Color(0xFF242527),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  profileImage,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.16168,
                  ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      artist,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color:
                              index < rating
                                  ? const Color(0xFFD7CE7C)
                                  : const Color(0xFFD9D9D9),
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      displayText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 4),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedReviews[album] = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? "Read Less" : "Read More...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageAssetPath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

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

  Widget buildCustomTabs() {
    final BorderRadiusGeometry friendsRadius =
        _selectedIndex == 0
            ? BorderRadius.circular(6)
            : const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            );
    final BorderRadiusGeometry youRadius =
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
                        backgroundColor:
                            _selectedIndex == 0
                                ? const Color(0xFF242527)
                                : const Color(0xFF0E0F11),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: friendsRadius,
                        ),
                      ),
                      child: const Text(
                        "Friends",
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
                      onPressed: () => setState(() => _selectedIndex = 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedIndex == 1
                                ? const Color(0xFF242527)
                                : const Color(0xFF0E0F11),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: youRadius),
                      ),
                      child: const Text(
                        "You",
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
          const SizedBox(height: 12),
        ],
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
            width: 428,
            height: 131,
            color: const Color(0xFF181A1C),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Activity",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                buildCustomTabs(),
              ],
            ),
          ),

          if (_selectedIndex == 0) ...[
            buildFollowRectangle(
              username: "umaylovesmus1c",
              followedUser: "thisisaras",
              timeAgo: "3h",
              imageAssetPath: "assets/umay.png",
            ),
            buildRateRectangle(
              username: "umaylovesmus1c",
              album: "DeBÍ TiRAR MáS FOToS",
              artist: "Bad Bunny",
              rating: 4,
              comment:
                  "THE summer album of 2025, manifesting this energy for me and my girlies. Cover photo is so meaningful too i love this album so much omg. Bad Bunny rly created a masterpiece i will be blasting this song all day everyday",
              imageAssetPath: "assets/dtmf.png",
              profileImage: "assets/umay.png",
              timeAgo: "3h",
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Text(
                  "Your activity will show up here",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
