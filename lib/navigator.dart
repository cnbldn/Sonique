import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sonique/routes/add_rating.dart';
import 'package:sonique/routes/welcome.dart';
import 'package:sonique/routes/login.dart';
import 'package:sonique/routes/signup.dart';
import 'package:sonique/routes/home.dart';
import 'package:sonique/routes/artist_page.dart';
import 'package:sonique/routes/search.dart';
import 'package:sonique/routes/my_profile.dart';
import 'package:sonique/routes/profile.dart';
import 'package:sonique/routes/activity.dart';
import 'package:sonique/utils/colors.dart';
import 'package:sonique/utils/widgets.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentNavIndex = 0;
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      setState(() {
        _profilePicUrl = doc.data()?['photoUrl'];
      });
    }
  }

  // List of all screens
  final List<Widget> _screens = [
    Home(),
    Search(),
    add_rating(),
    Activity(),
    myProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentNavIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151618),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF151618),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.sonique_purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon:
                _profilePicUrl != null
                    ? CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(_profilePicUrl!),
                    )
                    : const Icon(Icons.person_outline),
            activeIcon:
                _profilePicUrl != null
                    ? CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(_profilePicUrl!),
                    )
                    : const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
