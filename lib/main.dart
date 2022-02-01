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

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      // await this.deleteAlarms();
      setState(() {});
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
      throw Exception('Failed to load album');
    }
  }

  void addWorldTime (WorldTime worldTime) {
    // setState(() {
      String worldTimeCityName = worldTime.name;
      Future<CityWeatherResponse> parsedWeather = fetchCityWeather(worldTimeCityName);
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
    // setState(() {
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
    // });
  }

  @override
  Widget build(BuildContext context) {

    /*havedWorldTimes.toList().map((Object havedWorldTime) {
      addWorldTime();
    });*/

    Future<int> addNewCustomTimer(String hours, String minutes, String seconds) async {
      CustomTimer customTimer = CustomTimer(
          hours: hours,
          minutes: minutes,
          seconds: seconds
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
                            return Column(
                                children: alarms
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
                              return Column(
                                  children: worldTimes
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
                                        // addCustomTimer();
                                        addNewCustomTimer('00', '00', '00');
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
                              return Row(
                                children: customTimers
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
                          Navigator.pushNamed(context, '/started_timer');
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
            "CREATE TABLE timers(id INTEGER PRIMARY KEY, hours TEXT, minutes TEXT, seconds TEXT)"
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
            "CREATE TABLE timers(id INTEGER PRIMARY KEY, hours TEXT, minutes TEXT, seconds TEXT)"
        );*/
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
      result = await db.insert('timers', customTimer.toMap());
    }
    return result;
  }

  Future<List<CustomTimer>> retrieveCustomTimers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('timers');
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

  CustomTimer({
    this.id,
    required this.hours,
    required this.minutes,
    required this.seconds
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds
    };
  }

  CustomTimer.fromMap(Map<String, dynamic> res)
    : id = res["id"],
      hours = res["hours"],
      minutes = res["minutes"],
      seconds = res["seconds"];
}

class CityWeatherResponse {

  /*final int coord;
  final int weather;
  final String base;
  */
  final WeatherInfo main;
  // final int visibility;
  /*final String wind;
  final int snow;
  final int clouds;
  final String dt;
  final int sys;
  final int timezone;
  final String id;
  final int name;
  final int cod;*/

  const CityWeatherResponse({

    /*required this.coord,
    required this.weather,
    required this.base,
    */
    required this.main,
    // required this.visibility,
    /*required this.wind,
    required this.snow,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod*/
  });

  factory CityWeatherResponse.fromJson(Map<String, dynamic> json) {
    return CityWeatherResponse(
      /*coord: json['coord'],
      weather: json['weather'],
      base: json['base'],
      */
      main: WeatherInfo.fromJson(json['main'] as Map<String, dynamic>)
      // visibility: json['visibility'],
      /*wind: json['wind'],
      snow: json['snow'],
      clouds: json['clouds'],
      dt: json['dt'],
      sys: json['sys'],
      timezone: json['timezone'],
      id: json['id'],
      name: json['name'],
      cod: json['cod']*/
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