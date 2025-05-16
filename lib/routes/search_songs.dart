import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sonique/routes/rate.dart';

class search_songs extends StatefulWidget {
  const search_songs({super.key});
  @override
  State<search_songs> createState() => _search_songsState();
}

class _search_songsState extends State<search_songs> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _songs = [];
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

  Future<void> _searchSongs(String query) async {
    if (_accessToken == null || query.isEmpty) {
      print('Access token is null or query is empty');
      return;
    }

    final url = Uri.parse(
      'https://api.spotify.com/v1/search?q=$query&type=track&limit=10',
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
          _songs = data['tracks']['items'];
        });
        print('Songs found: ${_songs.length}');
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
      appBar: AppBar(title: const Text('Spotify Song Search')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search for songs...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchSongs(_controller.text),
                ),
              ),
              onSubmitted: _searchSongs,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  final track = _songs[index];
                  return ListTile(
                    leading: Image.network(
                      track['album']['images'][0]['url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(track['name']),
                    subtitle: Text(
                      track['artists'].map((a) => a['name']).join(', '),
                    ),
                    onTap: () {},
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
