import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class search_albums extends StatefulWidget {
  final Function(dynamic) onAlbumSelected;
  const search_albums({super.key, required this.onAlbumSelected});

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
    final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
    final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];
    final credentials = base64.encode(utf8.encode('$clientId:$clientSecret'));

    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      print('Auth status: ${response.statusCode}');
      print('Auth body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _accessToken = data['access_token'];
        });
        print('Access Token: $_accessToken');
      } else {
        debugPrint('Failed to authenticate: ${response.body}');
      }
    } catch (e) {
      debugPrint('Auth error: $e');
    }
  }

  Future<void> _searchAlbums(String query) async {
    if (_accessToken == null || query.isEmpty) {
      print('Access token is null or query is empty');
      return;
    }

    final url = Uri.parse(
      'https://api.spotify.com/v1/search?q=$query&type=album&limit=10',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      print('Search status: ${response.statusCode}');
      print('Search body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _albums = data['albums']['items'];
        });
        print('Albums found: ${_albums.length}');
      } else {
        debugPrint('Search failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spotify Albums Search')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search for albums...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchAlbums(_controller.text),
                ),
              ),
              onSubmitted: _searchAlbums,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _albums.length,
                itemBuilder: (context, index) {
                  final album = _albums[index];
                  return ListTile(
                    leading:
                        album['images'] != null && album['images'].isNotEmpty
                            ? Image.network(
                              album['images'][0]['url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : SizedBox(width: 50, height: 50),
                    title: Text(album['name']),
                    subtitle: Text(
                      album['artists'].map((a) => a['name']).join(', '),
                    ),
                    onTap: () {
                      widget.onAlbumSelected(
                        album,
                      ); // this passes the album back
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
