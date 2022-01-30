import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0;
  var alarmTogglers = [
    false,
    false,
    false,
    false,
    false
  ];
  bool isStartStopWatch = false;
  late Timer stopWatchTimer;
  String stopWatchTitle = '00:00:00';
  String stopWatchTitleSeparator = ':';
  int countSecondsInMinute = 60;
  int initialSeconds = 0;
  int countMinutesInHour = 60;
  int initialMinutes = 60;
  String oneCharPrefix = "0";
  List<String> alarmsPopupMenuItemsHeaders = <String> [
    'Установить время отхода ко сну и пробуждения',
    'Изменить',
    'Сортировать',
    'Настройки',
    'Свяжитесь с нами'
  ];
  List<String> worldTimePopupMenuItemsHeaders = <String>[
    "Изменить",
    "Конвертер часовых поясов",
    "Настройки",
    "Свяжитесь с нами"
  ];
  List<String> stopWatchPopupMenuItemsHeaders = <String>[
    "Список последних кругов",
    "Настройки",
    "Свяжитесь с нами"
  ];
  List<String> timerPopupMenuItemsHeaders = <String>[
    "Изменить установленные таймеры",
    "Настройки",
    "Свяжитесь с нами"
  ];
  List<Widget> alarms = [];
  List<Object> havedAlarms = [];
  List<Widget> worldTimes = [];
  List<Object> havedWorldTimes = [];
  List<Widget> customTimers = [];
  List<Object> havedCustomTimers = [];
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void addAlarm () {
    alarms.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
                child: Text(
                    '06:18',
                    style: TextStyle(
                        fontSize: 24
                    )
                )
            ),
            Container(
              child: Text(
                  'пн, 31 янв.'
              ),
            ),
            Switch(
                value: alarmTogglers[0],
                onChanged: (bool value) => {
                  setState(() {
                    alarmTogglers[0] = value;
                  })
                }
            ),
          ],
        )
    );
  }

  void addWorldTime () {
    worldTimes.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
              child: Column(
                children: <Widget>[
                  Text(
                      'Афины',
                      style: TextStyle(
                          fontSize: 24
                      )
                  ),
                  Text(
                      'на 1 час раньше'
                  )
                ],
              )
          ),
          Container(
            child: Text(
                '15:26',
                style: TextStyle(
                    fontSize: 24
                )
            ),
          ),
          Column(
            children: <Widget>[
              Image.asset(
                  'assets/weather.png',
                  width: 25
              ),
              Text(
                  '2*'
              )
            ],
          )
        ],
      )
    );
  }

  void addCustomTimer() {
    customTimers.add(
        GestureDetector(
          onTap: () {

          },
          child: Container(
              alignment: Alignment.center,
              height: 100.0,
              width: 100.0,
              margin: EdgeInsets.only(
                  top: 50,
                  bottom: 50,
                  left: 15,
                  right: 15
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 200, 200, 200),
                borderRadius: BorderRadius.circular(45),
              ),
              child: Text(
                  "00:00:00"
              )
          )
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    havedAlarms.toList().map((Object havedAlarm) {
      addAlarm();
    });

    havedWorldTimes.toList().map((Object havedWorldTime) {
      addWorldTime();
    });

    return DefaultTabController(
        initialIndex: 1,
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Будильник'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  text: 'Будильник'
                ),
                Tab(
                    text: 'Мировое время'
                ),
                Tab(
                    text: 'Секундомер'
                ),
                Tab(
                    text: 'Таймер'
                ),
                Tab(
                    text: 'Запущенный таймер'
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                      "Все будильники\nотключены",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24
                      ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          addAlarm();
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                bottom: 15,
                                top: 15,
                                left: 25,
                                right: 25
                            ),
                            child: Icon(
                                Icons.add
                            )
                        )
                      ),
                      Container(
                          margin: EdgeInsets.only(
                              bottom: 15,
                              top: 15,
                              left: 25,
                              right: 25
                          ),
                          child: PopupMenuButton(
                              itemBuilder: (BuildContext context) {
                                return alarmsPopupMenuItemsHeaders.map((String alarmsPopupMenuItemsHeader) {
                                  return  PopupMenuItem<String>(
                                    value: alarmsPopupMenuItemsHeader,
                                    child: Text(alarmsPopupMenuItemsHeader),
                                  );}
                                ).toList();
                              },
                              child: Icon(
                                  Icons.more_vert
                              )
                          )
                      )
                    ],
                  ),
                  SingleChildScrollView(
                    child: Container(
                        height: 300,
                        child: Column(
                          children: alarms
                        )
                    )
                  )
                ]
              ),
              Column(
                  children: <Widget>[
                    Text(
                      'Мировое время',
                      style: TextStyle(
                          fontSize: 24
                      ),
                    ),
                    Text(
                      'Москва, стандартное время'
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 15,
                              top: 15,
                              left: 25,
                              right: 25
                            ),
                            child: Icon(
                              Icons.add
                            )
                          ),
                          onPressed: () {
                            addWorldTime();
                          },
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                bottom: 15,
                                top: 15,
                                left: 25,
                                right: 25
                            ),
                            child: PopupMenuButton(
                                itemBuilder: (BuildContext context) {
                                  return worldTimePopupMenuItemsHeaders.map((String worldTimePopupMenuItemsHeader) {
                                    return  PopupMenuItem<String>(
                                      value: worldTimePopupMenuItemsHeader,
                                      child: Text(worldTimePopupMenuItemsHeader),
                                    );}
                                  ).toList();
                                },
                                child: Icon(
                                    Icons.more_vert
                                )
                            )
                        )
                      ],
                    ),
                    Column(
                      children: worldTimes,
                    )
                  ]
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(
                              bottom: 15,
                              top: 15,
                              left: 25,
                              right: 25
                          ),
                          child: PopupMenuButton(
                            itemBuilder: (BuildContext context) {
                              return stopWatchPopupMenuItemsHeaders.map((String stopWatchPopupMenuItemsHeader) {
                                return  PopupMenuItem<String>(
                                  value: stopWatchPopupMenuItemsHeader,
                                  child: Text(stopWatchPopupMenuItemsHeader),
                                );}
                              ).toList();
                            },
                            child: Icon(
                                Icons.more_vert
                            )
                          )
                      )
                    ],
                  ),
                  Text(
                    stopWatchTitle,
                    style: TextStyle(
                        fontSize: 36
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 350,
                      bottom: 50,
                      left: 0,
                      right: 0
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        TextButton(
                          style: ButtonStyle(
                              textStyle: MaterialStateProperty.all(
                                  TextStyle(
                                      fontSize: 18
                                  )
                              ),
                              backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 225, 225, 225)),
                              foregroundColor: MaterialStateProperty.all(Color.fromARGB(255, 150, 150, 150)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.transparent
                                      )
                                  )
                              ),
                              fixedSize: MaterialStateProperty.all<Size>(
                                  Size(
                                      100.0,
                                      45.0
                                  )
                              )
                          ),
                          onPressed: () {

                          },
                          child: Text(
                              'Интервал'
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              textStyle: MaterialStateProperty.all(
                                  TextStyle(
                                      fontSize: 18
                                  )
                              ),
                              backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 0, 0, 225)),
                              foregroundColor: MaterialStateProperty.all(Color.fromARGB(255, 255, 255, 255)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.transparent)
                                  )
                              ),
                              fixedSize: MaterialStateProperty.all<Size>(
                                  Size(
                                      100.0,
                                      45.0
                                  )
                              )
                          ),
                          onPressed: () {
                            bool isNotStart = !isStartStopWatch;
                            if (isNotStart) {
                              stopWatchTimer = new Timer.periodic(const Duration(seconds: 1), (Timer timer) {
                                /*setState(() {
                                  stopWatchTitle = "00:00:00";
                                });*/
                                List<String> timeParts = stopWatchTitle.split(stopWatchTitleSeparator);
                                String rawHours = timeParts[0];
                                String rawMinutes = timeParts[1];
                                String rawSeconds = timeParts[2];
                                int hours = rawHours as int;
                                int minutes = rawMinutes as int;
                                int seconds = rawSeconds as int;
                                seconds++;
                                bool isToggleSecond = seconds == countSecondsInMinute;
                                if (isToggleSecond) {
                                  seconds = initialSeconds;
                                  minutes++;
                                  bool isToggleHour = minutes == countMinutesInHour;
                                  if (isToggleHour) {
                                    minutes = initialMinutes;
                                    hours++;
                                  }
                                }
                                String updatedHoursText = hours as String;
                                int countHoursChars = updatedHoursText.length;
                                bool isAddHoursPrefix = countHoursChars == 1;
                                if (isAddHoursPrefix) {
                                  updatedHoursText = oneCharPrefix + updatedHoursText;
                                }
                                String updatedMinutesText = minutes as String;
                                int countMinutesChars = updatedMinutesText.length;
                                bool isAddMinutesPrefix = countMinutesChars == 1;
                                if (isAddMinutesPrefix) {
                                  updatedMinutesText = oneCharPrefix + updatedMinutesText;
                                }
                                String updatedSecondsText = seconds as String;
                                int countSecondsChars = updatedSecondsText.length;
                                bool isAddSecondsPrefix = countSecondsChars == 1;
                                if (isAddSecondsPrefix) {
                                  updatedSecondsText = oneCharPrefix + updatedSecondsText;
                                }
                                String currentTime = updatedHoursText + ":" + updatedMinutesText + ":" + updatedSecondsText;
                                setState(() {
                                  stopWatchTitle = currentTime;
                                });

                              });

                            } else {
                              setState(() {
                                stopWatchTitle = new Random().nextInt(5000).toString();
                              });
                            }
                            setState(() {
                              isStartStopWatch = !isStartStopWatch;
                            });
                          },
                          child: Text(
                              'Начать'
                          ),
                        )
                      ],
                    )
                  )
                ]
              ),
              Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 15,
                              top: 15,
                              left: 25,
                              right: 25
                            ),
                            child: Icon(
                                Icons.add
                            )
                          ),
                          onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Добавление готового таймера'),
                                  content: Container(
                                    height: 300,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: TextField(

                                          ),
                                          padding: EdgeInsets.only(
                                              top: 25,
                                              bottom: 25,
                                              left: 0,
                                              right: 0
                                          ),
                                          margin: EdgeInsets.only(
                                            top: 25,
                                            bottom: 25,
                                            left: 0,
                                            right: 0
                                          ),
                                        ),
                                        Container(
                                          child: TextField(
                                              decoration: new InputDecoration.collapsed(
                                                  hintText: 'Название готового таймера',
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 1.0
                                                      )
                                                  )
                                              )
                                          ),
                                          padding: EdgeInsets.only(
                                              top: 25,
                                              bottom: 25,
                                              left: 0,
                                              right: 0
                                          ),
                                          margin: EdgeInsets.only(
                                              top: 25,
                                              bottom: 25,
                                              left: 0,
                                              right: 0
                                          ),
                                        )
                                      ],
                                    )
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Отмена')
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        addCustomTimer();
                                        return Navigator.pop(context, 'OK');
                                      },
                                      child: const Text('Добавить')
                                    )
                                  ],
                                )
                            );
                          },
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                bottom: 15,
                                top: 15,
                                left: 25,
                                right: 25
                            ),
                            child: PopupMenuButton(
                              itemBuilder: (BuildContext context) {
                                return timerPopupMenuItemsHeaders.map((String timerPopupMenuItemsHeader) {
                                  return  PopupMenuItem<String>(
                                    value: timerPopupMenuItemsHeader,
                                    child: Text(timerPopupMenuItemsHeader),
                                  );
                                }).toList();
                              },
                            child: Icon(
                              Icons.more_vert
                            )
                          )
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                  'ч.'
                              ),
                            ),
                            Container(
                                child: Text(
                                    '00',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                            Container(
                                child: Text(
                                    '01',
                                    style: TextStyle(
                                        fontSize: 24
                                    )
                                )
                            ),
                            Container(
                              child: Text(
                                  '02',
                                  style: TextStyle(
                                      fontSize: 24
                                  )
                              )
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: Text(
                                  'мин.'
                              ),
                            ),
                            Container(
                                child: Text(
                                    '00',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                            Container(
                                child: Text(
                                    '01',
                                    style: TextStyle(
                                        fontSize: 24
                                    )
                                )
                            ),
                            Container(
                                child: Text(
                                    '02',
                                    style: TextStyle(
                                        fontSize: 24
                                    )
                                )
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: Text(
                                  'сек.'
                              ),
                            ),
                            Container(
                                child: Text(
                                    '00',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold
                                    )
                                )
                            ),
                            Container(
                                child: Text(
                                    '01',
                                    style: TextStyle(
                                        fontSize: 24
                                    )
                                )
                            ),
                            Container(
                                child: Text(
                                    '02',
                                    style: TextStyle(
                                        fontSize: 24
                                    )
                                )
                            )
                          ],
                        )
                      ],
                    ),
                    SingleChildScrollView(
                      child: Row(
                        children: customTimers,
                      )
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 115,
                        bottom: 0,
                        left: 0,
                        right: 0
                      ),
                      child: TextButton(
                        onPressed: () {

                        },
                        style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                TextStyle(
                                    fontSize: 18
                                )
                            ),
                            backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 0, 0, 225)),
                            foregroundColor: MaterialStateProperty.all(Color.fromARGB(255, 255, 255, 255)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: Colors.transparent)
                                )
                            ),
                            fixedSize: MaterialStateProperty.all<Size>(
                                Size(
                                    100.0,
                                    45.0
                                )
                            )
                        ),
                        child: Text(
                          'Начать'
                        ),
                      )
                    )
                  ]
              ),
              Column(
                children: <Widget>[
                  Text(
                    'Запущенный таймер'
                  )
                ],
              )
            ],
          )
        )
    );
  }
}