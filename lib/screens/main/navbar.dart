import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:smkn10sosmed/widget/constant.dart';
import 'package:smkn10sosmed/screens/main/home_screen.dart';
import 'package:smkn10sosmed/screens/main/post/post_screen.dart';
import 'package:smkn10sosmed/screens/main/profile/profile.dart';

class Navbar extends StatefulWidget {
  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int curent = 0;

  final List screen = [
    HomeScreen(),
    // KenanganScreen(),
    ProfileScreen(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget curentScreen = HomeScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          curent == 1 || curent == 2 ? Colors.white : CustColors.primaryWhite,
      body: PageStorage(
        bucket: bucket,
        child: curentScreen,
      ),
      bottomNavigationBar: Container(
        decoration: curent == 1 || curent == 2
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        offset: Offset(0, -2),
                        blurRadius: 2)
                  ])
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        offset: Offset(0, -2),
                        blurRadius: 2)
                  ]),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: BottomAppBar(
              child: Container(
                // decoration: BoxDecoration(
                //   color: Colors.white,
                // ),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        minWidth: 40,
                        onPressed: () {
                          setState(() {
                            curentScreen = HomeScreen();
                            curent = 0;
                          });
                        },
                        // minWidth: 40,
                        child: curent == 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FluentIcons.home_20_filled,
                                    size: 25,
                                  ),
                                  // Text(
                                  //   "Home",
                                  //   style: TextStyle(
                                  //     fontSize: 10,
                                  //     color: Colors.black,
                                  //   ),
                                  // )
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FluentIcons.home_20_filled,
                                    size: 25,
                                    color: Colors.grey,
                                  ),
                                  // Text(
                                  //   "Home",
                                  //   style: TextStyle(
                                  //     fontSize: 10,
                                  //     color: Colors.grey,
                                  //   ),
                                  // )
                                ],
                              )),
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: FlatButton(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // color: Color(0xFF23B66F),

                        color: curent == 1
                            ? CustColors.primaryBlue
                            : CustColors.primaryBlue.withOpacity(0.8),
                        onPressed: () {
                          setState(() {
                            curentScreen = PostScreen();
                            curent = 1;
                          });
                        },
                        // onPressed: () => print('Upload Photo'),
                        child: Icon(
                          Icons.add_box_rounded,
                          size: 35.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    MaterialButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            curentScreen = ProfileScreen();
                            curent = 2;
                          });
                        },
                        minWidth: 40,
                        child: curent == 2
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FluentIcons.person_20_filled,
                                    size: 25,
                                  ),
                                  // Text(
                                  //   "Profile",
                                  //   style: TextStyle(
                                  //     fontSize: 10,
                                  //     color: Colors.black,
                                  //   ),
                                  // )
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FluentIcons.person_20_filled,
                                    color: Colors.grey,
                                    size: 25,
                                  ),
                                  // Text(
                                  //   "Profile",
                                  //   style: TextStyle(
                                  //     fontSize: 10,
                                  //     color: Colors.grey,
                                  //   ),
                                  // )
                                ],
                              )),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
