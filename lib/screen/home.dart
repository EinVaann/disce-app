import 'package:disce/nav_screen/home_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../nav_screen/account_nav.dart';
import '../nav_screen/dict_nav.dart';
import '../widget/custom_tabbar.dart';

class HomeHub extends StatefulWidget {
  const HomeHub({super.key});

  @override
  State<HomeHub> createState() => _HomeHubState();
}

class _HomeHubState extends State<HomeHub> with TickerProviderStateMixin {
  late PageController _pageController;
  int _selectedIndex = 0;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    setState(() {
      _searchText = '';
    });
    // setText();
  }

  void setSelectedTabIndex(int index, dynamic value) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 250), curve: Curves.ease);
      if (index == 1) {
        _searchText = value;
      }
    });
  }

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
            _searchText = '';
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
            // ATabItem(
            //   icon: const Icon(Icons.camera),
            //   title: const Text('Camera'),
            //   activeColor: const Color.fromARGB(255, 104, 107, 255),
            //   inactiveColor: const Color.fromARGB(255, 92, 101, 124),
            // ),
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
            HomeNav(
              goToPage: setSelectedTabIndex,
            ),
            DictNav(
              searchText: _searchText,
            ),
            // Center(
            //     child: Text(
            //   _selectedIndex.toString(),
            //   style: const TextStyle(fontSize: 40),
            // )),
            Center(
                child: Text(
              _selectedIndex.toString(),
              style: const TextStyle(fontSize: 40),
            )),
            const AccountNav(),
          ],
        ),
      ),
    );
  }
}
