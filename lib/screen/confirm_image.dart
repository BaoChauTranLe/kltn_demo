import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kltn/screen/zoom_image.dart';
import 'package:kltn/server_connection/server_connection.dart';
import 'package:kltn/utils/routes.dart';
import 'package:kltn/widget/home_button.dart';
import 'package:provider/provider.dart';

import '../provider/loading_provider.dart';

class ConfirmImageScreen extends StatefulWidget {
  @override
  State<ConfirmImageScreen> createState() => _ConfirmImageScreenState();
}

class _ConfirmImageScreenState extends State<ConfirmImageScreen> {
  late File image_file;
  late Image display_image;
  bool isDetected = false;
  var detectResult;

  @override
  void didChangeDependencies() {
    image_file = ModalRoute.of(context)!.settings.arguments as File;
    display_image = Image.file(
      image_file,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          Flexible(
            flex: 7,
            child: buildImageView(),
          ),
          Flexible(
            flex: 1,
            child: buildToolRegion(),
          ),
          Flexible(
            flex: 3,
            child: Container(
              child: isDetected ? buildInforRegion() : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInforRegion() {
    return Container(
      padding: EdgeInsets.fromLTRB(32.h, 0, 32.h, 0),
      constraints: const BoxConstraints.expand(),
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  const TextSpan(
                    text: "Extract time: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(
                    text: '${detectResult['time']} ms',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  const TextSpan(
                    text: "SELLER: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(
                    text: detectResult['seller'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  const TextSpan(
                    text: "ADDRESS: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(
                    text: detectResult['address'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  const TextSpan(
                    text: "TIMESTAMP: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(
                    text: detectResult['timestamp'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  const TextSpan(
                    text: "TOTAL_COST: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(
                    text: detectResult['total_cost'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageView() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: display_image,
        ),
        Container(
          constraints: const BoxConstraints.expand(),
          alignment: Alignment.topLeft,
          child: const HomeButton(),
        ),
        Container(
          constraints: const BoxConstraints.expand(),
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 10.h, 10.h),
            width: 50,
            child: IconButton(
              onPressed: () {
                if (image_file != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ZoomImageScreen(display_image)),
                  );
                }
              },
              icon: const Icon(
                Icons.zoom_out_map,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildToolRegion() {
    var data;
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          isDetected
              ? OutlinedButton(
                  onPressed: () {
                    String content = 'SELLER: ' +
                        detectResult['seller'] +
                        '\nADDRESS: ' +
                        detectResult['address'] +
                        '\nTIMESTAMP: ' +
                        detectResult['timestamp'] +
                        '\nTOTAL_COST: ' +
                        detectResult['total_cost'];
                    Clipboard.setData(ClipboardData(text: content)).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Coppied")));
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 4.h, color: Colors.blue),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.copy),
                      SizedBox(
                        width: 4,
                      ),
                      Text("Copy"),
                    ],
                  ),
                )
              : OutlinedButton(
                  onPressed: () async {
                    context.read<LoadingProvider>().setLoad(true);
                    Future.delayed(const Duration(seconds: 10), () {
                      if (context.read<LoadingProvider>().loading) {
                        showDialog<void>(
                          context: context,
                          // false = user must tap button, true = tap outside dialog
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'There were some errors while connecting to the server. Please check your connection and try again.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(dialogContext)
                                        .pop(); // Dismiss alert dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        context.read<LoadingProvider>().setLoad(false);
                      }
                    });

                    //url = 'http://10.0.2.2:5000/';
                    data = await detect(image_file);
                    detectResult = jsonDecode(data);
                    setState(() {
                      isDetected = true;
                      display_image =
                          fileFromBase64String(detectResult['result_image']);
                    });
                    context.read<LoadingProvider>().setLoad(false);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 4.h, color: Colors.blue),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search),
                      SizedBox(
                        width: 4,
                      ),
                      Text("Detect"),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
