import 'package:flutter/material.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/widgets.dart';
import 'package:sonique/utils/styles.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';


class Rate extends StatefulWidget{

  const Rate({super.key});

  @override
  State<Rate> createState() => _RateState();
}

class _RateState extends State<Rate> {

  double _rating = 0;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _reviewController= TextEditingController();
  bool _isChecked = false;

  Future<void> _pickDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate){
      setState((){
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E0F11),
      appBar: AppBar(
        title: Text(
          "Rate Album",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16.0
        ),
        ),
        backgroundColor: AppColors.w_background,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
        },
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
        ),

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
                  )
                ),
                child: Text("Publish")
            ),
          )
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
                        Text("Aç Kurtlar Mixtape",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text("APL",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400
                            )
                        ),
                        SizedBox(height: 10,),
                        RatingBar.builder(
                          initialRating: _rating,
                          minRating: 0.5,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 32,
                          //itemPadding:
                          //  EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          unratedColor: Color(0xFFD9D9D9),
                          onRatingUpdate: (rating){
                            setState(() {
                              _rating = rating;
                            });
                          },
                        ),
                        SizedBox(height: 15,),
                        Text("Date",
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/kapak.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 34,),
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: Text(
                          DateFormat('EEEE, MMM d yyyy').format(_selectedDate),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10,),
              TextField(
                controller: _reviewController,
                maxLines: 8,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Add a review or not we don't care...",
                  hintStyle: TextStyle( color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF17191B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none
                  )

                ),
              ),
              SizedBox(height: 8,),
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
                                onChanged: (value){
                                  setState(() {
                                    _isChecked = value!;
                                  });
                                }
                            ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "This is a relisten.",
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      )
      )
    );
  }
}
