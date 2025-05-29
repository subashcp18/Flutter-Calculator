import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:calculator/buttons.dart';
import 'package:calculator/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var userQuestion = '';
  var userAnswer = '';
  bool history = false;
  List historyss = [];
  final player = AudioPlayer();
  DatabaseHelper db = DatabaseHelper();

  final List<String> buttons = [
    'C',
    'DEL',
    '%',
    '/',
    '7',
    '8',
    '9',
    'X',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '.',
    '0',
    'ANS',
    '=',
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchAllHistory();
  }

  void fetchAllHistory() async {
    final data = await db.fetchHistory();
    setState(() {
      historyss = data;
    });
  }

  void _updateText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    // final bgColor = Color.fromARGB(255, 208, 189, 243);
    const bgColor = Color.fromRGBO(22, 6, 40, 1);
    return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: AnnotatedRegion(
            value: const SystemUiOverlayStyle(
              statusBarColor: bgColor,
              systemNavigationBarColor: bgColor,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        history = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        const SizedBox(
                          height: 50,
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            child: Text(
                              userQuestion,
                              style: const TextStyle(
                                  fontSize: 38, color: Colors.white),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.centerRight,
                          child: Text(
                            userAnswer,
                            style: const TextStyle(
                                fontSize: 30, color: Colors.white),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  13.0, 0.0, 0.0, 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    history = !history;
                                  });
                                },
                                child: const Icon(
                                  Icons.history_rounded,
                                  size: 33,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 3.5,
                          color: Colors.white38,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        GridView.builder(
                          itemCount: buttons.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4),
                          padding: const EdgeInsets.all(0),
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return MyButton(
                                buttonTapped: () {
                                  setState(() {
                                    userQuestion = '';
                                    userAnswer = '';
                                  });
                                },
                                buttonText: buttons[index],
                                color: Colors.green,
                                textcolor: Colors.white,
                              );
                            } else if (index == 1) {
                              return MyButton(
                                buttonTapped: () async {
                                  setState(() {
                                    userQuestion = userQuestion.substring(
                                        0, userQuestion.length - 1);
                                  });
                                  _updateText();
                                },
                                buttonText: buttons[index],
                                color: Colors.red,
                                textcolor: Colors.white,
                              );
                            } else if (index == buttons.length - 2) {
                              return MyButton(
                                buttonTapped: () async {
                                  setState(() {
                                    equalPressed();
                                    _updateText();
                                    if (userQuestion.isNotEmpty) {
                                      db.insertHistory(
                                          userQuestion, userAnswer);
                                    }
                                    fetchAllHistory();
                                  });
                                },
                                buttonText: buttons[index],
                                color: const Color.fromRGBO(52, 28, 79, 1),
                                textcolor: Colors.white,
                              );
                            } else if (index == buttons.length - 1) {
                              return MyButton(
                                buttonTapped: () async {
                                  await player.play(AssetSource('tap.wav'));
                                  setState(() {
                                    equalPressed();
                                    _updateText();
                                    if (userQuestion.isNotEmpty) {
                                      db.insertHistory(
                                          userQuestion, userAnswer);
                                    }
                                    fetchAllHistory();
                                  });
                                },
                                buttonText: buttons[index],
                                color: const Color.fromRGBO(88, 7, 125, 1),
                                textcolor: Colors.white,
                              );
                            } else {
                              return MyButton(
                                buttonTapped: () {
                                  setState(() {
                                    userQuestion += buttons[index];
                                  });
                                  _updateText();
                                },
                                buttonText: buttons[index],
                                color: isOperator(buttons[index])
                                    ? const Color.fromRGBO(88, 7, 125, 1)
                                    : const Color.fromRGBO(52, 28, 79, 1),
                                textcolor: Colors.white,
                              );
                            }
                          },
                        ),
                        AnimatedContainer(
                          width: screen.width * 0.72,
                          // height: screen.height - 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          transform: Matrix4.translationValues(
                              history ? 0 : -screen.width, 0, 0),
                          margin: const EdgeInsets.only(
                              right: 0, top: 0, bottom: 0),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(88, 7, 125, 0.2),
                            // color: Colors.deepPurple[180],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1.0,
                              color: Colors.white38,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 50.0),
                                    child: ListView.builder(
                                        itemCount: historyss.length,
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.all(0),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return buildhist(
                                            historyss[index]["question"],
                                            historyss[index]["answer"],
                                          );
                                        }),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await player
                                            .play(AssetSource('tap.wav'));
                                        setState(() {
                                          db.deleteAllHistory();
                                          fetchAllHistory();
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 50,
                                        color: Colors.deepPurple,
                                        child: const Center(
                                          child: Text(
                                            "Clear History",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  bool isOperator(String x) {
    if (x == '%' || x == '/' || x == 'X' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

  void equalPressed() {
    if (userQuestion != '') {
      String finalQuestion = userQuestion;
      finalQuestion = finalQuestion.replaceAll('X', '*');
      Parser p = Parser();
      Expression exp = p.parse(finalQuestion);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      userAnswer = eval.toString();
    } else {
      setState(() {
        userAnswer = '';
      });
    }
  }

  buildhist(String question, String answer) {
    return GestureDetector(
      onTap: () {
        setState(() {
          double val = double.parse(answer);
          int roundedValue = val.round();
          userQuestion += roundedValue.toString();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(
                question,
                style: const TextStyle(
                    fontSize: 20,
                    // color: Colors.black54
                    color: Colors.white60),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
              child: Text(
                "= $answer",
                style: const TextStyle(
                    fontSize: 23, letterSpacing: 0.0, color: Colors.white),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.right,
              ),
            ),
            const Divider(
              height: 1.0,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
