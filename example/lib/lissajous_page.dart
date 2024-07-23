import 'dart:isolate';
import 'dart:math';

import 'package:animated_path_builder/animated_path.dart';
import 'package:example/utils/platform_util.dart';
import 'package:flutter/material.dart';

class LissajousPage extends StatefulWidget {
  const LissajousPage({super.key});

  @override
  State<LissajousPage> createState() => _LissajousPageState();
}

class _LissajousPageState extends State<LissajousPage> with SingleTickerProviderStateMixin {
  // 數據
  final aCtrl = TextEditingController(text: '1');
  final bCtrl = TextEditingController(text: '1');
  final pCtrl = TextEditingController(text: '3');
  final qCtrl = TextEditingController(text: '4');
  final precisionCtrl = TextEditingController(text: '100');

  List<double> xList = [];
  List<double> yList = [];

  // 動畫
  late Size size;
  Path path = Path();
  late final AnimationController controller;
  late final CurvedAnimation curve;
  final Tween<double> tween = Tween(begin: 0, end: 1);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    curve = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: controller,
    );
  }

  @override
  void dispose() {
    aCtrl.dispose();
    bCtrl.dispose();
    pCtrl.dispose();
    qCtrl.dispose();
    precisionCtrl.dispose();
    controller.dispose();
    curve.dispose();
    super.dispose();
  }

  static (List<double>, List<double>) _isolate({
    required int a,
    required int b,
    required int p,
    required int q,
    required double phi,
    required double precision,
  }) {
    double theta = 0;
    List<double> xList2 = [];
    List<double> yList2 = [];

    do {
      double x = a * sin(p * theta);
      double y = b * sin(q * theta + phi);
      xList2.add(x);
      yList2.add(y);
      theta += precision;
    } while(theta <= 2 * pi);

    return (xList2, yList2);
  }

  void calc() async {
    try {
      int a = int.parse(aCtrl.text);
      int b = int.parse(bCtrl.text);
      int p = int.parse(pCtrl.text);
      int q = int.parse(qCtrl.text);
      int precision = int.parse(precisionCtrl.text);

      if (a == 0 || b == 0 || p == 0 || q == 0 || precision == 0) return;

      xList.clear();
      yList.clear();
      path.reset();

      (List<double>, List<double>) result;
      if (PlatformUtil.isWeb) {
        result = _isolate(
          a: a,
          b: b,
          p: p,
          q: q,
          phi: 0,
          precision: 1 / precision,
        );
      } else {
        result = await Isolate.run(() => _isolate(
          a: a,
          b: b,
          p: p,
          q: q,
          phi: 0,
          precision: 1 / precision,
        ));
      }

      xList = result.$1;
      yList = result.$2;

      double maxX = getMax(xList);
      double maxY = getMax(yList);
      Offset middle = Offset(size.width / 2, size.height / 2);

      double ratioX = middle.dx / maxX;
      double ratioY = middle.dy / maxY;
      double ratio = ratioX > ratioY ? ratioY : ratioX;

      path.moveTo(middle.dx, middle.dy);
      for (int i = 0; i < xList.length; i++) {
        path.lineTo(middle.dx + xList[i] * ratio, middle.dy + yList[i] * ratio);
      }
      path.close();

      controller
        ..reset()
        ..forward();
    } catch(_) {}
  }

  double getMax(List<double> list) {
    double max = 0;
    for (var i in list) {
      if (i.abs() > max) {
        max = i.abs();
      }
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Lissajous'),
        actions: [IconButton(
          onPressed: () {
            calc();
          },
          icon: const Icon(
            Icons.calculate_outlined,
          ),
        )],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                textField(
                  controller: aCtrl,
                  label: 'A',
                ),
                const SizedBox(width: 20),
                textField(
                  controller: bCtrl,
                  label: 'B',
                ),
                const SizedBox(width: 20),
                textField(
                  controller: pCtrl,
                  label: 'P',
                ),
                const SizedBox(width: 20),
                textField(
                  controller: qCtrl,
                  label: 'Q',
                ),
              ],
            ),
            const SizedBox(height: 20),
            textField(
              controller: precisionCtrl,
              label: 'Precision',
              needExpanded: false,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedPath(
                paths: (value) {
                  size = value;
                  return [path];
                },
                animation: tween.animate(curve),
                color: Theme.of(context).colorScheme.onSurface,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String label,
    bool needExpanded = true,
  }) {
    Widget child = TextField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );

    if (needExpanded) {
      child = Expanded(child: child);
    }

    return child;
  }
}
