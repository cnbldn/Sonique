import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sonique/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Rate extends StatefulWidget {
  final dynamic album;
  const Rate({super.key, required this.album});

  @override
  State<Rate> createState() => _RateState();
}

class _RateState extends State<Rate> {
  double _rating = 0;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _reviewController = TextEditingController();
  bool _isChecked = false;
  final FirestoreService firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;

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
              onPressed: () async{
                // PUSH TO DATABASE
                if (user == null) return;

                final uid = user!.uid;
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .get();
                final username = userDoc.data()?['username'] ?? 'anonymous';

                final albumId = widget.album['id'];
                final albumName = widget.album['name'];
                final rating = _rating;
                final comment = _reviewController.text;
                final isRelisten = _isChecked;
                final listenedDate = _selectedDate;

                await firestoreService.postReview
                  (uid: uid,
                    username: username,
                    albumId: albumId,
                    albumName: albumName,
                    rating: rating,
                    comment: comment,
                    listenedDate: listenedDate,
                    isRelisten: isRelisten);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Review Published!")));
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
                          widget.album['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.album['artists']
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
                          widget.album['images'] != null &&
                                  widget.album['images'].isNotEmpty
                              ? widget.album['images'][0]['url']
                              : 'https://via.placeholder.com/100', // fallback if no image
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
