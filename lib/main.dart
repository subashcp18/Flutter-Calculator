import 'dart:ui';

import 'package:calculator/buttons.dart';
import 'package:calculator/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemUiOverlayStyle(
    statusBarColor: Color.fromARGB(255, 208, 189, 243),
    systemNavigationBarColor: Color.fromARGB(255, 208, 189, 243),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
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
      print(data);
      historyss = data;
      print(historyss);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final bgColor = Color.fromARGB(255, 208, 189, 243);
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
                  child: InkWell(
                    splashColor: bgColor,
                    onTap: () {
                    setState(() {
                      history = false;
                    });
                  },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            child: Text(
                              userQuestion,
                              style: TextStyle(fontSize: 38),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          alignment: Alignment.centerRight,
                          child: Text(
                            userAnswer,
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  13.0, 0.0, 0.0, 10.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    history = !history;
                                  });
                                  print('tapped');
                                },
                                child: Icon(
                                  Icons.history_rounded,
                                  size: 33,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 3.5,
                          color: Colors.white,
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
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4),
                          padding: EdgeInsets.all(0),
                          physics: NeverScrollableScrollPhysics(),
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
                                buttonTapped: () {
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
                            } else if (index == buttons.length - 1) {
                              return MyButton(
                                buttonTapped: () {
                                  setState(() {
                                    equalPressed();
                                    _updateText();
                                    if (userQuestion.isNotEmpty) {
                                      db.insertHistory(
                                          userQuestion, userAnswer);
                                    }
                                    print("success");
                                    fetchAllHistory();
                                    // historyss.add({
                                    //   "question": userQuestion,
                                    //   "answer": userAnswer
                                    // });
                                  });
                                },
                                buttonText: buttons[index],
                                color: Colors.deepPurple,
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
                                    ? Colors.deepPurple
                                    : Colors.deepPurple[50],
                                textcolor: isOperator(buttons[index])
                                    ? Colors.white
                                    : Colors.deepPurple,
                              );
                            }
                          },
                        ),
                        AnimatedContainer(
                          width: screen.width * 0.72,
                          // height: screen.height - 100,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          transform: Matrix4.translationValues(
                              history ? 0 : -screen.width, 0, 0),
                          margin: EdgeInsets.only(right: 0, top: 0, bottom: 0),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[180],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 50.0),
                                    child: ListView.builder(
                                        itemCount: historyss.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(0),
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
                                      onTap: () {
                                        setState(() {
                                          // historyss.clear();
                                          db.deleteAllHistory();
                                          fetchAllHistory();
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 50,
                                        color: Colors.deepPurple,
                                        child: Center(
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
          print(answer);
          double val = double.parse(answer);
          int roundedValue = val.round();
          print(roundedValue);
          // print(val);
          userQuestion += roundedValue.toString();
          // equalPressed();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.0),
              child: Text(
                question,
                style: TextStyle(fontSize: 20, color: Colors.black54),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 5.0, top: 5.0),
              child: Text(
                "= " + answer,
                style: TextStyle(fontSize: 23, letterSpacing: 0.0),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.right,
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
