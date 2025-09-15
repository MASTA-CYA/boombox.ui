// ignore_for_file: unused_import

import 'dart:typed_data';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/constants.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/music-component/widgets/song_view.dart';
import 'package:flutter/material.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<StatefulWidget> createState() => _TestWidget();
}

class _TestWidget extends State<TestWidget> {
  final String title = 'Test';

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<TestWidget>(title: title),
          // drawer: const CustomNavigationDrawer(),
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
