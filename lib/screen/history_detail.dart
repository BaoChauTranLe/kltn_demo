import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kltn/screen/zoom_image.dart';
import 'package:kltn/server_connection/server_connection.dart';
import 'package:kltn/utils/routes.dart';

import '../widget/home_button.dart';

class HistoryDetail extends StatelessWidget {
  var detail;
  late Image display_image;
  HistoryDetail(this.detail, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    display_image = fileFromBase64String(detail['anno']['result_image']);
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          Flexible(
            flex: 7,
            child: buildImageView(context),
          ),
          Flexible(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 4.h, color: Colors.blue),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.history),
                        SizedBox(
                          width: 4,
                        ),
                        Text("History"),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      String content = 'SELLER: ' +
                          detail['anno']['seller'] +
                          '\nADDRESS: ' +
                          detail['anno']['address'] +
                          '\nTIMESTAMP: ' +
                          detail['anno']['timestamp'] +
                          '\nTOTAL_COST: ' +
                          detail['anno']['total_cost'];
                      Clipboard.setData(ClipboardData(text: content)).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Coppied")));
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
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Container(
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
                            text: "Extract date: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          TextSpan(
                            text: detail['anno']['detect_day'],
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
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          TextSpan(
                            text: detail['anno']['seller'],
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
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          TextSpan(
                            text: detail['anno']['address'],
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
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          TextSpan(
                            text: detail['anno']['timestamp'],
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
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          TextSpan(
                            text: detail['anno']['total_cost'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageView(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: fileFromBase64String(detail['anno']['result_image']),
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
                if (display_image != null) {
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
}
