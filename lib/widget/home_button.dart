import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kltn/utils/routes.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.h, MediaQuery.of(context).viewPadding.top, 0, 0),
      width: 50,
      child: IconButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.home, (Route<dynamic> route) => false);
        },
        icon: const Icon(
          Icons.home,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

}