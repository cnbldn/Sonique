import 'package:flutter/material.dart';
import 'package:sonique/routes/search_songs.dart';
import 'package:sonique/routes/rate.dart';
import 'package:sonique/utils/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sonique/routes/rate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class add_rating extends StatefulWidget {
  @override
  State<add_rating> createState() => _add_ratingState();
}

class _add_ratingState extends State<add_rating> {
  int currentPage = 0;
  dynamic selectedTrack;

  void onTrackSelected(dynamic track) {
    setState(() {
      selectedTrack = track;
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      search_songs(onTrackSelected: onTrackSelected),
      Rate(track: selectedTrack),
    ];

    return Scaffold(body: _screens[currentPage]);
  }
}

//////////////////////searchsongs///////////////////////////////
class search_songs extends StatefulWidget {
  final Function(dynamic) onTrackSelected;
  const search_songs({super.key, required this.onTrackSelected});

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
                    onTap: () {
                      widget.onTrackSelected(track);
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

//////////////////////searchover///////////////////////////////

//////////////////////rate///////////////////////////////

class Rate extends StatefulWidget {
  final dynamic track;
  const Rate({super.key, required this.track});

  @override
  State<Rate> createState() => _RateState();
}

class _RateState extends State<Rate> {
  double _rating = 0;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _reviewController = TextEditingController();
  bool _isChecked = false;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonSelected,
      appBar: AppBar(
        title: Text(
          "Rate Album",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: AppColors.w_background,
        centerTitle: true,

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                print("Published");
                print("$_rating");
                print(_reviewController.text);
                print("$_selectedDate");
                print("$_isChecked");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sonique_purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Publish"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0, left: 20.0, right: 20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.track['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.track['artists']
                              .map((a) => a['name'])
                              .join(', '),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 10),
                        RatingBar.builder(
                          initialRating: _rating,
                          minRating: 0.5,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 32,
                          //itemPadding:
                          //  EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder:
                              (context, _) =>
                                  Icon(Icons.star, color: Colors.amber),
                          unratedColor: AppColors.starUnrated,
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating;
                            });
                          },
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Date",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          widget.track['album']['images'][0]['url'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 34),
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: Text(
                          DateFormat('EEEE, MMM d yyyy').format(_selectedDate),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                controller: _reviewController,
                maxLines: 8,
                style: TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Add a review or not we don't care...",
                  hintStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: AppColors.w_background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Transform.scale(
                          scale: 1,
                          child: Checkbox(
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "This is a relisten.",
                        style: TextStyle(color: AppColors.text, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////rateover///////////////////////////////
