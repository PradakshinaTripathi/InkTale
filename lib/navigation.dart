import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Screens/create_new/create_new_blog_story.dart';
import 'Screens/favourite/favourite_page.dart';
import 'Screens/home/home_page.dart';

class Navigation extends StatefulWidget {
  final User? user;
  const Navigation({Key? key, this.user,}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      HomePage(user: widget.user),
      CreateNew(),
      FavouritePage(),
    ];
  }

  void _onItemTapped(int index) {
    // Handle tab selection here
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Customize the selected item color
        onTap: _onItemTapped,
      ),
    );
  }
}
