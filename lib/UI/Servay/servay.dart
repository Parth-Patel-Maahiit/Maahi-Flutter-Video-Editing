import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/on_boarding_screens/OnBoardingScreen.dart';
import 'package:video_editing_app/util/app_color.dart';

class ServayScreen extends StatefulWidget {
  @override
  _ServayScreenState createState() => _ServayScreenState();
}

class _ServayScreenState extends State<ServayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> selectedVideos = [];
  List<String> selectedPlatforms = [];
  List<String> heardAbout = [];
  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {
      currentTabIndex = _tabController.index;
    });
  }

  void toggleSelection(List<String> list, String item) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  void moveToNextTab() {
    if (currentTabIndex < 2) {
      if (currentTabIndex == 0 && selectedVideos.isEmpty ||
          currentTabIndex == 1 && selectedPlatforms.isEmpty ||
          currentTabIndex == 2 && heardAbout.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please select at least one option.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        _tabController.animateTo(currentTabIndex + 1);
      }
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OnBoardingScreen(),
        ),
        (route) => false,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20,
        flexibleSpace: TabBar(
          controller: _tabController,
          indicatorColor: AppColor.blue_color,
          indicatorWeight: 1.0,
          dividerHeight: 1,
          tabs: [
            Tab(icon: Container()),
            Tab(icon: Container()),
            Tab(icon: Container()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildSurveyPage(
            images: "assets/Home/image6.jpeg",
            top: "Question 1 of 3",
            question: 'What are your videos about?',
            options: [
              {'label': 'Travel', 'icon': Icons.card_travel},
              {'label': 'Religion', 'icon': Icons.place_sharp},
              {'label': 'Food', 'icon': Icons.fastfood},
              {'label': 'Education', 'icon': Icons.school},
              {'label': 'Entertainment', 'icon': Icons.tv},
              {'label': 'Health', 'icon': Icons.health_and_safety},
              {'label': 'Technology', 'icon': Icons.computer},
            ],
            selectedOptions: selectedVideos,
            onSelectionChange: (option) =>
                toggleSelection(selectedVideos, option),
            onNext: moveToNextTab,
          ),
          buildSurveyPage(
            images: "assets/Home/image5.jpeg",
            top: "Question 2 of 3",
            question: 'Where do you share your videos?',
            options: [
              {'label': 'Youtube', 'icon': Icons.video_library},
              {'label': 'Twitter/X', 'icon': Icons.alternate_email},
              {'label': 'Facebook', 'icon': Icons.facebook},
              {'label': 'LinkedIn', 'icon': Icons.business},
              {'label': 'Snapchat', 'icon': Icons.snapchat},
              {'label': 'Instagram', 'icon': Icons.camera_alt},
              {'label': 'TikTok', 'icon': Icons.music_note},
            ],
            selectedOptions: selectedPlatforms,
            onSelectionChange: (option) =>
                toggleSelection(selectedPlatforms, option),
            onNext: moveToNextTab,
          ),
          buildSurveyPage(
            images: "assets/Home/image2.jpeg",
            top: "Question 3 of 3",
            question: 'How did you hear about VEED?',
            options: [
              {'label': 'VEED.IO on web', 'icon': Icons.web},
              {'label': 'TikTok', 'icon': Icons.music_note},
              {'label': 'Youtube', 'icon': Icons.video_library},
              {'label': 'Friends', 'icon': Icons.favorite},
              {'label': 'App Store', 'icon': Icons.store},
              {'label': 'Instagram', 'icon': Icons.camera_alt},
              {'label': 'Google', 'icon': Icons.search},
            ],
            selectedOptions: heardAbout,
            onSelectionChange: (option) => toggleSelection(heardAbout, option),
            onNext: () {
              print('Selected videos: $selectedVideos');
              print('Selected platforms: $selectedPlatforms');
              print('Heard about: $heardAbout');
              moveToNextTab();
            },
          ),
        ],
      ),
    );
  }

  Widget buildSurveyPage({
    required String top,
    required String question,
    required List<Map<String, dynamic>> options,
    required List<String> selectedOptions,
    required Function(String) onSelectionChange,
    required VoidCallback onNext,
    required String images,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 260,
                width: 300,
                child: Image.asset(
                  images,
                  height: 260,
                  width: 300,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            question,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.white_color),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: options.map((option) {
                bool isSelected = selectedOptions.contains(option["label"]);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                  ),
                  child: Container(
                    //borderOnForeground: true,
                    decoration: BoxDecoration(
                        border: isSelected
                            ? Border.all(width: 2, color: AppColor.blue_color)
                            : Border.all(),
                        color: AppColor.survay_container,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      minVerticalPadding: 0,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      leading: Icon(
                        option['icon'],
                        size: 20.0,
                        color: AppColor.white_color,
                      ),
                      minTileHeight: 45,
                      title: Text(
                        option['label'],
                        style: TextStyle(color: AppColor.white_color),
                      ),
                      onTap: () {
                        onSelectionChange(option['label']);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: ElevatedButton(
              onPressed: onNext,
              child: Center(
                child: Text(
                  currentTabIndex == 2 ? 'Done' : 'Next',
                  style: TextStyle(
                      fontSize: 18,
                      color: AppColor.black_color,
                      fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  backgroundColor: AppColor.white_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}
