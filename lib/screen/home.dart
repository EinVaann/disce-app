import 'package:disce/nav_screen/home_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../widget/custom_tabbar.dart';

class HomeHub extends StatefulWidget {
  const HomeHub({super.key});

  @override
  State<HomeHub> createState() => _HomeHubState();
}

class _HomeHubState extends State<HomeHub> with TickerProviderStateMixin {
  // late TabController _tabController;
  late PageController _pageController;
  int _selectedIndex = 0;
  // List<int> _showLabel = List.generate(4, (index) => 0);
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // setText();
  }

  // Future<void> setText() async {
  //   String s = await SessionManager().get('accessToken');
  //   setState(() {
  //     text = s;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        bottomNavigationBar: ATab(
          backgroundColor: Colors.transparent,
          selectedIndex: _selectedIndex,
          showElevation: false, // use this to remove appBar's elevation
          onItemSelected: (index) => setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease);
          }),
          items: [
            ATabItem(
              icon: const Icon(Icons.style),
              title: const Text('Home'),
              activeColor: const Color.fromARGB(255, 104, 107, 255),
              inactiveColor: const Color.fromARGB(255, 92, 101, 124),
            ),
            ATabItem(
              icon: const Icon(Icons.library_books),
              title: const Text('Dictionary'),
              activeColor: const Color.fromARGB(255, 104, 107, 255),
              inactiveColor: const Color.fromARGB(255, 92, 101, 124),
            ),
            ATabItem(
              icon: const Icon(Icons.message),
              title: const Text('Messages'),
              activeColor: const Color.fromARGB(255, 104, 107, 255),
              inactiveColor: const Color.fromARGB(255, 92, 101, 124),
            ),
            ATabItem(
              icon: const Icon(
                Icons.person,
                // color: Colors.black,
              ),
              title: const Text('User'),
              activeColor: const Color.fromARGB(255, 104, 107, 255),
              inactiveColor: const Color.fromARGB(255, 92, 101, 124),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            const HomeNav(),
            Center(
                child: Text(
              _selectedIndex.toString(),
              style: const TextStyle(fontSize: 40),
            )),
            Center(
                child: Text(
              _selectedIndex.toString(),
              style: const TextStyle(fontSize: 40),
            )),
            Center(
                child: Text(
              _selectedIndex.toString(),
              style: const TextStyle(fontSize: 40),
            )),
          ],
        ),
      ),
    );
  }
}
