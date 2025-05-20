import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchArtistStats();
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
    final albums = [
      {'cover': 'assets/defansifdizayn.png', 'title': 'Defansif Dizayn', 'grey': 0},
      {'cover': 'assets/mutsuzparti.png', 'title': 'Mutsuz Parti', 'grey': 2},
      {'cover': 'assets/firtinayt.png', 'title': 'FIRTINAYT', 'grey': 1},
      {'cover': 'assets/aysuramhalaagriyor.png', 'title': 'Ay Şuram Hala Ağrıyor', 'grey': 2},
      {'cover': 'assets/fullfaca.png', 'title': 'Full Faça', 'grey': 2},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Album Discography', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: albums.map<Widget>((album) => _buildAlbumCard(
              width: (MediaQuery.of(context).size.width - 44) / 2,
              cover: album['cover'] as String,
              albumTitle: album['title'] as String,
              artist: widget.artistName,
              greyCount: album['grey'] as int,
            )).toList(),
          )
        ],
      ),
    );
  }


  Widget _buildSongRow({
    required String index,
    required String title,
    required String rating,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      color: const Color(0xFF151618),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              index,
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(
                    text: 'Büyük Ev Ablukada',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              children: [
                Image.asset('assets/star.png', width: 14, height: 14),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard({required double width, required String cover, required String albumTitle, required String artist, int greyCount = 0}) { return Container(
    width: 396, // 428 - 32 for horizontal padding
    height: 40,
    color: const Color(0xFF151618),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        albumTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,

          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
  }
}