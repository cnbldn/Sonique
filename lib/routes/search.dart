import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/widgets.dart';
import 'package:sonique/utils/styles.dart';

class Search extends StatelessWidget {
  const Search({Key? key}) : super(key: key);

  static const _Offsets = (
    titleTop: 20.0,
    barTop: 60.0,
    trendingTop: 120.0,
    genresTop: 320.0,
  );

  final List<_Genre> _genres = const [
    _Genre('assets/pop.png', 'Pop'),
    _Genre('assets/rap.png', 'Rap/\nHip Hop'),
    _Genre('assets/rock.png', 'Rock'),
    _Genre('assets/alternative.png', 'Alternative'),
    _Genre('assets/rnb.png', 'R&B'),
    _Genre('assets/electronic.png', 'Electronic'),
    _Genre('assets/folk.png', 'Folk/Country'),
    _Genre('assets/jazz.png', 'Jazz'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    const double hPad = 16;
    const double gap = 12;

    final double rawW = (screenW - hPad * 2 - gap) / 2;
    final double tileW = rawW.floorToDouble();
    final double tileH = tileW * (116 / 190);

    return Scaffold(
      backgroundColor: AppColors.buttonSelected,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: SizedBox(
            width: screenW,
            height: 940,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _Offsets.barTop + 36 + 45,
                  child: Container(color: AppColors.cardBackground),
                ),
                Positioned(
                  top: _Offsets.titleTop + 35,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: _Offsets.barTop + 35,
                  left: hPad,
                  right: hPad,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.buttonSelected,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: AppColors.text, size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: 'Search a song, an album or an artist…',
                              hintStyle: TextStyle(color: AppColors.text),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: _Offsets.trendingTop + 40,
                  left: hPad,
                  child: Text('Trending', style: AppTextStyles.sectionHeader),
                ),
                Positioned(
                  top: _Offsets.trendingTop + 30 + 55,
                  left: hPad,
                  right: hPad,
                  child: Row(
                    children: [
                      genreTile(
                        'assets/new_releases.png',
                        'New\nReleases',
                        tileW,
                        tileH,
                      ),
                      const SizedBox(width: gap),
                      genreTile(
                        'assets/popular.png',
                        'Popular\nThis Week',
                        tileW,
                        tileH,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: _Offsets.genresTop + 15,
                  left: hPad,
                  child: Text('Genres', style: AppTextStyles.sectionHeader),
                ),
                Positioned(
                  top: _Offsets.genresTop + 60,
                  left: hPad,
                  right: hPad,
                  child: Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var genre in _genres)
                        SizedBox(
                          width: tileW,
                          height: tileH,
                          child: genreTile(
                            genre.asset,
                            genre.label,
                            tileW,
                            tileH,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Genre {
  final String asset;
  final String label;
  const _Genre(this.asset, this.label);
}
