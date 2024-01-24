import 'package:flutter/material.dart';
import 'package:twich_clone/screens/following_screen.dart';
import 'package:twich_clone/screens/golive_screen.dart';

import 'display_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int ci = 1;
  List<Widget> page = const [
    FollowingScreen(),
    GoliveScreen(),
    DisplayScreen(),
  ];

  void onTap(int page) {
    setState(() {
      ci = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page[ci],
      bottomNavigationBar:
          BottomNavigationBar(onTap: onTap, currentIndex: ci, items: [
        BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  setState(() {
                    ci = 0;
                  });
                },
                icon: const Icon(Icons.favorite_border)),
            label: 'Following'),
        BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  setState(() {
                    ci = 1;
                  });
                },
                icon: const Icon(Icons.add)),
            label: 'Go Live'),
        BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  setState(() {
                    ci = 2;
                  });
                },
                icon: const Icon(Icons.copy)),
            label: 'Browse'),
      ]),
    );
  }
}
