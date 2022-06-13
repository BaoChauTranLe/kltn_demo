import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kltn/utils/routes.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Text(
                  'RECEIPTS INFORMATION EXTRACT APPLICATION',
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 70.h),
                ),
              ),

              Image.asset(
                'assets/file_search (1).png',
                width: MediaQuery.of(context).size.width/2,
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.cameraScreen);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 4.h, color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search),
                    const Text("Detect"),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.historyScreen);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 4.h, color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history),
                    const Text("History"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
