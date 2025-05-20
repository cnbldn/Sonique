import 'dart:math' show pi;
import 'package:flutter/material.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({Key? key}) : super(key: key);

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  bool _expanded = false; // controls whether extra songs are shown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11), // matches your w_background
      body: SingleChildScrollView(
        child: SizedBox(
          width: 428,
          // Increase the height to accommodate possible extra songs
          height: _expanded ? 1930 : 1800,
          child: Stack(
            children: [
              // =============== 1) HEADER IMAGE =========================
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 428,
                  height: 322,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/buyukievablukada_headerimage.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // =============== 1A) BACK BUTTON ON HEADER IMAGE =========
              Positioned(
                top: 50,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // go back
                  },
                  child: Image.asset(
                    'assets/backarrow.png', // your backarrow image
                    width: 32,
                    height: 32,
                  ),
                ),
              ),

              // =============== 2) DARK CONTAINER with TEXTS =============
              // (unchanged from your code, just keep it)
              Positioned(
                top: 320,
                left: 0,
                child: Container(
                  width: 428,
                  height: 250,
                  color: const Color(0xFF151618),
                  child: Stack(
                    children: [
                      // “Büyük Ev Ablukada” Title
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'Büyük Ev Ablukada',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // Description
                      Positioned(
                        top: 70,
                        left: 19,
                        child: SizedBox(
                          width: 375,
                          height: 79,
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'Büyük Ev Ablukada is a Turkish music group founded in ',
                                    style: TextStyle(
                                      color: Color(0xFFAAAAAA),
                                      fontSize: 14,

                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Istanbul',
                                    style: TextStyle(
                                      color: Color(0xFFAAAAAA),
                                      fontSize: 14,

                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' in 2008. The band was started by Cem Yılmazer (a.k.a. Afordisman Salihins) '
                                        'and Bartu Küçükçağlayan (a.k.a. Canavar Banavar.) After some time the band...',
                                    style: TextStyle(
                                      color: Color(0xFFAAAAAA),
                                      fontSize: 14,

                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      // Stats: 3088, Albums, 5693, etc.
                      Positioned(
                        top: 170 + 7,
                        left: 53,
                        child: Text(
                          '3088',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 20,

                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 195 + 7,
                        left: 19,
                        child: Text(
                          'Albums Got Rated',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,

                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 170 + 7,
                        left: 185,
                        child: Text(
                          '5693',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 20,

                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 195 + 7,
                        left: 155,
                        child: Text(
                          'Songs Got Rated',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,

                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 170 + 7,
                        right: 45,
                        child: Text(
                          '3.9 / 5',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,

                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 195 + 7,
                        right: 36,
                        child: Text(
                          'Average Rating',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,

                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 173 + 7,
                        right: 108,
                        child: Image.asset(
                          'assets/star.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =============== 3) “Most Popular Songs” title =============
              // 24 px after that container => top ~ (320+250) + 24 = 594
              Positioned(
                top: 600,
                left: 16,
                child: Text(
                  'Most Popular Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // =============== 4) SONG 1, SONG 2, SONG 3  ===============
              // we place them with your existing logic
              // Song 1 => top: 640
              Positioned(
                top: 640,
                left: 0,
                child: _buildSongRow(
                  index: '1',
                  title: 'Hoşçakal Kadar',
                  rating: '4.2 / 5',
                ),
              ),

              // Song 2 => top: 716
              Positioned(
                top: 706,
                left: 0,
                child: _buildSongRow(
                  index: '2',
                  title: 'En Güzel Yerinde Evin',
                  rating: '4 / 5',
                ),
              ),

              // Song 3 => top: 792
              Positioned(
                top: 772,
                left: 0,
                child: _buildSongRow(
                  index: '3',
                  title: 'Güneş Yerinde',
                  rating: '4.1 / 5',
                ),
              ),

              // =============== 5) OPTIONAL: SONG 4 + SONG 5 ==============
              // Show only if _expanded == true
              if (_expanded)
                Positioned(
                  top: 838, // 792 + 64 + 12 = 868 (some spacing after 3rd song)
                  left: 0,
                  child: _buildSongRow(
                    index: '4',
                    title: 'İhtimallerin Heyecanına Üzülüyorum',
                    rating: '3.8 / 5',
                  ),
                ),
              if (_expanded)
                Positioned(
                  top: 904, // 868 + 64 + 12 = 944
                  left: 0,
                  child: _buildSongRow(
                    index: '5',
                    title: 'Beklediğim Gibiyim',
                    rating: '4.6 / 5',
                  ),
                ),

              // =============== 6) The Toggle Arrow Container =============
              // If not expanded, arrow is under the 3rd song (top: 860)
              // If expanded, arrow moves below 5th song => top: 1020 or so
              Positioned(
                top: _expanded ? 965 : 830,
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Container(
                    width: 428,
                    height: 25,
                    color: const Color(0xFF151618), // same background
                    child: Center(
                      // if expanded => rotate by pi, else => 0
                      child: Transform.rotate(
                        angle: _expanded ? pi : 0,
                        child: Image.asset(
                          'assets/downarrow.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // =============== 7) ALBUM DISCOGRAPHY (EXAMPLE) ============
              // Suppose you want it to appear below the arrow
              // If not expanded, arrow is at 860 => let’s add ~40 => 900
              // If expanded, arrow is at 1020 => add ~40 => 1060
              // so we do an if/else or a small function
              Positioned(
                top: _expanded ? 1025 : 885,
                left: 16,
                child: Text(
                  'Album Discography',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // We can place 5 albums below that heading or
              // you keep your older approach. For demonstration:
              // top => +some offset from the heading
              Positioned(
                top: _expanded ? 1070 : 930, // keep your original Y‑offsets
                left: 16,
                right: 16, // 16‑px margin ⇒ 4/3 × 12‑px middle gap
                child: Builder(
                  builder: (context) {
                    final double screen = MediaQuery.of(context).size.width;
                    const double leftPad = 16;
                    const double rightPad = 16;
                    const double midGap = 12;
                    final double cardW =
                        (screen - leftPad - rightPad - midGap) / 2;

                    return Wrap(
                      spacing: midGap, // gap between the two cards
                      runSpacing: 12,
                      children: [
                        _buildAlbumCard(
                          width: cardW,
                          cover: 'assets/defansifdizayn.png',
                          albumTitle: 'Defansif Dizayn',
                          artist: 'Büyük Ev Ablukada',
                          greyCount: 0,
                        ),
                        _buildAlbumCard(
                          width: cardW,
                          cover: 'assets/mutsuzparti.png',
                          albumTitle: 'Mutsuz Parti',
                          artist: 'Büyük Ev Ablukada',
                          greyCount: 2,
                        ),
                        _buildAlbumCard(
                          width: cardW,
                          cover: 'assets/firtinayt.png',
                          albumTitle: 'FIRTINAYT',
                          artist: 'Büyük Ev Ablukada',
                          greyCount: 1,
                        ),
                        _buildAlbumCard(
                          width: cardW,
                          cover: 'assets/aysuramhalaagriyor.png',
                          albumTitle: 'Ay Şuram Hala Ağrıyor',
                          artist: 'Büyük Ev Ablukada',
                          greyCount: 2,
                        ),
                        _buildAlbumCard(
                          width: cardW,
                          cover: 'assets/fullfaca.png',
                          albumTitle: 'Full Faça',
                          artist: 'Büyük Ev Ablukada',
                          greyCount: 2,
                        ),
                      ],
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

  // --- SONG ROW (64 px) -------------------------------------------------
  Widget _buildSongRow({
    required String index,
    required String title,
    required String rating,
  }) {
    return Container(
      width: 428,
      height: 64,
      color: const Color(0xFF151618),
      child: Row(
        children: [
          // index
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

          // title + artist
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

          // ★  rating
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

  // ---------- ALBUM CARD (dynamic width + big stars + tint) -------------
  Widget _buildAlbumCard({
    required double width, // calculated in the Wrap
    required String cover,
    required String albumTitle,
    required String artist,
    int greyCount = 0, // ← number of stars to tint #D9D9D9 (0‑5)
  }) {
    const double starSize = 24; // same size as the Average‑Rating star
    final double coverSize = width; // square cover
    final double starsTop = coverSize + 8;
    final double titleTop = starsTop + starSize + 6;
    final double artistTop = titleTop + 19;

    return Container(
      width: width,
      height: artistTop + 20,
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // album cover
          Positioned(
            left: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                cover,
                width: coverSize,
                height: coverSize,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ★★★★★  (24 px, some can be grey)
          Positioned(
            top: starsTop,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final bool grey = i >= 5 - greyCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      grey ? const Color(0xFFD9D9D9) : Color(0xFFD7CE7C),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/star.png',
                      width: starSize / 1.25,
                      height: starSize,
                    ),
                  ),
                );
              }),
            ),
          ),

          // album title
          Positioned(
            top: titleTop,
            left: 0,
            right: 0,
            child: Text(
              albumTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,

                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // artist
          Positioned(
            top: artistTop,
            left: 0,
            right: 0,
            child: Text(
              artist,
              textAlign: TextAlign.center,
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

  // Example single album "row" or "card"
  Widget _buildAlbum(String title) {
    return Container(
      width: 396, // 428 - 32 for horizontal padding
      height: 40,
      color: const Color(0xFF151618),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
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
