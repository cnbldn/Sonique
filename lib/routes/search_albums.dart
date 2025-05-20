import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/services/spotify_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sonique/routes/rate.dart';

class search_albums extends StatefulWidget {
  final Function(dynamic)? onAlbumSelected;
  const search_albums({super.key, this.onAlbumSelected});

  @override
  State<search_albums> createState() => _search_albumsState();
}

class _search_albumsState extends State<search_albums> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _albums = [];
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final accessToken = await getSpotifyAccessToken();
    setState(() {
      _accessToken = accessToken;
    });
  }

  Future<void> _searchAlbums(String query) async {
    if (_accessToken == null || query.isEmpty) return;

    final url = Uri.parse(
      'https://api.spotify.com/v1/search?q=$query&type=album&limit=10',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _albums = data['albums']['items'];
        });
      } else {
        debugPrint('Search failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  void _onSearchChanged(String value) {
    if (value.trim().isNotEmpty) {
      _searchAlbums(value);
    } else {
      setState(() {
        _albums.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A1C),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Spotify Albums Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.text, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: 'Search for albums...',
                          hintStyle: TextStyle(color: AppColors.text),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    final album = _albums[index];
                    final imageUrl = album['images'] != null && album['images'].isNotEmpty
                        ? album['images'][0]['url']
                        : null;

                    return ListTile(
                      leading: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : const SizedBox(width: 50, height: 50),
                      title: Text(album['name'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        album['artists'].map((a) => a['name']).join(', '),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        if (widget.onAlbumSelected != null) {
                          widget.onAlbumSelected!(album);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Rate(album: album),
                            ),
                          );
                        }
                      },
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
