# Animated Path

An Animated Widget for create path animation

## Showcase

<img src="https://raw.githubusercontent.com/Dabbit-Chan/animated_path/main/gifs/DrawBoardCase.gif" width=60%>
<img src="https://raw.githubusercontent.com/Dabbit-Chan/animated_path/main/gifs/LissajousCase.gif" width=60%>
<img src="https://raw.githubusercontent.com/Dabbit-Chan/animated_path/main/gifs/EffectCase.gif" width=60%>

## Features

- Support list of path
- `header` for customise effect
- `fps` for better performance

## Getting started

`import 'package:animated_path_builder/animated_path.dart';`

## Usage

First you need to create a list of `Path` and create an `AnimationController` to control the animation.

Here is a minimalist example.

```dart
AnimatedPath(
  paths: (size) => createPath(size),
  animation: animation,
  color: Colors.black,
)
```

You can also add a header to create some effect with that animation.

```dart
AnimatedPath(
  paths: (size) => createPath(size),
  header: HeaderEffect(),
  animation: animation,
  color: Colors.black,
)
```

If performance is suffering due to overly complex paths, you can use `fps` to control this.

```dart
AnimatedPath(
  paths: (size) => createPath(size),
  animation: animation,
  color: Colors.black,
  fps: 60,
)
```
Check [example](https://github.com/Dabbit-Chan/animated_path/tree/main/example) for more.
