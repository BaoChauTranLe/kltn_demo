import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'loading_provider.dart';

class LoadingScreen {
  static TransitionBuilder init({
    TransitionBuilder? builder,
  }) {
    return (BuildContext context, Widget? child) {
      if (builder != null) {
        return builder(context, LoadingCustom(child: child!));
      } else {
        return LoadingCustom(child: child!);
      }
    };
  }
}

class LoadingCustom extends StatelessWidget {
  final Widget child;
  const LoadingCustom({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider<LoadingProvider>(
            create: (context) => LoadingProvider(),
            builder: (context, _) {
              return Stack(children: [
                child,
                Consumer<LoadingProvider>(builder: (context, provider, child) {
                  return provider.loading
                      ? Scaffold(
                          backgroundColor: Colors.black.withOpacity(
                              0.85), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/file_search (1).png",
                                  height: 200.0,
                                  width: 200.0,
                                ),
                                const Text("Please wait...", style: TextStyle(color: Colors.white),),
                              ],
                            ),
                          ),
                        )
                      : Container();
                })
              ]);
            }));
  }
}
