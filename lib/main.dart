import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {

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
        '/add_world_time': (context) => AddWorldTimePage()
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
    int rawAlarmIsEnabled = alarm.enabled;
    bool isAlarmEnabled = rawAlarmIsEnabled == 1;
    alarmTogglers.add(isAlarmEnabled);
    int alarmIndex = alarms.length;
    //setState(() {
      alarms.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                  child: Text(
                      alarmTime,
                      style: TextStyle(
                          fontSize: 24
                      )
                  )
              ),
              Container(
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
            ],
          )
      );
    // });
  }

  void addWorldTime () {
    setState(() {
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
    });
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
                  Text(
                      'asd'
                  )
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
          "CREATE TABLE alarmes(id INTEGER PRIMARY KEY, time TEXT, date TEXT, enabled INTEGER, name TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertAlarm(List<Alarm> alarms) async {
    int result = 0;
    final Database db = await initializeDB();
    for(var alarm in alarms){
      result = await db.insert('alarmes', alarm.toMap());
    }
    return result;
  }

  Future<List<Alarm>> retrieveAlarms() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('alarmes');
    var returnedAlarms = queryResult.map((e) => Alarm.fromMap(e)).toList();
    return returnedAlarms;
  }

  Future<void> deleteAlarm(int id) async {
    final db = await initializeDB();
    await db.delete(
      'alarmes',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAlarms() async {
    final db = await initializeDB();
    await db.delete(
      'alarmes',
      where: "id > ?",
      whereArgs: [0],
    );
  }

}

