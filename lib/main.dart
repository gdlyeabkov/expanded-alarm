import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// import 'package:appspector/appspector.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

/*void runAppSpector() {
  final config = Config()
    ..iosApiKey = "Your iOS API_KEY"
    ..androidApiKey = "Your Android API_KEY";

  // If you don't want to start all monitors you can specify a list of necessary ones
  config.monitors = [Monitors.http, Monitors.logs, Monitors.screenshot];

  AppSpectorPlugin.run(config);
}*/

void main() async {
  // runAppSpector();
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/main': (context) => const MyHomePage(
            title: 'Flutter Demo Home Page'
        ),
        '/add_alarm': (context) => AddAlarmPage(),
        '/add_world_time': (context) => AddWorldTimePage(),
        '/started_timer': (context) => StartedTimerPage()
      },
      initialRoute: '/main',
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


  late DatabaseHandler handler;
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
  var weekDayLabels = <String, String>{
    'Monday': 'пн',
    'Tuesday': 'вт',
    'Wednesday': 'ср',
    'Thursday': 'чт',
    'Friday': 'пт',
    'Saturday': 'сб',
    'Sunday': 'вс'
  };
  var monthsLabels = <int, String>{
    0: 'янв.',
    1: 'февр.',
    2: 'мар.',
    3: 'апр.',
    4: 'мая',
    5: 'июн.',
    6: 'июл.',
    7: 'авг.',
    8: 'сен.',
    9: 'окт.',
    10: 'ноя.',
    11: 'дек'
  };
  bool isStartTimer = false;
  String stopWatchStartBtnStopLabel = 'Стоп';
  String stopWatchStartBtnStartLabel = 'Начать';
  String stopWatchStartBtnResumeLabel = 'Продолж.';
  String stopWatchStartBtnTitle = '';
  String stopWatchIntervalBtnResetLabel = 'Сбросить';
  String stopWatchIntervalBtnIntervalLabel = 'Интервал';
  String stopWatchIntervalBtnTitle = '';
  bool isStopWatchIntervalBtnDisalbled = true;
  List<Widget> intervals = [];
  Timer? stopWatchCircleTimer = null;
  int circleHours = 0;
  int circleMinutes = 0;
  int circleSeconds = 0;
  ScrollController timerHoursController = ScrollController();
  List<double> hoursLabelsStyles = [
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24
  ];
  late Column timerHoursColumn;
  ScrollController timerMinutesController = ScrollController();
  List<double> minutesLabelsStyles = [
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24
  ];
  late Column timerMinutesColumn;
  ScrollController timerSecondsController = ScrollController();
  List<double> secondsLabelsStyles = [
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24
  ];
  late Column timerSecondsColumn;
  String newCustomTimerHours = '00';
  String newCustomTimerMinutes = '00';
  String newCustomTimerSeconds = '00';
  String newCustomTimerName = '';
  int customActiveTimer = -1;
  String startTimerTitle = '00:00:00';
  late Timer startedTimer;
  int startedTimerSeconds = 0;
  int startedTimerMinutes = 0;
  int startedTimerHours = 0;
  String startedTimerPauseLabel = 'Пауза';
  String startedTimerResumeLabel = 'Продолж.';
  String startedTimerPauseBtnContent = 'Пауза';

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      // await this.deleteAlarms();
      setState(() {
        stopWatchIntervalBtnTitle = stopWatchIntervalBtnIntervalLabel;
        stopWatchStartBtnTitle = stopWatchStartBtnStartLabel;
      });
    });

    timerHoursColumn = Column(
        children: <Widget>[
          Container(
              child: Text(
                  '00',
                  style: TextStyle(
                    fontSize: hoursLabelsStyles[0]
                  )
              )
          ),
          Container(
              child: Text(
                  '01',
                  style: TextStyle(
                    fontSize: hoursLabelsStyles[1]
                  )
              )
          ),
          Container(
              child: Text(
                '02',
                style: TextStyle(
                    fontSize: hoursLabelsStyles[2]
                )
              )
          ),
          Container(
              child: Text(
                  '03',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[3]
                  )
              )
          ),
          Container(
              child: Text(
                  '04',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[4]
                  )
              )
          ),
          Container(
              child: Text(
                  '05',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[5]
                  )
              )
          ),
          Container(
              child: Text(
                  '06',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[6]
                  )
              )
          ),
          Container(
              child: Text(
                  '07',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[7]
                  )
              )
          ),
          Container(
              child: Text(
                  '08',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[8]
                  )
              )
          ),
          Container(
              child: Text(
                  '09',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[9]
                  )
              )
          ),
          Container(
              child: Text(
                  '10',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[10]
                  )
              )
          ),
          Container(
              child: Text(
                  '11',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[11]
                  )
              )
          ),
          Container(
              child: Text(
                  '12',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[12]
                  )
              )
          ),
          Container(
              child: Text(
                  '13',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[13]
                  )
              )
          ),
          Container(
              child: Text(
                  '14',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[14]
                  )
              )
          ),
          Container(
              child: Text(
                  '15',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[15]
                  )
              )
          ),
          Container(
              child: Text(
                  '16',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[16]
                  )
              )
          ),
          Container(
              child: Text(
                  '17',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[17]
                  )
              )
          ),
          Container(
              child: Text(
                  '18',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[18]
                  )
              )
          ),
          Container(
              child: Text(
                  '19',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[19]
                  )
              )
          ),
          Container(
              child: Text(
                  '20',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[20]
                  )
              )
          ),
          Container(
              child: Text(
                  '21',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[21]
                  )
              )
          ),
          Container(
              child: Text(
                  '22',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[22]
                  )
              )
          ),
          Container(
              child: Text(
                  '23',
                  style: TextStyle(
                      fontSize: hoursLabelsStyles[23]
                  )
              )
          )
        ]
    );

    timerHoursController.addListener(() {
      double offsetTop = timerHoursController.position.pixels;
      double correctOffsetTop = offsetTop / 15;
      List<Widget> hoursLabels = timerHoursColumn.children;
      int possibleOffsetTop = correctOffsetTop.toInt();
      String rawPossibleOffsetTop = possibleOffsetTop.toString();
      print('debug: ${rawPossibleOffsetTop}');
      setState(() {
        this.hoursLabelsStyles[possibleOffsetTop] = 24;
        newCustomTimerHours = ((hoursLabels[possibleOffsetTop] as Container).child as Text).data.toString();
      });
    });

    timerMinutesColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
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
        ),
        Container(
            child: Text(
                '03',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '04',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '05',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '06',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '07',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '08',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '09',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '10',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '11',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '12',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '13',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '14',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '15',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '16',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '17',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '18',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '19',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '20',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '21',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '22',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '23',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '24',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '25',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '26',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '27',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '28',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '29',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '30',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '31',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '32',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '33',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '34',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '35',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '36',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '37',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '38',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '39',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '40',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '41',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '42',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '43',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '44',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '45',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '46',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '47',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '48',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '49',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '50',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '51',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '52',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '53',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '54',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '55',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '56',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '57',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '58',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '59',
                style: TextStyle(
                    fontSize: 24
                )
            )
        )
      ],
    );

    timerMinutesController.addListener(() {
      double offsetTop = timerMinutesController.position.pixels;
      double correctOffsetTop = offsetTop / 15;
      List<Widget> minutesLabels = timerMinutesColumn.children;
      int possibleOffsetTop = correctOffsetTop.toInt();
      String rawPossibleOffsetTop = possibleOffsetTop.toString();
      print('debug: ${rawPossibleOffsetTop}');
      setState(() {
        this.minutesLabelsStyles[possibleOffsetTop] = 24;
        newCustomTimerMinutes = ((minutesLabels[possibleOffsetTop] as Container).child as Text).data.toString();
      });
    });

    timerSecondsColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
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
        ),
        Container(
            child: Text(
                '03',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '04',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '05',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '06',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '07',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '08',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '09',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '10',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '11',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '12',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '13',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '14',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '15',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '16',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '17',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '18',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '19',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '20',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '21',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '22',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '23',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '24',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '25',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '26',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '27',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '28',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '29',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '30',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '31',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '32',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '33',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '34',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '35',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '36',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '37',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '38',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '39',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '40',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '41',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '42',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '43',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '44',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '45',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '46',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '47',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '48',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '49',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '50',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '51',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '52',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '53',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '54',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '55',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '56',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '57',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '58',
                style: TextStyle(
                    fontSize: 24
                )
            )
        ),
        Container(
            child: Text(
                '59',
                style: TextStyle(
                    fontSize: 24
                )
            )
        )
      ],
    );

    timerSecondsController.addListener(() {
      double offsetTop = timerSecondsController.position.pixels;
      double correctOffsetTop = offsetTop / 15;
      List<Widget> secondsLabels = timerSecondsColumn.children;
      int possibleOffsetTop = correctOffsetTop.toInt();
      String rawPossibleOffsetTop = possibleOffsetTop.toString();
      print('debug: ${rawPossibleOffsetTop}');
      setState(() {
        this.secondsLabelsStyles[possibleOffsetTop] = 24;
        newCustomTimerSeconds = ((secondsLabels[possibleOffsetTop] as Container).child as Text).data.toString();
      });
    });

  }

  Future<void> deleteAlarms() async {
    return await this.handler.deleteAlarms();
  }

  void addAlarm (Alarm alarm) {
    String alarmTime = alarm.time;
    String alarmDate = alarm.date;
    String rawAlarmYear = alarm.date.split('/')[2];
    String rawAlarmMonth = alarm.date.split('/')[1];
    if (rawAlarmMonth.length == 1) {
      rawAlarmMonth = '0${rawAlarmMonth}';
    }
    String rawAlarmDay = alarm.date.split('/')[0];
    if (rawAlarmDay.length == 1) {
      rawAlarmDay = '0${rawAlarmDay}';
    }

    DateTime parsedAlarmDate = DateTime.parse('${rawAlarmYear}-${rawAlarmMonth}-${rawAlarmDay}');
    String weekDayKey = DateFormat('EEEE').format(parsedAlarmDate);
    var rawWeekDayLabel = weekDayLabels[weekDayKey];
    String weekDayLabel = rawWeekDayLabel.toString();
    int alarmDay = parsedAlarmDate.day;
    int monthLabelIndex = parsedAlarmDate.month;
    var rawMonthLabel = monthsLabels[monthLabelIndex];
    String monthLabel = rawMonthLabel.toString();
    alarmDate = '${weekDayLabel}, ${alarmDay} ${monthLabel}';
    int rawAlarmIsEnabled = alarm.enabled;
    bool isAlarmEnabled = rawAlarmIsEnabled == 1;
    alarmTogglers.add(isAlarmEnabled);
    int alarmIndex = alarms.length;
    // setState(() {
      // alarmTogglers[alarmIndex] = isAlarmEnabled;
    // });
    //setState(() {
      alarms.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  child: Text(
                      alarmTime,
                      style: TextStyle(
                          fontSize: 24
                      )
                  )
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: 0,
                      bottom: 0,
                      left: 25,
                      right: 25
                    ),
                    child: Text(
                        alarmDate
                    ),
                  ),
                  Switch(
                      value: alarmTogglers[alarmIndex],
                      onChanged: (bool value) => {
                        setState(() {
                          alarmTogglers[alarmIndex] = value;
                          Map<String, Object> parsedAlarm = alarm.toMap() as Map<String, Object>;
                          handler.updateIsEnabledAlarm(parsedAlarm);
                        })
                      }
                  )
                ]
              )
            ],
          )
      );
    // });
  }

  Future<CityWeatherResponse> fetchCityWeather(String cityName) async {
    final response = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=${cityName}&appid=8ced8d3f02f94ff154bc4ddb60fa72a9&units=metric'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return CityWeatherResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load city weather');
    }
  }

  Future<CityWorldTimeResponse> fetchCityWorldTime(String cityName) async {
    final response = await http.get(Uri.parse('https://worldtimeapi.org/api/timezone/Europe/${cityName}'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return CityWorldTimeResponse.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load city world time');
    }
  }

  void addWorldTime (WorldTime worldTime) {
    // setState(() {
      String worldTimeCityName = worldTime.name;
      Future<CityWeatherResponse> parsedWeather = fetchCityWeather(worldTimeCityName);
      Future<CityWorldTimeResponse> parsedWorldTime = fetchCityWorldTime(worldTimeCityName);
      worldTimes.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
                child: Column(
                  children: <Widget>[
                    Text(
                        worldTimeCityName,
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
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 25
                  ),
                  child: FutureBuilder<CityWorldTimeResponse>(
                    future: parsedWorldTime,
                    builder: (context, snapshot) {
                      bool isHasData = snapshot.hasData;
                      if (isHasData) {
                        var snapshotData = snapshot.data!;
                        String cityWorldDatetime = snapshotData.datetime;
                        List<String> cityWorldDateAndTime = cityWorldDatetime.split('T');
                        String cityWorldTime = cityWorldDateAndTime[1];
                        List<String> cityWorldTimeMinutesAndHours = cityWorldTime.split(':');
                        String cityWorldTimeHours = cityWorldTimeMinutesAndHours[0];
                        String cityWorldTimeMinutes = cityWorldTimeMinutesAndHours[1];
                        String rawCityWorldTime = '${cityWorldTimeHours}:${cityWorldTimeMinutes}';
                        return Text(
                          rawCityWorldTime,
                          style: TextStyle(
                              fontSize: 24
                          )
                        );
                      } else {
                        return Text(
                          'Неизвестно',
                          style: TextStyle(
                            fontSize: 24
                          )
                        );
                      }
                    }
                  ),
                ),
                Column(
                  children: <Widget>[
                    Image.asset(
                        'assets/weather.png',
                        width: 25
                    ),
                    FutureBuilder<CityWeatherResponse>(
                      future: parsedWeather,
                      builder: (context, snapshot) {
                        bool isHasData = snapshot.hasData;
                        var snapshotData = snapshot.data!;
                        WeatherInfo weatherInfo = snapshotData.main;
                        double parsedTemp = weatherInfo.temp;
                        int roundedParsedTemp = parsedTemp.toInt();
                        String rawTemp = roundedParsedTemp.toString();
                        String rawTempInDegresses = '${rawTemp}°';
                        if (isHasData) {
                          return Row(
                            children: [
                              Text(
                                  rawTempInDegresses
                              )
                            ]
                          );
                        } else {
                          return Text(
                              'Неизвестно'
                          );
                        }
                      }
                    )
                  ],
                )
              ]
            )
          ]
        )
      );
    // });
  }

  void addCustomTimer(CustomTimer customTimer) {
    String customTimerHours = customTimer.hours;
    String customTimerMinutes = customTimer.minutes;
    String customTimerSeconds = customTimer.seconds;
    String customTimerTime = '${customTimerHours}:${customTimerMinutes}:${customTimerSeconds}';
    String customTimerLabel = customTimerTime;
    String customTimerName = customTimer.name;
    bool isNameSet = customTimerName.length >= 1;
    if (isNameSet) {
      customTimerLabel = '${customTimerName}\n${customTimerTime}';
    }
    int customTimerIndex = customTimers.length;
    bool isApplyCustomTimer = customTimerTime == '${newCustomTimerHours}:${newCustomTimerMinutes}:${newCustomTimerSeconds}';
    Widget currentCustomTimer = GestureDetector(
      onTap: () {
        print('Выбираю customtimer');
        setState(() {
          customActiveTimer = customTimerIndex;
        });
        double rawCustomTimerHours = double.parse(customTimerHours);
        double hoursLabelRatio = 25;
        double scrollHoursValue = rawCustomTimerHours * hoursLabelRatio;
        timerHoursController.animateTo(
          scrollHoursValue,
          duration: Duration(
            seconds: 2
          ),
          curve: Curves.ease
        );
        double rawCustomTimerMinutes = double.parse(customTimerMinutes);
        double minutesLabelRatio = 27;
        double scrollMinutesValue = rawCustomTimerMinutes * minutesLabelRatio;
        timerMinutesController.animateTo(
          scrollMinutesValue,
          duration: Duration(
              seconds: 2
          ),
          curve: Curves.ease
        );
        double rawCustomTimerSeconds = double.parse(customTimerSeconds);
        double secondsLabelRatio = 27;
        double scrollSecondsValue = rawCustomTimerSeconds * secondsLabelRatio;
        timerSecondsController.animateTo(
            scrollSecondsValue,
            duration: Duration(
                seconds: 2
            ),
            curve: Curves.ease
        );
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
              color: customTimerIndex == customActiveTimer ? Colors.transparent : Color.fromARGB(255, 200, 200, 200),
              borderRadius: BorderRadius.circular(45),
              border: customTimerIndex == customActiveTimer ? Border.fromBorderSide(
                  BorderSide(
                    color: Color.fromARGB(255, 200, 150, 255),
                    width: 3.0
                  )
                )
              :
                Border.fromBorderSide(
                  BorderSide(
                    color: Colors.transparent
                  )
                )
          ),
          child: Text(
              customTimerLabel,
              textAlign: TextAlign.center
          )
      )
    );
    customTimers.insert(0, currentCustomTimer);
  }

  void addInterval() {
    bool isCircleBegin = stopWatchCircleTimer != null;
    if (isCircleBegin) {
      stopWatchCircleTimer!.cancel();
    }
    String circleTime = '00:00:00';
    String rawCircleHours = '00';
    if (circleHours <= 9) {
      rawCircleHours = '0${circleHours}';
    }
    String rawCircleMinutes = '00';
    if (circleMinutes <= 9) {
      rawCircleMinutes = '0${circleMinutes}';
    }
    String rawCircleSeconds = '00';
    if (circleSeconds <= 9) {
      rawCircleSeconds = '0${circleSeconds}';
    }
    circleTime = '${rawCircleHours}:${rawCircleMinutes}:${rawCircleSeconds}';
    String totalTime = stopWatchTitle;
    int circlesCount = intervals.length;
    int circleLabel = circlesCount + 1;
    String rawCircleLabel = circleLabel.toString();
    bool isCircleTop9 = circleLabel <= 9;
    if (isCircleTop9) {
      String prefixedCircleLabel = '${oneCharPrefix}${rawCircleLabel}';
      rawCircleLabel = prefixedCircleLabel;
    }
    Row interval = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          rawCircleLabel,
          style: TextStyle(
            color: Color.fromARGB(255, 150, 150, 150)
          )
        ),
        Text(
            circleTime,
            style: TextStyle(
              color: Color.fromARGB(255, 150, 150, 150)
            )
        ),
        Text(
          totalTime
        )
      ]
    );

    setState(() {
      intervals.add(interval);
    });

    setState(() {
      circleHours = 0;
      circleMinutes = 0;
      circleSeconds = 0;
      stopWatchCircleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          circleSeconds++;
        });
        bool isToggleSecond = circleSeconds == countSecondsInMinute;
        if (isToggleSecond) {
          setState(() {
            circleSeconds = initialSeconds;
            circleMinutes++;
          });
          bool isToggleHour = circleMinutes == countMinutesInHour;
          if (isToggleHour) {
            setState(() {
              circleMinutes = initialMinutes;
              circleHours++;
            });
          }
        }
        String updatedHoursText = '${circleHours}';
        int countHoursChars = updatedHoursText.length;
        bool isAddHoursPrefix = countHoursChars == 1;
        if (isAddHoursPrefix) {
          updatedHoursText = oneCharPrefix + updatedHoursText;
        }
        String updatedMinutesText = '${circleMinutes}';
        int countMinutesChars = updatedMinutesText.length;
        bool isAddMinutesPrefix = countMinutesChars == 1;
        if (isAddMinutesPrefix) {
          updatedMinutesText = oneCharPrefix + updatedMinutesText;
        }
        String updatedSecondsText = '${circleSeconds}';
        int countSecondsChars = updatedSecondsText.length;
        bool isAddSecondsPrefix = countSecondsChars == 1;
        if (isAddSecondsPrefix) {
          updatedSecondsText = oneCharPrefix + updatedSecondsText;
        }
        String currentTime = updatedHoursText + ":" + updatedMinutesText + ":" + updatedSecondsText;
        circleTime = currentTime;
      });
    });

  }

  void runStartedTimer() {
    setState(() {
      isStartTimer = true;
      // здесь
      startedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          bool isSecondsLeft = startedTimerSeconds >= 1;
          if (isSecondsLeft) {
            startedTimerSeconds--;
          } else {
            startedTimer.cancel();
            isStartTimer = false;
          }
        });
        bool isToggleSecond = startedTimerSeconds == 0;
        if (isToggleSecond) {
          setState(() {
            bool isMinutesLeft = startedTimerMinutes >= 1;
            if (isMinutesLeft) {
              startedTimerSeconds = 59;
              startedTimerMinutes--;
            }
          });
          bool isToggleHour = startedTimerMinutes == 0;
          if (isToggleHour) {
            setState(() {
              bool isHoursLeft = startedTimerHours >= 1;
              if (isHoursLeft) {
                startedTimerMinutes = 59;
                startedTimerHours--;
              }
            });
          }
        }
        String updatedHoursText = '${startedTimerHours}';
        int countHoursChars = updatedHoursText.length;
        bool isAddHoursPrefix = countHoursChars == 1;
        if (isAddHoursPrefix) {
          updatedHoursText = oneCharPrefix + updatedHoursText;
        }
        String updatedMinutesText = '${startedTimerMinutes}';
        int countMinutesChars = updatedMinutesText.length;
        bool isAddMinutesPrefix = countMinutesChars == 1;
        if (isAddMinutesPrefix) {
          updatedMinutesText = oneCharPrefix + updatedMinutesText;
        }
        String updatedSecondsText = '${startedTimerSeconds}';
        int countSecondsChars = updatedSecondsText.length;
        bool isAddSecondsPrefix = countSecondsChars == 1;
        if (isAddSecondsPrefix) {
          updatedSecondsText = oneCharPrefix + updatedSecondsText;
        }
        String currentTime = updatedHoursText + ":" + updatedMinutesText + ":" + updatedSecondsText;
        startTimerTitle = currentTime;

        // bool isTimeOver = startedTimerSeconds == 0 && startedTimerMinutes == 0 && startedTimerSeconds == 0;
        bool isTimeOver = startedTimerSeconds == -1;
        if (isTimeOver) {
          startedTimer.cancel();
          isStartTimer = false;
        }

      });

    });
  }

  @override
  Widget build(BuildContext context) {

    /*havedWorldTimes.toList().map((Object havedWorldTime) {
      addWorldTime();
    });*/

    Future<int> addNewCustomTimer(String hours, String minutes, String seconds, String name) async {
      CustomTimer customTimer = CustomTimer(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          name: name
      );
      List<CustomTimer> customTimers = [customTimer];
      return await this.handler.insertCustomTimer(customTimers);
    }

    return DefaultTabController(
        initialIndex: 0,
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
                    text: 'Database inspector'
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
                          Navigator.pushNamed(context, '/add_alarm');
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
                      child: FutureBuilder(
                        future: this.handler.retrieveAlarms(),
                        builder: (BuildContext context, AsyncSnapshot<List<Alarm>> snapshot) {
                          int snapshotsCount = 0;
                          if (snapshot.data != null) {
                            snapshotsCount = snapshot.data!.length;
                            alarms = [];
                            for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                              addAlarm(snapshot.data!.elementAt(snapshotIndex));
                            }
                          }
                          if (snapshot.hasData) {
                            return Container(
                                height: 250,
                                child: SingleChildScrollView(
                                  child: Column(
                                      children: alarms
                                  )
                                )
                            );
                          } else {
                            return Column(

                            );
                          }
                        }
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
                            Navigator.pushNamed(context, '/add_world_time');
                            // addWorldTime();
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
                    Container(
                      child: FutureBuilder(
                          future: this.handler.retrieveWorldTimes(),
                          builder: (BuildContext context, AsyncSnapshot<List<WorldTime>> snapshot) {
                            int snapshotsCount = 0;
                            if (snapshot.data != null) {
                              snapshotsCount = snapshot.data!.length;
                              worldTimes = [];
                              for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                                addWorldTime(snapshot.data!.elementAt(snapshotIndex));
                              }
                            }
                            if (snapshot.hasData) {
                              return Container(
                                height: 200,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: worldTimes
                                  )
                                )
                              );
                            } else {
                              return Column(

                              );
                            }
                          }
                      )
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
                  intervals.length >= 1 ?
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Круг'
                            ),
                            Text(
                              'Время круга'
                            ),
                            Text(
                              'Общее время'
                            )
                          ]
                        ),
                        Divider(
                          thickness: 1.0
                        ),
                        Container(
                          height: 150,
                          child: SingleChildScrollView(
                            child: Column(
                                children: intervals
                            )
                          )
                        )
                      ]
                    )
                  :
                    Column(),
                  Container(
                    margin: EdgeInsets.only(
                      top: 175,
                      bottom: 50,
                      left: 0,
                      right: 0
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IgnorePointer(
                          ignoring: isStopWatchIntervalBtnDisalbled,
                          child: TextButton(
                            style: ButtonStyle(
                                textStyle: MaterialStateProperty.all(
                                    TextStyle(
                                        fontSize: 18
                                    )
                                ),
                                backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 225, 225, 225)),
                                foregroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 0, 0, 0)
                                ),
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
                              bool isResetAction = stopWatchIntervalBtnTitle == stopWatchIntervalBtnResetLabel;
                              if (isResetAction) {
                                setState(() {
                                  isStopWatchIntervalBtnDisalbled = true;
                                  stopWatchIntervalBtnTitle = stopWatchIntervalBtnIntervalLabel;
                                  stopWatchTitle = '00:00:00';
                                  stopWatchStartBtnTitle = stopWatchStartBtnStartLabel;
                                  intervals = [];
                                });
                              } else {
                                addInterval();
                              }
                            },
                            child: Text(
                                stopWatchIntervalBtnTitle
                            ),

                          )
                        ),
                        TextButton(
                          style: ButtonStyle(
                              textStyle: MaterialStateProperty.all(
                                  TextStyle(
                                      fontSize: 18
                                  )
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                  stopWatchStartBtnTitle == stopWatchStartBtnStopLabel ?
                                    Color.fromARGB(255, 255, 0, 0)
                                  :
                                    Color.fromARGB(255, 0, 0, 225)
                              ),
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
                            setState(() {
                              isStopWatchIntervalBtnDisalbled = false;
                            });
                            bool isNotStart = !isStartStopWatch;
                            if (isNotStart) {
                              setState(() {
                                // stopWatchTitle = '00:00:00';
                                stopWatchStartBtnTitle = stopWatchStartBtnStopLabel;
                              });
                              stopWatchTimer = new Timer.periodic(const Duration(seconds: 1), (Timer timer) {
                                List<String> timeParts = stopWatchTitle.split(stopWatchTitleSeparator);
                                String rawHours = timeParts[0];
                                String rawMinutes = timeParts[1];
                                String rawSeconds = timeParts[2];
                                int hours = int.parse(rawHours);
                                int minutes = int.parse(rawMinutes);
                                int seconds = int.parse(rawSeconds);
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
                                String updatedHoursText = '${hours}';
                                int countHoursChars = updatedHoursText.length;
                                bool isAddHoursPrefix = countHoursChars == 1;
                                if (isAddHoursPrefix) {
                                  updatedHoursText = oneCharPrefix + updatedHoursText;
                                }
                                String updatedMinutesText = '${minutes}';
                                int countMinutesChars = updatedMinutesText.length;
                                bool isAddMinutesPrefix = countMinutesChars == 1;
                                if (isAddMinutesPrefix) {
                                  updatedMinutesText = oneCharPrefix + updatedMinutesText;
                                }
                                String updatedSecondsText = '${seconds}';
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
                                stopWatchStartBtnTitle = stopWatchStartBtnResumeLabel;
                                // stopWatchTitle = '${new Random().nextInt(5000)}:${new Random().nextInt(5000)}:${new Random().nextInt(5000)}';
                                stopWatchIntervalBtnTitle = stopWatchIntervalBtnResetLabel;
                              });
                              stopWatchTimer.cancel();
                            }
                            setState(() {
                              isStartStopWatch = !isStartStopWatch;
                            });
                          },
                          child: Text(
                              stopWatchStartBtnTitle
                          ),
                        )
                      ],
                    )
                  )
                ]
              ),
              !isStartTimer ?
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
                                                decoration: new InputDecoration.collapsed(
                                                    hintText: '${newCustomTimerHours}:${newCustomTimerMinutes}:${newCustomTimerSeconds}',
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            width: 1.0
                                                        )
                                                    )
                                                ),
                                                controller: TextEditingController()..text = '${newCustomTimerHours},:${newCustomTimerMinutes}:${newCustomTimerSeconds}',
                                                onChanged: (value) {
                                                  List<String> possibleTime = value.split(':');
                                                  bool isTime = possibleTime.length == 3;
                                                  if (isTime) {
                                                    newCustomTimerHours = possibleTime[0];
                                                    newCustomTimerMinutes = possibleTime[1];
                                                    newCustomTimerSeconds = possibleTime[2];
                                                  }
                                                }
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
                                                keyboardType: TextInputType.numberWithOptions(

                                                ),
                                                decoration: new InputDecoration.collapsed(
                                                    hintText: 'Название готового таймера',
                                                    border: OutlineInputBorder(
                                                      gapPadding: 500.0,
                                                      borderSide: BorderSide(
                                                          style: BorderStyle.solid,
                                                          width: 1.0
                                                      )
                                                    )
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    newCustomTimerName = value;
                                                  });
                                                },
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
                                        onPressed: () {
                                          setState(() {
                                            newCustomTimerName = '';
                                          });
                                          return Navigator.pop(context, 'Cancel');
                                        },
                                        child: const Text('Отмена')
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // addCustomTimer();
                                          addNewCustomTimer(newCustomTimerHours, newCustomTimerMinutes, newCustomTimerSeconds, newCustomTimerName);
                                          setState(() {
                                            newCustomTimerName = '';
                                          });
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
                          Container(
                            child: Text(
                                'ч.'
                            ),
                          ),
                          Container(
                            child: Text(
                                'мин.'
                            ),
                          ),
                          Container(
                            child: Text(
                                'сек.'
                            ),
                          )
                        ]
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            height: 100,
                            child: SingleChildScrollView(
                              controller: timerHoursController,
                              child: timerHoursColumn
                            )
                          ),
                          Container(
                              height: 100,
                              child: SingleChildScrollView(
                                  controller: timerMinutesController,
                                  child: timerMinutesColumn
                              )
                          ),
                          Container(
                              height: 100,
                              child: SingleChildScrollView(
                                controller: timerSecondsController,
                                child: timerSecondsColumn
                              )
                          )
                        ],
                      ),
                      SingleChildScrollView(
                        child: FutureBuilder(
                            future: this.handler.retrieveCustomTimers(),
                            builder: (BuildContext context, AsyncSnapshot<List<CustomTimer>> snapshot) {
                              int snapshotsCount = 0;
                              if (snapshot.data != null) {
                                snapshotsCount = snapshot.data!.length;
                                customTimers = [];
                                for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                                  addCustomTimer(snapshot.data!.elementAt(snapshotIndex));
                                }
                              }
                              if (snapshot.hasData) {
                                return Container(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: customTimers
                                    )
                                  )
                                );
                              } else {
                                return Column(

                                );
                              }
                            }
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
                            // Navigator.pushNamed(context, '/started_timer');
                            setState(() {
                              startTimerTitle = '${newCustomTimerHours}:${newCustomTimerMinutes}:${newCustomTimerSeconds}';
                              startedTimerHours = int.parse(newCustomTimerHours);
                              startedTimerMinutes = int.parse(newCustomTimerMinutes);
                              startedTimerSeconds = int.parse(newCustomTimerSeconds);
                            });
                            runStartedTimer();
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
                )
              :
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
                                          // addCustomTimer();
                                          addNewCustomTimer(newCustomTimerHours, newCustomTimerMinutes, newCustomTimerSeconds, newCustomTimerName);
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
                    Container(
                        alignment: Alignment.center,
                        height: 300.0,
                        width: 300.0,
                        margin: EdgeInsets.only(
                            top: 25,
                            bottom: 50,
                            left: 15,
                            right: 15
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 200, 200, 200),
                          borderRadius: BorderRadius.circular(150),
                        ),
                        child: Text(
                          startTimerTitle,
                          style: TextStyle(
                            fontSize: 36
                          )
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState((){
                              isStartTimer = false;
                              startedTimer.cancel();
                              startedTimerPauseBtnContent = startedTimerPauseLabel;
                            });
                          },
                          child: Text(
                            'Отмена',
                            style: TextStyle(
                              fontSize: 18
                            )
                          ),
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                              Colors.black
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 215, 215, 215)
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)
                              )
                            ),
                            fixedSize: MaterialStateProperty.all(
                              Size(
                                100.0,
                                50.0
                              )
                            )
                          )
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                bool isStartedTimerRun = startedTimerPauseBtnContent == startedTimerResumeLabel;
                                if (isStartedTimerRun) {
                                  startedTimerPauseBtnContent = startedTimerPauseLabel;
                                  runStartedTimer();
                                } else {
                                  startedTimerPauseBtnContent = startedTimerResumeLabel;
                                  startedTimer.cancel();
                                }
                              });
                            },
                            child: Text(
                                startedTimerPauseBtnContent,
                                style: TextStyle(
                                    fontSize: 18
                                )
                            ),
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all(
                                    Colors.white
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                  startedTimerPauseBtnContent == startedTimerResumeLabel ?
                                    Colors.blue
                                  :
                                    Colors.red
                                ),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0)
                                    )
                                ),
                                fixedSize: MaterialStateProperty.all(
                                    Size(
                                        100.0,
                                        50.0
                                    )
                                )
                            )
                        )
                      ]
                    )
                  ]
                ),
              Column(
                children: <Widget>[
                  TextButton(
                    child: Text(
                      'Database inspector'
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DatabaseList()));
                    }
                  )
                ],
              )
            ],
          )
        )
    );
  }
}

class AddAlarmPage extends StatefulWidget {

  const AddAlarmPage({Key? key}) : super(key: key);

  @override
  State<AddAlarmPage> createState() => _AddAlarmPageState();

}

class _AddAlarmPageState extends State<AddAlarmPage> {

  late DatabaseHandler handler;
  String newAlarmDate = '22/11/2000';
  String alarmSignalName = '';

  Future<void> setAlarmDate(BuildContext context) async {
    setState(() async {
      final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(
              Duration(
                  days: 365
              )
          ),
          lastDate: DateTime.now().add(
              Duration(
                  days: 365
              )
          )
      );
      setState(() {
        bool isDatePick = pickedDate != null;
        if (isDatePick) {
          // mockDate = pickedDate.toString();
          int pickedDateDay = pickedDate.day;
          int pickedDateMonth = pickedDate.month;
          int pickedDateYear = pickedDate.year;
          newAlarmDate = '${pickedDateDay}/${pickedDateMonth}/${pickedDateYear}';
        }
      });
    });

  }

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {});
    });
  }

  Future<int> addNewAlarm(String time, String date, int enabled, String name) async {
    Alarm firstAlarm = Alarm(time: time, date: date, enabled: enabled, name: name);
    List<Alarm> listOfAlarms = [firstAlarm];
    return await this.handler.insertAlarm(listOfAlarms);
  }

  @override
  Widget build(BuildContext context) {
    return (
      Scaffold(
        appBar: AppBar(
          title: Text(
              'Добавить будильник'
          )
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: [
                          Text(
                            '00',
                            style: TextStyle(
                              fontSize: 48
                            )
                          ),
                          Text(
                              '01',
                              style: TextStyle(
                                  fontSize: 48,
                                  color: Color.fromARGB(255, 200, 200, 200)
                              )
                          ),
                          Text(
                              '02',
                              style: TextStyle(
                                  fontSize: 48,
                                  color: Color.fromARGB(255, 200, 200, 200)
                              )
                          )
                        ]
                      ),
                      Text(
                        ':',
                        style: TextStyle(
                            fontSize: 48
                        )
                      ),
                      Column(
                        children: [
                          Text(
                            '00',
                              style: TextStyle(
                                  fontSize: 48
                              )
                          ),
                          Text(
                              '01',
                              style: TextStyle(
                                  fontSize: 48,
                                  color: Color.fromARGB(255, 200, 200, 200)
                              )
                          ),
                          Text(
                              '02',
                              style: TextStyle(
                                fontSize: 48,
                                color: Color.fromARGB(255, 200, 200, 200)
                              )
                          )
                        ]
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Завтра-вт., 1 фев'
                      ),
                      TextButton(
                        onPressed: () {
                          setAlarmDate(context);
                        },
                        child: Icon(
                          Icons.calendar_today
                        )
                      )
                    ]
                  ),
                  Container(
                    child: Row(
                      children: [
                        TextButton(
                            style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(
                                    Size(
                                        5.0, 25.0
                                    )
                                ),

                            ),
                            child: Text(
                                'П',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10
                                )
                            ),
                            onPressed: () {

                            }
                        ),
                        TextButton(
                            child: Text(
                                'В',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10
                                )
                            ),
                            onPressed: () {

                            }
                        ),
                        TextButton(
                            child: Text(
                                'С',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10
                                )
                            ),
                            onPressed: () {

                            }
                        ),
                        TextButton(
                            child: Text(
                                'Ч',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10
                                )
                            ),
                            onPressed: () {

                            }
                        ),
                        TextButton(
                            child: Text(
                                'П',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10
                                )
                            ),
                            onPressed: () {

                            }
                        ),
                        TextButton(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                Size(
                                  5.0, 25.0
                                )
                              )
                            ),
                            child: Text(
                                'С',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10
                                )
                            ),
                            onPressed: () {

                            }
                        )
                      ]
                    )
                  ),
                  TextField(
                      decoration: new InputDecoration.collapsed(
                          hintText: 'Имя сигнала',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1.0
                              )
                          )
                      ),
                      onChanged: (String signalName) {
                        alarmSignalName = signalName;
                      },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                           'Звук будильника',
                            style: TextStyle(
                              fontSize: 18
                            )
                          ),
                          Text(
                            'Homecoming',
                            style: TextStyle(
                                color: Colors.blue
                            )
                          )
                        ]
                      ),
                      Switch(
                        value: true,
                        onChanged: (bool value) {

                        }
                      )
                    ]
                  ),
                  Divider(
                    thickness: 1.0
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            children: [
                              Text(
                                  'Вибрация',
                                  style: TextStyle(
                                      fontSize: 18
                                  )
                              ),
                              Text(
                                  'Basic call',
                                  style: TextStyle(
                                      color: Colors.blue
                                  )
                              )
                            ]
                        ),
                        Switch(
                            value: true,
                            onChanged: (bool value) {

                            }
                        )
                      ]
                  ),
                  Divider(
                      thickness: 1.0
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            children: [
                              Text(
                                  'Пауза',
                                  style: TextStyle(
                                      fontSize: 18
                                  )
                              ),
                              Text(
                                  '5 минут, 3 раза',
                                  style: TextStyle(
                                      color: Colors.blue
                                  )
                              )
                            ]
                        ),
                        Switch(
                            value: true,
                            onChanged: (bool value) {

                            }
                        )
                      ]
                  )
                ]
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/main');
                  },
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 18
                    )
                  ),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Colors.black
                    )
                  )
                ),
                TextButton(
                    onPressed: () async {
                      await this.addNewAlarm('17:00', newAlarmDate, 1, alarmSignalName);
                      Navigator.pushNamed(context, '/main');
                    },
                    child: Text(
                        'Сохранить',
                        style: TextStyle(
                            fontSize: 18
                        ),
                    ),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            Colors.black
                        )
                    )
                )
              ]
            )
          ]
        )
      )
    );
  }

}

class AddWorldTimePage extends StatefulWidget {

  const AddWorldTimePage({Key? key}) : super(key: key);

  @override
  State<AddWorldTimePage> createState() => _AddWorldTimePageState();

}

class _AddWorldTimePageState extends State<AddWorldTimePage> {

  late DatabaseHandler handler;
  String newCityName = '';

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {});
    });
  }

  Future<int> addNewWorldTime(String cityName) async {
    WorldTime worldTime = WorldTime(name: cityName);
    List<WorldTime> worldTimes = [worldTime];
    return await this.handler.insertWorldTime(worldTimes);
  }

  @override
  Widget build(BuildContext context) {
    return (
        Scaffold(
            appBar: AppBar(
                title: Text(
                    'Добавить мировое время'
                )
            ),
            body: Column(
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      newCityName = value;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.blue
                              )
                          ),
                          child: Text(
                              'Добавить мировое время',
                              style: TextStyle(
                                  color: Colors.white
                              )
                          ),
                          onPressed: () {
                            addNewWorldTime(newCityName);
                            Navigator.pushNamed(context, '/main');
                          }
                      )
                    ]
                  )
                ]
            )
        )
    );
  }

}

class StartedTimerPage extends StatefulWidget {

  const StartedTimerPage({Key? key}) : super(key: key);

  @override
  State<StartedTimerPage> createState() => _StartedTimerPageState();

}

class _StartedTimerPageState extends State<StartedTimerPage> {

  late DatabaseHandler handler;

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return (
        Scaffold(
            appBar: AppBar(
                title: Text(
                    'Запущенный таймер'
                )
            ),
            body: Column(
                children: <Widget>[

                ]
            )
        )
    );

  }

}

class Alarm {

  final int? id;
  final String time;
  final String date;
  final int enabled;
  final String name;

  Alarm({
    this.id,
    required this.time,
    required this.date,
    required this.enabled,
    required this.name
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'date': date,
      'enabled': enabled,
      'name': name
    };
  }

  Alarm.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        time = res["time"],
        date = res["date"],
        enabled = res["enabled"],
        name = res["name"];
}

class DatabaseHandler {

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'flutter_alarmes.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE alarms(id INTEGER PRIMARY KEY, time TEXT, date TEXT, enabled INTEGER, name TEXT)"
        );
        await database.execute(
            "CREATE TABLE worldtimes(id INTEGER PRIMARY KEY, name TEXT)"
        );
        await database.execute(
            "CREATE TABLE customtimers(id INTEGER PRIMARY KEY, hours TEXT, minutes TEXT, seconds TEXT, name TEXT)"
        );
      },
      onOpen: (database) async {
        /*await database.execute(
            "CREATE TABLE alarms(id INTEGER PRIMARY KEY, time TEXT, date TEXT, enabled INTEGER, name TEXT);"
        );
        await database.execute(
            "CREATE TABLE worldtimes(id INTEGER PRIMARY KEY, name TEXT);"
        );
        await database.execute(
            "CREATE TABLE customtimers(id INTEGER PRIMARY KEY, hours TEXT, minutes TEXT, seconds TEXT, name TEXT)"
        );
        */
        // await database.execute('DROP TABLE customtimers;');
      },
      version: 1,
    );
  }

  Future<int> insertAlarm(List<Alarm> alarms) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var alarm in alarms){
      result = await db.insert('alarms', alarm.toMap());
    }
    return result;
  }

  Future<List<Alarm>> retrieveAlarms() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('alarms');
    var returnedAlarms = queryResult.map((e) => Alarm.fromMap(e)).toList();
    return returnedAlarms;
  }

  Future<void> deleteAlarm(int id) async {
    final db = await initializeDB();
    await db.delete(
      'alarms',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAlarms() async {
    final db = await initializeDB();
    await db.delete(
      'alarms',
      where: "id > ?",
      whereArgs: [0],
    );
  }

  Future<void> updateIsEnabledAlarm(Map<String, Object> alarm) async {
    final db = await initializeDB();
    Map<String, Object> values = Map<String, Object>();
    values = alarm;
    bool isEnabled = alarm['enalbed'] as bool;
    alarm['enalbed'] = isEnabled ? false : true;
    values = alarm;
    await db.update('alarms', values);
  }

  Future<int> insertWorldTime(List<WorldTime> worldTimes) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var worldTime in worldTimes){
      result = await db.insert('worldtimes', worldTime.toMap());
    }
    return result;
  }

  Future<List<WorldTime>> retrieveWorldTimes() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('worldtimes');
    var returnedWorldTimes = queryResult.map((e) => WorldTime.fromMap(e)).toList();
    return returnedWorldTimes;
  }

  Future<int> insertCustomTimer(List<CustomTimer> customTimers) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var customTimer in customTimers){
      result = await db.insert('customtimers', customTimer.toMap());
    }
    return result;
  }

  Future<List<CustomTimer>> retrieveCustomTimers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('customtimers');
    var returnedCustomTimers = queryResult.map((e) => CustomTimer.fromMap(e)).toList();
    return returnedCustomTimers;
  }

}

class WorldTime {

  final int? id;
  final String name;

  WorldTime({
    this.id,
    required this.name
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name
    };
  }

  WorldTime.fromMap(Map<String, dynamic> res)
    : id = res["id"],
      name = res["name"];
}

class CustomTimer {

  final int? id;
  final String hours;
  final String minutes;
  final String seconds;
  final String name;

  CustomTimer({
    this.id,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.name
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'name': name
    };
  }

  CustomTimer.fromMap(Map<String, dynamic> res)
    : id = res["id"],
      hours = res["hours"],
      minutes = res["minutes"],
      seconds = res["seconds"],
      name = res["name"];
}

class CityWeatherResponse {

  final WeatherInfo main;

  const CityWeatherResponse({
    required this.main
  });

  factory CityWeatherResponse.fromJson(Map<String, dynamic> json) {
    return CityWeatherResponse(
      main: WeatherInfo.fromJson(json['main'] as Map<String, dynamic>)
    );
  }

}

class WeatherInfo {

  WeatherInfo({
    required this.temp
  });

  // non-nullable - assuming the score field is always present
  final double temp;

  factory WeatherInfo.fromJson(Map<String, dynamic> data) {
    final temp = data['temp'] as double;
    return WeatherInfo(temp: temp);
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp
    };
  }

}

class CityWorldTimeResponse {

  final String datetime;

  const CityWorldTimeResponse({
    required this.datetime
  });

  factory CityWorldTimeResponse.fromJson(Map<String, dynamic> json) {
    return CityWorldTimeResponse(
        datetime: json['datetime'] as String
    );
  }

}