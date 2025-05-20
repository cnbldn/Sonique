import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/services/spotify_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Search extends StatefulWidget {

  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<dynamic> _albums = [];
  List<dynamic> _artists = [];
  List<DocumentSnapshot> _users = [];

  @override
  void initState(){
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  //final List<_Genre> _genres = const [
    //_Genre('assets/pop.png', 'Pop'),
    //_Genre('assets/rap.png', 'Rap/\nHip Hop'),
    //_Genre('assets/rock.png', 'Rock'),
    //_Genre('assets/alternative.png', 'Alternative'),
    //_Genre('assets/rnb.png', 'R&B'),
    //_Genre('assets/electronic.png', 'Electronic'),
    //_Genre('assets/folk.png', 'Folk/Country'),
    //_Genre('assets/jazz.png', 'Jazz'),
  //];

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) async{
    setState(() => _query = value);
    if(value.trim().isEmpty) return;

    await _searchSpotify(value);
    await _searchUsers(value);
  }

  Future<void> _searchSpotify(String query) async{
    final accessToken = await getSpotifyAccessToken();
    final uri = Uri.parse('https://api.spotify.com/v1/search?q=$query&type=album,artist&limit=10');

    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if(res.statusCode == 200){
      final data = json.decode(res.body);
      setState(() {
        _albums = data['albums']['items'];
        _artists = data['artists']['items'];
      });
    }
  }

  Future<void> _searchUsers(String query) async{
    final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('displayName', isGreaterThanOrEqualTo: query)
      .where('displayName', isLessThanOrEqualTo: '$query\uf8ff').limit(10).get();

    setState(() {
      _users = snapshot.docs;
    });
  }

  Widget _buildResultTiles(){
    final index = _tabController.index;
    if(_query.isEmpty) return SizedBox();

    switch(index) {
      case 0:
        return Column(
          children: _albums.map((album) => ListTile(
            title: Text(album['name'], style: TextStyle(color: Colors.white)),
            subtitle: Text(album['artists'][0]['name'], style: TextStyle(color: Colors.grey)),
          )).toList(),
        );
      case 1:
        return Column(
          children: _artists.map((artist) => ListTile(
            title: Text(artist['name'], style: TextStyle(color: Colors.white)),
          )).toList(),
        );
      case 2:
        return Column(
          children: _users.map((doc) => ListTile(
            title: Text(doc['displayName'], style: TextStyle(color: Colors.white),),
          )).toList(),
        );
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E0F11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A1C), // match your background
        elevation: 0, // removes shadow line
        centerTitle: true,
        automaticallyImplyLeading: false, // removes back button
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
          child:
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
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
                            hintText: 'Search artists, albums, users...',
                            hintStyle: TextStyle(color: AppColors.text),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16,),
                TabBar(
                    controller: _tabController,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Albums",),
                      Tab(text: "Artists",),
                      Tab(text: "Users",),
                    ]
                ),
                const SizedBox(height: 16,),
                Expanded(
                    child: TabBarView(
                        controller: _tabController,
                        children:[
                          SingleChildScrollView(child: _buildResultTiles()),
                          SingleChildScrollView(child: _buildResultTiles()),
                          SingleChildScrollView(child: _buildResultTiles()),
                        ]
                    ),
                ),

              ],
            ),
          )
      ),
    );
  }
}
