import 'package:flutter/material.dart';
import 'package:sonique/routes/search_albums.dart';
import 'package:sonique/routes/rate.dart';

class add_rating extends StatefulWidget {
  @override
  State<add_rating> createState() => _add_ratingState();
}

class _add_ratingState extends State<add_rating> {
  int currentPage = 0;
  dynamic selectedAlbum;

  void onAlbumSelected(dynamic album) {
    setState(() {
      selectedAlbum = album;
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      search_albums(onAlbumSelected: onAlbumSelected),
      Rate(album: selectedAlbum),
    ];

    return Scaffold(body: _screens[currentPage]);
  }
}
