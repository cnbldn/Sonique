import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/colors.dart';
import '../services/spotify_auth.dart';

class EditProfilePage extends StatefulWidget {
  final String currentBio;
  final List<Map<String, String>> favoriteAlbums;

  const EditProfilePage({
    Key? key,
    required this.currentBio,
    required this.favoriteAlbums,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  List<Map<String, String>> _favoriteAlbums = [];
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.currentBio;
    _favoriteAlbums = List.from(widget.favoriteAlbums);
    _authenticate();
  }

  Future<void> _authenticate() async {
    final accessToken = await getSpotifyAccessToken();
    setState(() {
      _accessToken = accessToken;
    });
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final updates = <String, dynamic>{
        'bio': _bioController.text,
        'favoriteAlbums': _favoriteAlbums,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updates);

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save changes: $e')));
    }
  }

  void _showAddAlbumDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Add Favorite Album',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: AlbumSearchWidget(
                onAlbumSelected: (album) {
                  final newAlbum = <String, String>{
                    'title': album['name']?.toString() ?? 'Unknown Title',
                    'artist':
                        album['artists']
                            ?.map(
                              (a) => a['name']?.toString() ?? 'Unknown Artist',
                            )
                            ?.join(', ') ??
                        'Unknown Artist',
                    'image':
                        (album['images'] != null && album['images'].isNotEmpty)
                            ? album['images'][0]['url']?.toString() ?? ''
                            : '',
                    'spotifyId': album['id']?.toString() ?? '',
                  };
                  setState(() {
                    _favoriteAlbums.add(newAlbum);
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.s_dark_bg,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              maxLines: 3,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Bio',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.w_background,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Favorite Albums',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _favoriteAlbums.isEmpty
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: const Text(
                    'No favorite albums',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
                : Column(
                  children:
                      _favoriteAlbums.asMap().entries.map((entry) {
                        final index = entry.key;
                        final album = entry.value;
                        return ListTile(
                          leading:
                              album['image']!.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      album['image']!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey,
                                  ),
                          title: Text(
                            album['title']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            album['artist']!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _favoriteAlbums.removeAt(index);
                              });
                            },
                          ),
                        );
                      }).toList(),
                ),
            ElevatedButton(
              onPressed: _showAddAlbumDialog,
              child: const Text('Add Album'),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumSearchWidget extends StatefulWidget {
  final Function(dynamic) onAlbumSelected;

  const AlbumSearchWidget({Key? key, required this.onAlbumSelected})
    : super(key: key);

  @override
  State<AlbumSearchWidget> createState() => _AlbumSearchWidgetState();
}

class _AlbumSearchWidgetState extends State<AlbumSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _albums = [];
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final accessToken = await getSpotifyAccessToken();
    setState(() {
      _accessToken = accessToken;
    });
  }

  Future<void> _searchAlbums(String query) async {
    if (_accessToken == null || query.isEmpty) return;

    final url = Uri.parse(
      'https://api.spotify.com/v1/search?q=$query&type=album&limit=10',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _albums = data['albums']['items'];
        });
      } else {
        debugPrint('Search failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  void _onSearchChanged(String value) {
    if (value.trim().isNotEmpty) {
      _searchAlbums(value);
    } else {
      setState(() {
        _albums.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Search for albums...',
                    hintStyle: TextStyle(color: AppColors.text),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: _albums.length,
            itemBuilder: (context, index) {
              final album = _albums[index];
              final imageUrl =
                  album['images'] != null && album['images'].isNotEmpty
                      ? album['images'][0]['url']
                      : null;

              return ListTile(
                leading:
                    imageUrl != null
                        ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                        : const SizedBox(width: 50, height: 50),
                title: Text(
                  album['name'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  album['artists'].map((a) => a['name']).join(', '),
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  widget.onAlbumSelected(album);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
