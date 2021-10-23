import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver/Testing/HomeScreen.dart';
import 'package:whatsapp_status_saver/Testing/SavedStatusesScreen.dart';
import 'package:whatsapp_status_saver/Testing/SettingsScreen.dart';
import 'package:whatsapp_status_saver/Common/Constants.dart' as cnst;
import 'package:whatsapp_status_saver/en.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  String dropDownHintText = ALL_MEDIA;
  List<String> options = [
    ALL_MEDIA,
    IMAGES,
    VIDEOS,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    RECENT,
                    style: TextStyle(color: cnst.appPrimaryMaterialColor),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 30,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items: options.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: cnst.appPrimaryMaterialColor,
                              ),
                            ),
                          );
                        }).toList(),
                        hint: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            dropDownHintText,
                            style:
                                TextStyle(color: cnst.appPrimaryMaterialColor),
                          ),
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Icon(
                            Icons.arrow_drop_down_circle,
                            color: cnst.appPrimaryMaterialColor,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            dropDownHintText = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _selectedIndex == 1
              ? AppBar(
                  title: Text(
                    SAVED,
                    style: TextStyle(color: cnst.appPrimaryMaterialColor),
                  ),
                  centerTitle: true,
                )
              : AppBar(
                  title: Text(
                    SETTINGS,
                    style: TextStyle(color: cnst.appPrimaryMaterialColor),
                  ),
                  centerTitle: true,
                ),
      body: getPages(_selectedIndex),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.white,
        iconSize: 25,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: _selectedIndex,
        // showElevation: true,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          BottomNavyBarItem(
            inactiveColor: Colors.grey[800],
            textAlign: TextAlign.center,
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Image.asset(
                'assets/status.png',
                height: 20,
                width: 20,
                color: _selectedIndex == 0
                    ? cnst.appPrimaryMaterialColor
                    : Colors.grey[800],
              ),
            ),
            title: Text(
              STATUS,
              style: TextStyle(
                color: cnst.appPrimaryMaterialColor,
              ),
            ),
            activeColor: cnst.appPrimaryMaterialColor,
          ),
          BottomNavyBarItem(
            inactiveColor: Colors.grey[800],
            textAlign: TextAlign.center,
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Image.asset(
                'assets/saved.png',
                height: 20,
                width: 20,
                color: _selectedIndex == 1
                    ? cnst.appPrimaryMaterialColor
                    : Colors.grey[800],
              ),
            ),
            title: Text(
              SAVED,
              style: TextStyle(
                color: cnst.appPrimaryMaterialColor,
              ),
            ),
            activeColor: cnst.appPrimaryMaterialColor,
          ),
          BottomNavyBarItem(
            inactiveColor: Colors.grey[800],
            textAlign: TextAlign.center,
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.settings_outlined,
              ),
            ),
            title: Text(
              SETTINGS,
              style: TextStyle(
                color: cnst.appPrimaryMaterialColor,
              ),
            ),
            activeColor: cnst.appPrimaryMaterialColor,
          ),
        ],
      ),
    );
  }

  getPages(index) {
    if (index == 0) {
      return HomeScreen(
        filterOption: dropDownHintText,
      );
    } else if (index == 1) {
      return SavedStatusesScreen();
    } else if (index == 2) {
      return SettingsScreen();
    }
  }
}
