import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/services/spotify_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonique/routes/rate.dart';

class AlbumPage extends StatefulWidget {
  final String albumId;
  final String albumName;
  final String albumCoverUrl;
  final String artistName;

  const AlbumPage({
    Key? key,
    required this.albumId,
    required this.albumName,
    required this.albumCoverUrl,
    required this.artistName,
  }) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<dynamic> _tracks = [];
  String _totalDuration = "";
  String? _accessToken;
  double _averageRating = 0.0;
  int _ratingsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAlbumDetails();
    _fetchAlbumRatings();
  }

  Future<void> _loadAlbumDetails() async {
    final token = await getSpotifyAccessToken();
    setState(() => _accessToken = token);

    final url = Uri.parse('https://api.spotify.com/v1/albums/${widget.albumId}');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'];

      int totalMs = 0;
      for (var track in tracks) {
        totalMs += (track['duration_ms'] as num).toInt();
      }

      final duration = Duration(milliseconds: totalMs);
      final formattedDuration = "${duration.inMinutes} min ${duration.inSeconds.remainder(60)} sec";

      setState(() {
        _tracks = tracks;
        _totalDuration = formattedDuration;
      });
    } else {
      debugPrint('Failed to load album details');
    }
  }

  Future<void> _fetchAlbumRatings() async {
    final query = await FirebaseFirestore.instance
        .collection('reviews')
        .where('albumName', isEqualTo: widget.albumName)
        .get();

    double total = 0.0;
    for (var doc in query.docs) {
      final data = doc.data();
      if (data['rating'] != null) {
        total += (data['rating'] as num).toDouble();
      }
    }

    setState(() {
      _ratingsCount = query.docs.length;
      _averageRating = query.docs.isEmpty ? 0.0 : total / query.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A1C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.albumName, style: const TextStyle(color: Colors.white)),
      ),
      body: _tracks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.network(
                    widget.albumCoverUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 12),
                  Text(widget.albumName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(widget.artistName, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text("${_averageRating.toStringAsFixed(1)} / 5", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Text("Average Rating", style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("Tracks: ${_tracks.length}", style: const TextStyle(color: Colors.white70 )),
                  Text("Total Duration: $_totalDuration", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Tracks", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ..._tracks.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final track = entry.value;
              final name = track['name'];
              final duration = Duration(milliseconds: track['duration_ms']);
              final formatted = "${duration.inMinutes}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$index. $name", style: const TextStyle(color: Colors.white, fontSize: 17)),
                    Text(formatted, style: const TextStyle(color: Colors.white70, fontSize: 17)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
