import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

class TestNestedScrollView extends StatefulWidget {
  static const String id = 'nested_scroll_view';

  @override
  _TestNestedScrollViewState createState() => _TestNestedScrollViewState();
}

class _TestNestedScrollViewState extends State<TestNestedScrollView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: ModalProgressHUD(
        inAsyncCall: false,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool isscrolled) {
            return [
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                centerTitle: true,
                title: Text('App bar label'),
                backgroundColor: kAppBarColor,
                floating: true,
                snap: true,
                // pinned: true,
                forceElevated: isscrolled,
                actions: [],
              ),
            ];
          },
          body: ScrollableLayout(
            child: Column(
              children: [
                Container(
                  height: 300,
                  color: Colors.red,
                ),
                Container(
                  height: 300,
                  color: Colors.orange,
                ),
                Container(
                  height: 300,
                  color: Colors.yellow,
                ),
                Container(
                  height: 300,
                  color: Colors.green,
                ),
                Container(
                  height: 300,
                  color: Colors.blue,
                ),
                Container(
                  height: 300,
                  color: Colors.purple,
                ),
                Container(
                  height: 300,
                  color: Colors.pink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
