import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'dashboard.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            SizedBox(height: 20),
            courseGrid(),
          ],
        ),
      ),
      floatingActionButton: helpButton(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 5,
      toolbarHeight: 50,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            appBarLogo(),
            appBarButton(context),
            const Spacer(),
            appBarIcon(context),
          ],
        ),
      ),
    );
  }

  Widget appBarLogo() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Image.asset(
        'assets/spectrum.png',
        height: 50,
      ),
    );
  }

  Widget appBarButton(BuildContext context) {
    return Row(
      children: [
        _buildAppBarTextButton(context, 'Home'),
        _buildAppBarTextButton(context, 'Dashboard'),
        _buildAppBarTextButton(context, 'My courses'),
        _buildDropdownMenu('Portals', ['MySIS', 'MAYA']),
        _buildAppBarTextButton(context, 'CTES Evaluation'),
        _buildDropdownMenu('Archive', ['Archive 1', 'Archive 2']),
      ],
    );
  }

  Widget _buildAppBarTextButton(BuildContext context, String text) {
    return TextButton(
      onPressed: () {
        if (text == 'Home') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
          );
        }
        if (text == 'Dashboard') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        }
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDropdownMenu(String label, List<String> items) {
    return DropdownButtonHideUnderline(
      child: PopupMenuButton<String>(
        onSelected: (value) {},
        icon: Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        itemBuilder: (BuildContext context) {
          return items
              .map((item) => PopupMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(color: Colors.black)),
                  ))
              .toList();
        },
        offset: Offset(0, 50),
      ),
    );
  }

  Widget appBarIcon(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LineIcons.bell),
          onPressed: () {},
          color: Colors.black,
        ),
        _buildMessageDropdown(context),
        _buildProfileDropdown(context),
      ],
    );
  }

  Widget buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0),
          child: Text(
            'SPeCTRUM | Universiti Malaya',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 120.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hi, Users',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  AnimatedEmoji(
                    AnimatedEmojis.clap,
                    size: 32,
                    repeat: false,
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text(
                'My Courses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {},
      icon: Icon(LineIcons.comment),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'message1',
            child: Row(
              children: [
                Icon(LineIcons.user, color: Colors.black),
                SizedBox(width: 10),
                Text('John Doe: "Hello, how are you?"'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'message2',
            child: Row(
              children: [
                Icon(LineIcons.user, color: Colors.black),
                SizedBox(width: 10),
                Text('Jane Smith: "Don\'t forget to submit your homework."'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'message3',
            child: Row(
              children: [
                Icon(LineIcons.user, color: Colors.black),
                SizedBox(width: 10),
                Text('Admin: "New updates are available."'),
              ],
            ),
          ),
        ];
      },
      constraints: BoxConstraints(maxHeight: 200),
      offset: Offset(0, 50),
    );
  }

  Widget _buildProfileDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {},
      icon: Icon(LineIcons.user),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'accessibility',
            child: Row(
              children: [
                Icon(LineIcons.universalAccess, color: Colors.black),
                SizedBox(width: 10),
                Text('Accessibility'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'calendar',
            child: Row(
              children: [
                Icon(LineIcons.calendar, color: Colors.black),
                SizedBox(width: 10),
                Text('Calendar'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'courses',
            child: Row(
              children: [
                Icon(LineIcons.book, color: Colors.black),
                SizedBox(width: 10),
                Text('Courses'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'preferences',
            child: Row(
              children: [
                Icon(LineIcons.tools, color: Colors.black),
                SizedBox(width: 10),
                Text('Preferences'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'report',
            child: Row(
              children: [
                Icon(LineIcons.fileAlt, color: Colors.black),
                SizedBox(width: 10),
                Text('Report'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(LineIcons.lock, color: Colors.red),
                SizedBox(width: 10),
                Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ];
      },
      constraints: BoxConstraints(maxHeight: 300),
      offset: Offset(0, 50),
    );
  }

  Widget courseGrid() {
    final courseBackgrounds = [
      'assets/coursebg1.png',
      'assets/coursebg2.png',
      'assets/coursebg3.png',
    ];

    final courseCode = [
      'KQC 7015 MACHINE LEARNING',
      'KQC 7028 MEMS DESIGN',
      'KQC 7017 SYSTEM ANALYSIS AND DESIGN',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 16 / 9,
        ),
        itemCount: 3,
        itemBuilder: (context, index) {
          return courseCard(
            context,
            courseCode[index],
            'Faculty of Engineering',
            courseBackgrounds[index],
          );
        },
      ),
    );
  }

  Widget courseCard(
    BuildContext context,
    String name,
    String faculty,
    String backgroundImage,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    image: DecorationImage(
                      image: AssetImage(backgroundImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      faculty,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.black),
                      onSelected: (value) {
                        if (value == 'add_assignment') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Dashboard()),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'add_assignment', child: Text('Add Assignment')),
                        PopupMenuItem(value: 'grading', child: Text('Grading')),
                        PopupMenuItem(value: 'attendance', child: Text('Attendance')),
                        PopupMenuItem(value: 'reschedule', child: Text('Reschedule Class')),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Session 2024/2025 Semester 1',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '(Group 1, 2)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget helpButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.help_outline),
      ),
    );
  }
}

