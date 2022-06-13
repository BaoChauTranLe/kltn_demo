import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZoomImageScreen extends StatelessWidget {
  final Image image;
  const ZoomImageScreen(this.image, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: image,
          ),
          Container(
            constraints: const BoxConstraints.expand(),
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.h, MediaQuery.of(context).viewPadding.top, 0, 0),
              width: 50,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
