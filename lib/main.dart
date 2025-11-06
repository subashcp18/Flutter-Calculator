import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:calculator/buttons.dart';
import 'package:calculator/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  int index = 0;

  final List<Map<String, Color>> colorThemes = [
    {
      'buttonColor': Color(0xFFDCE0D9),
      'buttonSecondary': Color(0xFFEAD7C3),
      'backgroundColor': Color(0xFFFBF6EF),
      'textColor': Colors.black,
    },
    {
      'buttonColor': Color(0xFFDDBEA9),
      'buttonSecondary': Color(0xFFCB997E),
      'backgroundColor': Color(0xFFFFE8D6),
      'textColor': Colors.white,
    },
    {
      'buttonColor': Color(0xFFB8B8FF),
      'buttonSecondary': Color(0xFF9381FF),
      'backgroundColor': Color(0xFFF8F7FF),
      'textColor': Colors.white,
    },
    {
      'buttonColor': Color(0xFF14213D),
      'buttonSecondary': Color(0xFFFCA311),
      'backgroundColor': Color(0xFF000000),
      'textColor': Colors.white,
    },
    {
      'buttonColor': Color.fromRGBO(52, 28, 79, 1),
      'buttonSecondary': Color.fromRGBO(88, 7, 125, 1),
      'backgroundColor': Color.fromRGBO(22, 6, 40, 1),
      'textColor': Colors.white,
    }
  ];

  Color buttonColor = Color(0xFFDCE0D9);
  Color buttonSecondary = Color(0xFFEAD7C3);
  Color backgroundColor = Color(0xFFFBF6EF);
  Color textColor = Colors.black87;

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
    getSavedThemeIndex();
    fetchAllHistory();
  }

  Future<void> saveThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', index);
    print('Theme index $index saved');
  }

  void getSavedThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('themeIndex') ?? 4;
    setState(() {
      this.index = index;
      setTheme(index);
    });
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

  void setTheme(int index) {
    buttonColor = colorThemes[index]['buttonColor']!;
    buttonSecondary = colorThemes[index]['buttonSecondary']!;
    backgroundColor = colorThemes[index]['backgroundColor']!;
    textColor = colorThemes[index]['textColor']!;
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
    final bgColor = backgroundColor;
    return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: AnnotatedRegion(
            value: SystemUiOverlayStyle(
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
                          alignment: Alignment.centerRight,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            child: Text(
                              userQuestion,
                              style: TextStyle(
                                  fontSize: 38,
                                  color: bgColor == Colors.black || bgColor == Color.fromRGBO(22, 6, 40, 1)
                                      ? Colors.white
                                      : Colors.black),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.centerRight,
                          child: Text(
                            userAnswer,
                            style: TextStyle(
                                fontSize: 30,
                                color: bgColor == Colors.black || bgColor == Color.fromRGBO(22, 6, 40, 1)
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    history = !history;
                                  });
                                },
                                child: Icon(
                                  Icons.history_rounded,
                                  size: 33,
                                  color: buttonSecondary,
                                ),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (index < colorThemes.length - 1) {
                                        index++;
                                        setTheme(index);
                                        saveThemeIndex(index);
                                      } else {
                                        index = 0;
                                        setTheme(index);
                                        saveThemeIndex(index);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    Icons.color_lens_outlined,
                                    size: 30,
                                    color: buttonSecondary,
                                  ))
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.5,
                          color: buttonSecondary.withOpacity(0.2),
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
                                textcolor: textColor,
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
                                textcolor: textColor,
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
                                // color: const Color.fromRGBO(52, 28, 79, 1),
                                color: buttonColor,
                                textcolor: textColor,
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
                                // color: const Color.fromRGBO(88, 7, 125, 1),
                                color: buttonSecondary,
                                textcolor: textColor,
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
                                    ? buttonSecondary
                                    : buttonColor,
                                // ? const Color.fromRGBO(88, 7, 125, 1)
                                // : const Color.fromRGBO(52, 28, 79, 1),
                                textcolor: textColor,
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
                            // color: const Color.fromRGBO(88, 7, 125, 0.2),
                            color: buttonSecondary.withOpacity(0.2),
                            // color: Colors.deepPurple[180],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1.0,
                              color: buttonSecondary.withOpacity(0.2),
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
                                        color: buttonColor,
                                        child: Center(
                                          child: Text(
                                            "Clear History",
                                            style: TextStyle(
                                              color: textColor,
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
                style: TextStyle(
                    fontSize: 20,
                    // color: Colors.black54
                    color: textColor.withOpacity(0.6)),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
              child: Text(
                "= $answer",
                style: TextStyle(
                    fontSize: 23, letterSpacing: 0.0, color: textColor),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.right,
              ),
            ),
            Divider(
              height: 1.0,
              color: textColor.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
