import 'package:doodle_for_gdsc/screens/canvas/canvas_main.dart';
import 'package:doodle_for_gdsc/screens/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashSceeen extends StatefulWidget {
  const SplashSceeen({super.key});

  @override
  State<SplashSceeen> createState() => _SplashSceeenState();
}

class _SplashSceeenState extends State<SplashSceeen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  void navigateToCanvasScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CanvasMainScreen(),
      ),
    ).then((value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/loder.gif',
                scale: 4,
              ),
              const Text.rich(
                TextSpan(
                    text: 'Doodle ',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: 'for',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                        ),
                      )
                    ]),
              ),
              const Text.rich(
                TextSpan(
                    text: 'G ',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 30,
                    ),
                    children: [
                      TextSpan(
                          text: 'D ',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 30,
                          ),
                          children: [
                            TextSpan(
                                text: 'S ',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 30,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'C ',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 30,
                                    ),
                                  )
                                ])
                          ]),
                    ]),
              ),
              const SizedBox(
                height: 40,
              ),
              CustomButton(
                label: "Let's Doodle",
                onTap: () => navigateToCanvasScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
