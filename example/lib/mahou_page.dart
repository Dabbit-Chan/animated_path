import 'dart:math';

import 'package:animated_path/animated_path.dart';
import 'package:example/utils/path_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MaHouPage extends StatefulWidget {
  const MaHouPage({super.key});

  @override
  State<MaHouPage> createState() => _MaHouPageState();
}

class _MaHouPageState extends State<MaHouPage> with SingleTickerProviderStateMixin {
  Path starPath = Path();
  Path circlePath = Path();

  late final AnimationController controller;
  late final CurvedAnimation curve;
  final Tween<double> tween = Tween(begin: 0, end: 1);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    curve = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    curve.dispose();
    super.dispose();
  }

  void createPath(Size size) {
    starPath.reset();
    circlePath.reset();
    double angle = 72;

    Offset middle = Offset(size.width / 2, size.height / 2);
    double radius = (size.width < size.height ? size.width : size.height) / 2;

    Offset top = middle.translate(0, -radius);
    Offset left = middle.translate(-radius * sin(angle.curve), -radius * cos(angle.curve));
    Offset right = middle.translate(radius * sin(angle.curve), -radius * cos(angle.curve));
    Offset leftBottom = middle.translate(-radius * sin((angle / 2).curve), radius * cos((angle / 2).curve));
    Offset rightBottom = middle.translate(radius * sin((angle / 2).curve), radius * cos((angle / 2).curve));

    circlePath.addArc(
      Rect.fromCircle(center: middle, radius: radius),
      (90 - angle).curve + pi,
      pi + 3.14159,
      // https://github.com/flutter/flutter/issues/107965
      // 2 * pi,
    );

    starPath.moveToPoint(left);
    starPath.lineToPoint(right);
    starPath.lineToPoint(leftBottom);
    starPath.lineToPoint(top);
    starPath.lineToPoint(rightBottom);
    starPath.lineToPoint(left);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller
        ..reset()
        ..forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(20);
    return Scaffold(
      appBar: AppBar(title: const Text('Effect')),
      body: AnimatedPath(
        padding: padding,
        paths: (size) {
          createPath(size);
          return [starPath, circlePath];
        },
        header: Container(
          color: Colors.orange,
          child: Text(
            'Effect',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        animation: tween.animate(curve),
        color: Theme.of(context).colorScheme.onSurface,
        strokeWidth: 5,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller
            ..reset()
            ..forward();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

extension RadiuExtension on num {
  double get curve => this * pi / 180;
}