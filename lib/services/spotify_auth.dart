import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String?> getSpotifyAccessToken() async {
  final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
  final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];

  if(clientId == null || clientSecret == null){
    throw Exception('Spotify credentials are not set in .env');
  }

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

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      print('Spotify auth failed: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Spotify auth error: $e');
    return null;
  }
}