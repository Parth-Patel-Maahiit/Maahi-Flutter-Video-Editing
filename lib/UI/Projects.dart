import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/Profile_screen.dart';
import 'package:video_editing_app/UI/home_scren.dart';
import 'package:video_editing_app/UI/myprojects.dart';
import 'package:video_editing_app/util/app_color.dart';
import 'package:video_editing_app/util/app_images.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Set initial index to the splash screen
  int _selectedCrossIndex = 0;
  bool _iscreate = true;
  late AnimationController _controller;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void changeshape() {
    setState(() {
      _iscreate = !_iscreate;
      if (_iscreate) {
        _controller.reverse();
        _selectedIndex = _selectedCrossIndex;
      } else {
        _controller.forward();
        _selectedIndex = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 1,
        shadowColor: Colors.white70,
        title: Text(
          'APP',
          style: TextStyle(color: AppColor.white_color),
        ),
      ),
      body: [
        MyProjectsScreen(),
        HomeScreen(
          onTap: () {
            changeshape();
          },
        ),
        ProfileScreen(),
      ].elementAt(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
              color: _iscreate ? Colors.white10 : Colors.transparent,
              borderRadius: BorderRadius.circular(40)),
          //color: Colors.amber,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_iscreate) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _onItemTapped(0);
                          _selectedCrossIndex = 0;
                        },
                        icon: ImageIcon(
                          AssetImage(AppImages.folder),
                          size: 30,
                        ),
                        color: AppColor.white_color,
                      ),
                      _selectedCrossIndex == 0
                          ? Container(
                              height: 10,
                              child: ImageIcon(
                                AssetImage(AppImages.dott),
                                color: AppColor.white_color,
                              ),
                            )
                          : Container(height: 10),
                    ],
                  ),
                ],
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.35).animate(_controller),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: _iscreate
                          ? Color.fromARGB(233, 94, 90, 90)
                          : Color.fromARGB(255, 176, 167, 167),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _iscreate
                              ? AppColor.home_plus_color
                              : const Color.fromARGB(255, 89, 88, 88),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _iscreate = !_iscreate;
                                if (_iscreate) {
                                  _controller.reverse();
                                  _selectedIndex = _selectedCrossIndex;
                                } else {
                                  _controller.forward();
                                  _selectedIndex = 1;
                                }
                              });
                            },
                            icon: ImageIcon(
                              AssetImage(AppImages.plus),
                              color: AppColor.white_color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_iscreate) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _onItemTapped(2);
                          _selectedCrossIndex = 2;
                        },
                        icon: ImageIcon(
                          AssetImage(AppImages.user),
                          size: 30,
                        ),
                        color: AppColor.white_color,
                      ),
                      _selectedCrossIndex == 2
                          ? Container(
                              height: 10,
                              child: ImageIcon(
                                AssetImage(AppImages.dott),
                                color: AppColor.white_color,
                              ),
                            )
                          : Container(height: 10),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
