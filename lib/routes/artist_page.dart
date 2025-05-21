import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sonique/services/spotify_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ArtistPage extends StatefulWidget {
  final String artistName;
  final String? artistImageUrl;
  final List<String> genres;

  const ArtistPage({
    Key? key,
    required this.artistName,
    this.artistImageUrl,
    required this.genres,
  }) : super(key: key);

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  int _ratingsCount = 0;
  double _averageRating = 0.0;
  List<Map<String, dynamic>> _albums = [];
  bool _isLoadingAlbums = true;

  Future<String> _fetchSpotifyArtistId(String artistName) async{
    final accessToken = await getSpotifyAccessToken();
    final query = Uri.encodeComponent(artistName);
    final url = 'https://api.spotify.com/v1/search?q=$query&type=artist&limit=1';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if(response.statusCode == 200){
      final data = json.decode(response.body);
      final artists = data['artists']['items'];

      if(artists.isNotEmpty){
        return artists[0]['id'];
      }
      else{
        throw Exception('No artist found with name: $artistName');
      }
    }
    else{
      throw Exception('Spotify API error: ${response.statusCode} ${response.reasonPhrase}');
    }

  }

  Future<List<Map<String, dynamic>>> _fetchAlbumsFromSpotify(String artistId) async{
    final accessToken = await getSpotifyAccessToken();
    final url = 'https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album&limit=20';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if(response.statusCode == 200){
      final data = json.decode(response.body);
      final albums = data['items'] as List;
      return albums.map((album) => {
        'title': album['name'],
        'cover': album['images'].isNotEmpty ? album['images'][0]['url'] : null,
        'id': album['id'],
      }).toList();
    }
    else{
      throw Exception('Failed to fetch albums');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchArtistStats();
    _loadAlbums();
  }

  Future<void> _fetchArtistStats() async{
    try{
      final query = await FirebaseFirestore.instance
          .collection('reviews')
          .where('artist', isEqualTo: widget.artistName)
          .get();

      final docs = query.docs;

      double total = 0.0;
      for (var doc in docs) {
        final data = doc.data();
        if (data['rating'] != null) {
          total += (data['rating'] as num).toDouble();
        }
      }

      setState(() {
        _ratingsCount = query.docs.length;
        _averageRating = docs.isEmpty ? 0.0 : total / docs.length;
      });
    }
    catch (e){
      print("Error fetching ratings count: $e");
    }
  }

  Future<void> _loadAlbums() async{
    try {
      final artistId = await _fetchSpotifyArtistId(widget.artistName);
      final albums = await _fetchAlbumsFromSpotify(artistId);

      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('artist', isEqualTo: widget.artistName)
          .get();

      final albumRatings = <String, List<double>> {};

      for(var doc in ratingsSnapshot.docs){
        final data = doc.data();
        final albumName = data['albumName'];
        final rating = (data['rating'] as num?)?.toDouble();

        if(albumName != null && rating != null){
          albumRatings.putIfAbsent(albumName, () => []).add(rating);
        }
      }

      final enrichedAlbums = albums.map((album) {
        final ratings = albumRatings[album['title']] ?? [];
        final avgRating = ratings.isNotEmpty
            ? ratings.reduce((a, b) => a + b) / ratings.length
            : null;
        return {
          ...album,
          'rating': avgRating,
        };
      }).toList();

      setState(() {
        _albums = enrichedAlbums;
        _isLoadingAlbums = false;
      });
    }
    catch (e){
      print('Failed to load albums: $e');
      setState(() => _isLoadingAlbums = false);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 322,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.artistImageUrl != null && widget.artistImageUrl!.isNotEmpty
                      ? Image.network(widget.artistImageUrl!, fit: BoxFit.cover)
                      : Image.asset('assets/alexg.png', fit: BoxFit.cover),
                  Positioned(
                    top: 50,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/backarrow.png', width: 32, height: 32),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildDiscography()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF151618),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            widget.artistName,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: widget.genres.map((genre) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genre,
                style: const TextStyle(color: Color(0xFFDDDDDD), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('$_ratingsCount', 'Ratings'),
              const SizedBox(width: 64),
              Column(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/star.png', width: 24, height: 24),
                      const SizedBox(width: 6),
                      Text('${_averageRating.toStringAsFixed(1)} / 5', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Average Rating', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
      ],
    );
  }

  Widget _buildDiscography() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Album Discography',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _isLoadingAlbums
              ? const Center(child: CircularProgressIndicator())
              : _albums.isEmpty
              ? const Center(
            child: Text(
              'No albums.',
              style: TextStyle(color: Colors.white70),
            ),
          )
              : Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _albums.map((album) {
              return _buildAlbumCard(
                width: (MediaQuery.of(context).size.width - 44) / 2,
                cover: album['cover'] ?? 'assets/default_album.png',
                albumTitle: album['title'],
                artist: widget.artistName,
                rating: album['rating'],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard({
    required double width,
    required String cover,
    required String albumTitle,
    required String artist,
    double? rating,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              cover,
              width: width,
              height: width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Image.asset('assets/default_album.png', width: width, height: width),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text(
                  albumTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (rating != null) ...[
                      Text(
                        '${rating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => Image.asset(
                          'assets/star.png',
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 18.0,
                        unratedColor: Colors.grey[700],
                        direction: Axis.horizontal,
                      ),
                    ] else
                      const Text(
                        'no ratings',
                        style: TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

}