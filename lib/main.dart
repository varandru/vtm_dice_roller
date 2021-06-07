import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
        colorScheme: ColorScheme(
      primary: const Color(0xffC92F2F),
      primaryVariant: const Color(0xff97000D),
      onPrimary: const Color(0xffF3EED9),
      secondary: const Color(0xffA7777A),
      secondaryVariant: const Color(0xffC92F2F),
      onSecondary: Colors.amber,
      background: Colors.grey.shade900,
      onBackground: Colors.white,
      surface: Colors.grey.shade700,
      onSurface: Colors.white,
      error: Colors.yellow,
      onError: Colors.black,
      brightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: const MyHomePage(title: 'Dice Roller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _minDiceCount = 1;
  final _maxDiceCount = 20;
  final _minDifficulty = 2;
  final _maxDifficulty = 9;

  int _diceCount = 1;
  int _difficulty = 2;
  bool _isExploding = false;

  RichText _rollResult = RichText(
    text: const TextSpan(
      text: "",
    ),
  );
  int _successCount = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> diceScroll = [];
    List<Widget> difficultyScroll = [];

    for (int i = _minDiceCount; i < _maxDiceCount; i++) {
      diceScroll.add(TextWithNumber(i));
    }

    for (int i = _minDifficulty; i < _maxDifficulty; i++) {
      difficultyScroll.add(TextWithNumber(i));
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: [
                      Text(
                        "# Dice",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Flexible(
                        child: ListWheelScrollView(
                          itemExtent: 60.0,
                          children: diceScroll,
                          onSelectedItemChanged: (value) {
                            _diceCount = value + 1;
                          },
                          squeeze: 1.0,
                          physics: const FixedExtentScrollPhysics(),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Text(
                        "Difficulty",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Flexible(
                        child: ListWheelScrollView(
                          itemExtent: 60.0,
                          children: difficultyScroll,
                          onSelectedItemChanged: (value) {
                            _difficulty = value + _minDifficulty;
                          },
                          physics: const FixedExtentScrollPhysics(),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SwitchListTile(
              value: _isExploding,
              title: const Text("Do dice explode on 10?"),
              secondary: Icon(_isExploding
                  ? Icons.celebration
                  : Icons.celebration_outlined),
              onChanged: (value) => setState(() => _isExploding = value),
            ),
          ),
          Flexible(
            child: TextButton(
              onPressed: roll,
              child: Text(
                "Roll!",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ),
          Flexible(
            child: Center(
              child: _rollResult,
            ),
          ),
          Flexible(
            child: Text(
              "Successes: " + _successCount.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ],
      ),
    );
  }

  void roll() {
    setState(() {
      _successCount = 0;
      List<TextSpan> spans = [];

      for (int i = 0; i < _diceCount; i++) {
        int roll = Random().nextInt(10) + 1;
        // 1. Start a roll, in case of explosions, which I'll do later
        spans.add(const TextSpan(text: "("));
        if (roll == 1) {
          spans.add(TextSpan(
            text: roll.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w200,
              color: Colors.redAccent,
            ),
          ));
          _successCount--;
        } else if (roll >= _difficulty) {
          spans.add(TextSpan(
            text: roll.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ));
          _successCount++;

          while (_isExploding && roll == 10) {
            roll = Random().nextInt(10) + 1;
            spans.add(const TextSpan(text: " + "));
            if (roll == 1) {
              spans.add(TextSpan(
                text: roll.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w200,
                  color: Colors.redAccent,
                ),
              ));
              _successCount--;
            } else if (roll >= _difficulty) {
              spans.add(TextSpan(
                text: roll.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ));
              _successCount++;
            } else {
              spans.add(TextSpan(text: roll.toString()));
            }
          }
        } else {
          spans.add(TextSpan(text: roll.toString()));
        }
        // 2. Explosions handling goes here
        // 3. Finish roll
        spans.add(const TextSpan(text: ")"));
        if (i < _diceCount - 1) spans.add(const TextSpan(text: " + "));
      }
      _rollResult = RichText(
        text: TextSpan(
          text: '',
          style: Theme.of(context).textTheme.headline6,
          children: spans,
        ),
      );
    });
  }
}

class TextWithNumber extends StatelessWidget {
  const TextWithNumber(this.number, {Key? key}) : super(key: key);

  final int number;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        number.toString(),
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}
