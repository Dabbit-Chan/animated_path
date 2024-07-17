import 'package:example/draw_board_page.dart';
import 'package:example/lissajous_page.dart';
import 'package:example/mahou_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Path',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Animated Path'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            listTile(title: 'Draw Board', target: const DrawBoardPage()),
            listTile(title: 'Lissajous', target: const LissajousPage()),
            listTile(title: 'Effect', target: const MaHouPage())
          ],
        ),
      ),
    );
  }

  Widget listTile({
    required String title,
    required Widget target,
  }) {
    return ListTile(
      title: Text(title,),
      trailing: const Icon(
          Icons.chevron_right
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => target,
          ),
        );
      },
    );
  }
}
