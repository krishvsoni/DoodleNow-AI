import 'dart:async';
import 'dart:io';

import 'package:doodle_for_gdsc/screens/canvas/doodle_ai.dart';
import 'package:doodle_for_gdsc/screens/canvas/stroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import "dart:ui" as ui;

import 'package:share_plus/share_plus.dart';

enum CanvasTool { pen, ai }

class CanvasMainScreen extends StatefulWidget {
  const CanvasMainScreen({super.key});

  @override
  State<CanvasMainScreen> createState() => _CanvasMainScreenState();
}

class _CanvasMainScreenState extends State<CanvasMainScreen> {
  ValueNotifier<Stroke?> currentStroke = ValueNotifier(null);
  ValueNotifier<List<Stroke>> stroke = ValueNotifier([]);

  ValueNotifier<CanvasTool> selectedTool = ValueNotifier(CanvasTool.pen);

  ValueNotifier<PictureInfo?> pictureInfo = ValueNotifier(null);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  GlobalKey canvasKey = GlobalKey();

  selectTool(CanvasTool tool) {
    selectedTool.value = tool;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    selectedTool.notifyListeners();
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  Future<void> clear() async {
    currentStroke.value = null;
    pictureInfo.value = null;
    stroke.value.clear();

    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    currentStroke.notifyListeners();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pictureInfo.notifyListeners();

    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    stroke.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, loading, _) {
            return ValueListenableBuilder<CanvasTool>(
                valueListenable: selectedTool,
                builder: (context, tool, _) {
                  return Stack(
                    children: [
                      buildAllPaths(context),
                      buildCurrentPath(context),
                      buildToolBar(context),
                      tool == CanvasTool.ai
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: DoodleAI(
                                loadingCallback: (loading) {
                                  isLoading.value = loading;
                                  if (loading) {
                                    selectTool(CanvasTool.pen);
                                  }
                                  isLoading.notifyListeners();
                                },
                                onGptCalled: (svg) {
                                  pictureInfo.value = svg;
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  pictureInfo.notifyListeners();
                                  selectTool(CanvasTool.pen);
                                },
                              ),
                            )
                          : const SizedBox(),
                      loading
                          ? Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/loder.gif',
                                scale: 4,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  );
                });
          }),
    );
  }

  Widget buildToolBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ValueListenableBuilder<CanvasTool>(
            valueListenable: selectedTool,
            builder: (context, tool, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  toolWidget(
                    () {
                      selectTool(CanvasTool.pen);
                    },
                    'assets/pen.png',
                    tool == CanvasTool.pen ? 1 : 0.5,
                  ),
                  toolWidget(
                    () {
                      selectTool(CanvasTool.ai);
                    },
                    'assets/ai.png',
                    tool == CanvasTool.ai ? 1 : 0.5,
                  ),
                  toolWidget(
                    () async {
                      RenderRepaintBoundary boundary = canvasKey.currentContext!
                          .findRenderObject() as RenderRepaintBoundary;

                      ui.Image image = await boundary.toImage();
                      ByteData? byteData = await image.toByteData(
                          format: ui.ImageByteFormat.png);

                      if (byteData == null) {
                        throw Exception('ByteData was null');
                      } else {
                        Uint8List pngBytes = byteData.buffer.asUint8List();

                        final tempDir = await getTemporaryDirectory();

                        File file = await File(
                                '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png')
                            .create();
                        file.writeAsBytesSync(pngBytes);

                        await Share.shareXFiles(
                          [XFile(file.path)],
                          text: 'Doodle for GDSC',
                        );
                      }
                    },
                    'assets/export.png',
                    1,
                  ),
                  toolWidget(
                    () {
                      selectTool(CanvasTool.pen);
                      clear();
                    },
                    'assets/clear.png',
                    1,
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget toolWidget(
      void Function()? onPressed, String imagePath, double opacity) {
    return Opacity(
      opacity: opacity,
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          imagePath,
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: canvasKey,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ValueListenableBuilder<PictureInfo?>(
            valueListenable: pictureInfo,
            builder: (context, picture, _) {
              return ValueListenableBuilder<List<Stroke>>(
                valueListenable: stroke,
                builder: (context, strokes, _) {
                  return CustomPaint(
                    painter: StrokePainter(
                      points: strokes,
                      pictureInfo: picture,
                    ),
                  );
                },
              );
            }),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent details) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(details.position);
        Point point = Point(
          offset.dx,
          offset.dy,
          (details.pressure - details.pressureMin) /
              (details.pressureMax - details.pressureMin),
        );

        final points = [point];
        currentStroke.value = Stroke(points);
      },
      onPointerMove: (PointerMoveEvent details) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(details.position);
        Point point = Point(
          offset.dx,
          offset.dy,
          (details.pressure - details.pressureMin) /
              (details.pressureMax - details.pressureMin),
        );

        final points = [...currentStroke.value!.points, point];

        currentStroke.value = Stroke(points);
      },
      onPointerUp: (PointerUpEvent details) {
        stroke.value = List.from(stroke.value)..add(currentStroke.value!);
      },
      child: ValueListenableBuilder<CanvasTool>(
          valueListenable: selectedTool,
          builder: (context, tool, _) {
            return ValueListenableBuilder<Stroke?>(
                valueListenable: currentStroke,
                builder: (context, points, _) {
                  return RepaintBoundary(
                    // key: canvasKey,
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: CustomPaint(
                        painter: StrokePainter(
                          points: points == null ? [] : [points],
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}

class StrokePainter extends CustomPainter {
  final List<Stroke> points;
  final PictureInfo? pictureInfo;

  StrokePainter({required this.points, this.pictureInfo});

  @override
  void paint(Canvas canvas, Size size) {
    if (pictureInfo != null) {
      canvas.drawPicture(pictureInfo!.picture);
      return;
    }

    Paint paint = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; ++i) {
      final outlinePoints = getStroke(
        points[i].points,
        size: 4,
      );

      final path = Path();

      if (outlinePoints.isEmpty) {
        return;
      } else if (outlinePoints.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(Rect.fromCircle(
            center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
      } else {
        // Otherwise, draw a line that connects each point with a curve.
        path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

        for (int i = 1; i < outlinePoints.length - 1; ++i) {
          final p0 = outlinePoints[i];
          final p1 = outlinePoints[i + 1];
          path.quadraticBezierTo(
              p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
