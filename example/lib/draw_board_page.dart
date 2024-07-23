import 'dart:async';

import 'package:animated_path_builder/animated_path.dart';
import 'package:example/utils/path_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DrawBoardPage extends StatefulWidget {
  const DrawBoardPage({super.key});

  @override
  State<DrawBoardPage> createState() => _DrawBoardPageState();
}

class _DrawBoardPageState extends State<DrawBoardPage> with SingleTickerProviderStateMixin {
  // 采樣
  int fps = 144;
  Timer? fpsTimer;
  bool get canUpdate {
    if (fpsTimer == null) {
      fpsTimer = Timer(
        Duration(milliseconds: (1000 / fps ~/ 1)),
        () => fpsTimer = null,
      );
      return true;
    } else {
      return false;
    }
  }

  // 數據
  List<Path> paths = [];

  // 動畫
  bool showAnimated = false;
  DateTime start = DateTime.now();
  late final AnimationController controller;
  late final CurvedAnimation curve;
  final Tween<double> tween = Tween(begin: 0, end: 1);

  void update() {
    if (canUpdate) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    curve = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: controller,
    );
  }

  @override
  void dispose() {
    fpsTimer?.cancel();
    controller.dispose();
    curve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Board'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                paths.clear();
              });
            },
            icon: const Icon(Icons.delete_outline),
          )
        ],
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          start = DateTime.now();
          showAnimated = false;
          controller.reset();

          paths.add(Path());

          Offset offset = event.localPosition;
          paths.last.moveToPoint(offset);
          update();
        },
        onPointerMove: (event) {
          if (canUpdate) {
            Offset offset = event.localPosition;
            paths.last.lineToPoint(offset);
            setState(() {});
          }
        },
        child: LayoutBuilder(
          builder: (_, constraints) {
            if (showAnimated) {
              return SizedBox.fromSize(
                size: constraints.biggest,
                child: AnimatedPath(
                  paths: (_) => paths,
                  animation: tween.animate(curve),
                  color: Theme.of(context).colorScheme.onSurface,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  strokeJoin: StrokeJoin.round,
                  fps: fps,
                ),
              );
            } else {
              return CustomPaint(
                painter: _DrawPainter(
                  paths: paths,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                size: constraints.biggest,
              );
            }

          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showAnimated = true;
          });
          SchedulerBinding.instance.addPostFrameCallback((_) {
            controller.reset();
            controller.forward();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _DrawPainter extends CustomPainter {
  const _DrawPainter({
    required this.paths,
    required this.color,
  });

  final List<Path> paths;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (Path path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawPainter oldDelegate) => true;
}
