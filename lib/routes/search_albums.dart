import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/services/spotify_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class search_albums extends StatefulWidget {
  final Function(dynamic) onAlbumSelected;

  const search_albums({Key? key, required this.onAlbumSelected}) : super(key: key);

  @override
  State<search_albums> createState() => _search_albumsState();
}


class _search_albumsState extends State<search_albums> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<dynamic> _albums = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) async {
    setState(() => _query = value);
    if (value.trim().isEmpty) return;
    await _searchSpotifyAlbums(value);
  }

  Future<void> _searchSpotifyAlbums(String query) async {
    final accessToken = await getSpotifyAccessToken();
    final uri = Uri.parse('https://api.spotify.com/v1/search?q=$query&type=album&limit=10');

    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        _albums = data['albums']['items'];
      });
    }
  }

  Widget _buildAlbumTiles() {
    if (_query.isEmpty) return const SizedBox();

    return Column(
      children: _albums.map((album) => ListTile(
        leading: album['images'] != null && album['images'].isNotEmpty
            ? Image.network(
          album['images'][0]['url'],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        )
            : const SizedBox(width: 50, height: 50),
        title: Text(album['name'], style: const TextStyle(color: Colors.white)),
        subtitle: Text(album['artists'][0]['name'], style: const TextStyle(color: Colors.grey)),
      )).toList(),
    );
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
                        controller: _searchController,
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
                child: SingleChildScrollView(child: _buildAlbumTiles()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
