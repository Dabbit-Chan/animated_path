library animated_path;

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class AnimatedPath extends StatefulWidget {
  const AnimatedPath({
    super.key,
    required this.paths,
    this.header,
    required this.color,
    this.strokeWidth = 1,
    this.strokeCap = StrokeCap.square,
    this.strokeJoin = StrokeJoin.miter,
    required this.animation,
    this.fps,
    this.padding = EdgeInsets.zero,
  });

  final List<Path> Function(Size size) paths;
  final Widget? header;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final Animation<double> animation;
  final int? fps;
  final EdgeInsetsGeometry padding;

  @override
  State<AnimatedPath> createState() => _AnimatedPathState();
}

class _AnimatedPathState extends State<AnimatedPath> {
  Timer? fpsTimer;
  Size? headerSize;
  List<ui.Offset> headerOffsets = [];

  bool get canPaint {
    if (widget.fps == null) {
      return true;
    }
    if (fpsTimer == null) {
      createTimer();
      return true;
    } else {
      return false;
    }
  }

  double tempProgress = 0;
  double get progress {
    if (canPaint) {
      tempProgress = widget.animation.value;
    }
    return tempProgress;
  }

  void createTimer() {
    fpsTimer = Timer(
      Duration(milliseconds: (1000 / widget.fps! ~/ 1)),
      () => fpsTimer = null,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(() {
      if (widget.animation.isCompleted) {
        tempProgress = 1;
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedPath oldWidget) {
    super.didUpdateWidget(oldWidget);
    tempProgress = 0;
    if (oldWidget.fps != widget.fps) {
      fpsTimer?.cancel();
      if (widget.fps != null) {
        createTimer();
      }
    }
  }

  @override
  void dispose() {
    fpsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      Size size = constraints.biggest;
      size = Size(
        size.width - widget.padding.horizontal,
        size.height - widget.padding.vertical,
      );
      List<Path> paths = widget.paths(size);

      return AnimatedBuilder(
        animation: widget.animation,
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Padding(
                padding: widget.padding,
                child: CustomPaint(
                  painter: _AnimatedPathPainter(
                    paths: paths,
                    header: widget.header,
                    color: widget.color,
                    strokeWidth: widget.strokeWidth,
                    strokeCap: widget.strokeCap,
                    strokeJoin: widget.strokeJoin,
                    progress: progress,
                    onProgressing: (value) {
                      headerOffsets = value;
                    },
                  ),
                ),
              ),
              if (widget.header != null)
                ...List.generate(headerOffsets.length, (index) {
                  return Positioned(
                    top: headerOffsets[index].dy -
                        (headerSize?.height ?? 0) / 2 +
                        widget.padding.vertical / 2,
                    left: headerOffsets[index].dx -
                        (headerSize?.width ?? 0) / 2 +
                        widget.padding.horizontal / 2,
                    child: _AfterLayout(
                      callback: (_RenderAfterLayout ral) {
                        headerSize = ral.size;
                      },
                      child: widget.header!,
                    ),
                  );
                }),
            ],
          );
        },
      );
    });
  }
}

class _AnimatedPathPainter extends CustomPainter {
  _AnimatedPathPainter({
    required this.paths,
    required this.header,
    required this.color,
    required this.strokeWidth,
    required this.strokeCap,
    required this.strokeJoin,
    required this.progress,
    required this.onProgressing,
  });

  final List<Path> paths;
  final Widget? header;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double progress;
  final Function(List<ui.Offset> headerOffsets) onProgressing;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..strokeJoin = strokeJoin
      ..style = PaintingStyle.stroke;

    List<ui.Offset> result = [];

    for (Path path in paths) {
      List<ui.PathMetric> pathMetrics = path.computeMetrics().toList();
      for (int i = 0; i < pathMetrics.length; i++) {
        ui.PathMetric pathMetric = pathMetrics[i];

        Path extractPath = pathMetric.extractPath(
          0,
          pathMetric.length * ui.clampDouble(progress, 0.0, 1.0),
        );

        ui.PathMetrics extraPathMetrics = extractPath.computeMetrics();

        ui.PathMetric? extraComputeMetrics = extraPathMetrics.firstOrNull;
        Offset? headPosition = extraComputeMetrics
            ?.getTangentForOffset(extraComputeMetrics.length)
            ?.position;

        if (extraComputeMetrics != null) {
          canvas.drawPath(
            extraComputeMetrics.extractPath(0, extraComputeMetrics.length),
            paint,
          );
          if (header != null) {
            result.add(headPosition!);
          }
        }
      }
    }

    onProgressing(result);
  }

  @override
  bool shouldRepaint(covariant _AnimatedPathPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.header != header ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.strokeJoin != strokeJoin;
  }
}

/// [https://book.flutterchina.club/chapter14/layout.html#_14-4-6-afterlayout]
class _AfterLayout extends SingleChildRenderObjectWidget {
  const _AfterLayout({
    required this.callback,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderAfterLayout(callback);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderAfterLayout renderObject) {
    renderObject.callback = callback;
  }

  ///组件树布局结束后会被触发，注意，并不是当前组件布局结束后触发
  final ValueSetter<_RenderAfterLayout> callback;
}

class _RenderAfterLayout extends RenderProxyBox {
  _RenderAfterLayout(this.callback);

  ValueSetter<_RenderAfterLayout> callback;

  @override
  void performLayout() {
    super.performLayout();
    // 不能直接回调callback，原因是当前组件布局完成后可能还有其他组件未完成布局
    // 如果callback中又触发了UI更新（比如调用了 setState）则会报错。因此，我们
    // 在 frame 结束的时候再去触发回调。
    SchedulerBinding.instance
        .addPostFrameCallback((timeStamp) => callback(this));
  }

  /// 组件在屏幕坐标中的起始点坐标（偏移）
  Offset get offset => localToGlobal(Offset.zero);

  /// 组件在屏幕上占有的矩形空间区域
  Rect get rect => offset & size;
}
