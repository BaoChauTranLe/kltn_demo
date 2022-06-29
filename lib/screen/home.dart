import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kltn/screen/history_detail.dart';
import 'package:kltn/server_connection/server_connection.dart';
import 'package:kltn/utils/routes.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<String> historyData;
  @override
  void initState() {
    historyData = fetchHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Receipts information extract app',
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    String data = await deleteAll();
                    var deleteResult = jsonDecode(data);
                    if (deleteResult['noti'] ==
                        'Success') {
                      setState(() {
                        historyData = fetchHistory();
                      });
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                          content: Text("Deleted")));
                    }
                  },
                  child: const Text(
                    'DELETE ALL',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                FutureBuilder<String>(
                  future: historyData,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      var detectResult = jsonDecode(snapshot.data!);
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: detectResult['images'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HistoryDetail(
                                              detectResult['images'][index])),
                                    );
                                    //HistoryDetail
                                  },
                                  child: Container(
                                    padding:
                                    EdgeInsets.fromLTRB(16.h, 5.h, 16.h, 5.h),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex:
                                          2 /*or any integer value above 0 (optional)*/,
                                          child: Image.memory(
                                            base64Decode(detectResult['images'][index]
                                            ['anno']['result_image']),
                                            height: 72,
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex:
                                          6 /*or any integer value above 0 (optional)*/,
                                          child: Container(
                                            padding:
                                            EdgeInsets.fromLTRB(16.h, 0, 16.h, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  detectResult['images'][index]
                                                  ['anno']['seller'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(
                                                  height: 10.h,
                                                ),
                                                Text(
                                                  detectResult['images'][index]
                                                  ['anno']['total_cost'],
                                                  style:
                                                  TextStyle(color: Colors.white),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(
                                                  height: 10.h,
                                                ),
                                                Text(
                                                  detectResult['images'][index]
                                                  ['anno']['detect_day'],
                                                  style: TextStyle(
                                                      fontStyle: FontStyle.italic,
                                                      color: Colors.white70),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          flex:
                                          1 /*or any integer value above 0 (optional)*/,
                                          child: IconButton(
                                            onPressed: () async {
                                              String data = await delete(
                                                  detectResult['images'][index]['name']);
                                              var deleteResult = jsonDecode(data);
                                              if (deleteResult['noti'] ==
                                                  'Success') {
                                                setState(() {
                                                  historyData = fetchHistory();
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                    content: Text("Deleted")));
                                              }
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.white70,
                                  thickness: 1,
                                  indent: 50.h,
                                  endIndent: 50.h,
                                ),
                              ],
                            );
                          });
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.all(20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: (){
                    _getImageGallery();
                  },
                  child: Icon(Icons.collections,),
                ),
                SizedBox(width: 16.0),
                FloatingActionButton(
                  onPressed: (){
                    Navigator.of(context).pushNamed(
                        Routes.cameraScreen);
                  },
                  child: Icon(Icons.add_a_photo),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _getImageGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      changeToConfirmScreen(file);
    }
  }

  void changeToConfirmScreen(File image) {
    Navigator.of(context).pushNamed(
        Routes.confirmImage, arguments: image);
  }
}
