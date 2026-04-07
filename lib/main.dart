import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _loading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    setState(() {
      _showOnboarding = !seen;
      _loading = false;
    });
  }

  void _onFinishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(onFinish: _onFinishOnboarding);
    }

    return const MyHomePage(title: 'Study Timer');
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  void _onPageChanged(int index) {
    setState(() {
      _page = index;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    widget.onFinish();
  }

  Widget _buildPage({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, size: 96, color: Colors.white24),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPage(
                    title: 'Stay Focused',
                    description: 'Use the Pomodoro technique to concentrate on your study sessions.',
                  ),
                  _buildPage(
                    title: 'Track Your Progress',
                    description: 'Monitor your study time and subjects with built-in statistics.',
                  ),
                  _buildPage(
                    title: 'Build Study Habits',
                    description: 'Create a consistent study routine and improve your productivity.',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: _page == index ? 12 : 8,
                  height: _page == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _page == index ? Colors.white : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            if (_page == 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Start Studying', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
          ],
        ),
      ),
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

                    Future<void> showNotification(String title, String body) async {
                      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
                        'pomodoro_channel',
                        'Pomodoro Notifications',
                        channelDescription: 'Notifications for Pomodoro timer',
                        importance: Importance.max,
                        priority: Priority.high,
                        showWhen: false,
                      );
                      const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
                      const NotificationDetails platformChannelSpecifics = NotificationDetails(
                        android: androidPlatformChannelSpecifics,
                        iOS: iOSPlatformChannelSpecifics,
                      );
                      await flutterLocalNotificationsPlugin.show(
                        id: 0,
                        title: title,
                        body: body,
                        notificationDetails: platformChannelSpecifics,
                      );
                    }
                  // Calculate total focused minutes per weekday for the current week
                  List<int> get _weeklyMinutes {
                    final now = DateTime.now();
                    // Find the start of the week (Monday)
                    final weekStart = now.subtract(Duration(days: now.weekday - 1));
                    final weekEnd = weekStart.add(const Duration(days: 7));
                    List<int> totals = List.filled(7, 0);
                    for (final dt in _secessionTimestamps) {
                      if (dt.isAfter(weekStart.subtract(const Duration(seconds: 1))) && dt.isBefore(weekEnd)) {
                        int weekday = dt.weekday - 1; // 0=Mon, 6=Sun
                        if (weekday >= 0 && weekday < 7) {
                          totals[weekday] += 25; // Each session = 25 min
                        }
                      }
                    }
                    return totals;
                  }

                  Widget _buildWeeklyBarChart() {
                    final data = _weeklyMinutes;
                    final barGroups = List.generate(7, (i) =>
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: data[i].toDouble(),
                            color: Colors.red,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                    return SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (data.reduce((a, b) => a > b ? a : b) + 10).toDouble(),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(days[value.toInt()], style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: true, horizontalInterval: 25),
                          borderData: FlBorderData(show: false),
                          barGroups: barGroups,
                        ),
                      ),
                    );
                  }
                Timer? _timer;
              // Subject tracking
  List<String> _subjects = ['Math', 'English', 'Science'];
  final TextEditingController _subjectController = TextEditingController();
  String _selectedSubject = 'Math';
  Map<String, int> _subjectMinutes = {};
  List<DateTime> _secessionTimestamps = [];
  Map<int, bool> _dayStudied = {0: false, 1: false, 2: false, 3: false, 4: false, 5: false, 6: false}; // Mon-Sun
          int _selectedIndex = 0;

          void _onNavBarTapped(int index) {
            setState(() {
              _selectedIndex = index;
            });
          }
        int _secessions = 0;
        int _totalFocusedMinutes = 0;
      // For the end spin animation
      bool _showEndSpin = false;
      double _endSpinValue = 0.0;
  final List<int> _focusOptions = [25, 30, 45];
  final List<int> _breakOptions = [5, 10, 15];
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int get _studySeconds => _focusMinutes * 60;
  int get _breakSeconds => _breakMinutes * 60;
  int _seconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  Future<void>? _timerFuture;
  DateTime? _endTime; // Stores the target end time for background-independent counting
  DateTime? _pausedTime; // Stores the time when timer was paused
  @override
  void initState() {
    super.initState();
    _loadData();
    _resumeTimerIfActive();
  }

  /// Resume timer if one was active when app was closed
  Future<void> _resumeTimerIfActive() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_endTime != null && DateTime.now().isBefore(_endTime!)) {
      // Timer was running and hasn't expired yet
      setState(() {
        _isRunning = true;
      });
      _startTimer();
    } else if (_endTime != null && DateTime.now().isAfter(_endTime!)) {
      // Timer expired while app was closed
      _endTime = null;
      _pausedTime = null;
      _onSessionComplete();
    }
  }

  /// Calculate remaining seconds from end time
  int _getRemainingSeconds() {
    if (_endTime == null) return _seconds;
    final remaining = _endTime!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _subjects = prefs.getStringList('subjects') ?? ['Math', 'English', 'Science'];
      _selectedSubject = prefs.getString('selectedSubject') ?? 'Math';
      _subjectMinutes = Map<String, int>.from(jsonDecode(prefs.getString('subjectMinutes') ?? '{}'));
      _secessions = prefs.getInt('secessions') ?? 0;
      _totalFocusedMinutes = prefs.getInt('totalFocusedMinutes') ?? 0;
      _focusMinutes = prefs.getInt('focusMinutes') ?? 25;
      _breakMinutes = prefs.getInt('breakMinutes') ?? 5;
      _seconds = prefs.getInt('seconds') ?? (_focusMinutes * 60);
      _isBreak = prefs.getBool('isBreak') ?? false;
      _isRunning = false;
      _dayStudied = Map<int, bool>.from(jsonDecode(prefs.getString('dayStudied') ?? '{"0":false,"1":false,"2":false,"3":false,"4":false,"5":false,"6":false}'));
      _secessionTimestamps = (jsonDecode(prefs.getString('secessionTimestamps') ?? '[]') as List)
          .map<DateTime>((e) => DateTime.tryParse(e) ?? DateTime.now()).toList();
      
      // Restore end time and paused time from background
      final endTimeStr = prefs.getString('endTime');
      final pausedTimeStr = prefs.getString('pausedTime');
      _endTime = endTimeStr != null ? DateTime.tryParse(endTimeStr) : null;
      _pausedTime = pausedTimeStr != null ? DateTime.tryParse(pausedTimeStr) : null;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('subjects', _subjects);
    await prefs.setString('selectedSubject', _selectedSubject);
    await prefs.setString('subjectMinutes', jsonEncode(_subjectMinutes));
    await prefs.setInt('secessions', _secessions);
    await prefs.setInt('totalFocusedMinutes', _totalFocusedMinutes);
    await prefs.setInt('focusMinutes', _focusMinutes);
    await prefs.setInt('breakMinutes', _breakMinutes);
    await prefs.setInt('seconds', _seconds);
    await prefs.setBool('isBreak', _isBreak);
    await prefs.setString('dayStudied', jsonEncode(_dayStudied));
    await prefs.setString('secessionTimestamps', jsonEncode(_secessionTimestamps.map((e) => e.toIso8601String()).toList()));
    
    // Persist end time and paused time for background resumption
    if (_endTime != null) {
      await prefs.setString('endTime', _endTime!.toIso8601String());
    } else {
      await prefs.remove('endTime');
    }
    if (_pausedTime != null) {
      await prefs.setString('pausedTime', _pausedTime!.toIso8601String());
    } else {
      await prefs.remove('pausedTime');
    }
  }

  void _toggleCountdown() {
    if (_isRunning) {
      _stopTimer();
      setState(() {
        _isRunning = false;
      });
    } else {
      setState(() {
        _isRunning = true;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    // Calculate the target end time based on remaining seconds
    _endTime = DateTime.now().add(Duration(seconds: _getRemainingSeconds()));
    _pausedTime = null;
    _saveData(); // Persist the end time immediately
    
    // Lightweight periodic timer - only updates UI, doesn't decrement time
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      final remaining = _getRemainingSeconds();
      
      setState(() {
        _seconds = remaining;
      });
      
      // Check if session is complete
      if (remaining <= 0 && _isRunning) {
        timer.cancel();
        _endTime = null;
        _pausedTime = null;
        _onSessionComplete();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (_isRunning && _endTime != null) {
      // Store the paused time and remaining seconds for later resume
      _pausedTime = DateTime.now();
      final remaining = _getRemainingSeconds();
      _seconds = remaining > 0 ? remaining : 0;
      _saveData();
    }
  }

  void _onSessionComplete() async {
    // Clear end time and paused time for next session
    _endTime = null;
    _pausedTime = null;
    
    // Show end spin
    setState(() {
      _showEndSpin = true;
      _endSpinValue = 0.0;
    });
    // Animate the spin for 1 second
    for (int i = 0; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() {
        _endSpinValue = i / 20.0;
      });
    }
    setState(() {
      _showEndSpin = false;
      _endSpinValue = 0.0;
    });
    if (!_isBreak) {
      // Focus session ended, record the session
      int today = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
      setState(() {
        _secessions++;
        _totalFocusedMinutes += _focusMinutes;
        _secessionTimestamps.add(DateTime.now());
        _subjectMinutes[_selectedSubject] = (_subjectMinutes[_selectedSubject] ?? 0) + _focusMinutes;
        _dayStudied[today] = true;
      });
      _saveData();
      // Notify for break
      await showNotification('Time for a break!', 'Focus session complete. Take a short break.');
      setState(() {
        _isBreak = true;
        _isRunning = true;
        _seconds = _breakMinutes * 60;
      });
      _startTimer();
    } else {
      // Break session ended, notify for focus
      await showNotification('Back to focus!', 'Break is over. Time to focus again!');
      setState(() {
        _isRunning = false;
        _isBreak = false;
        _seconds = _focusMinutes * 60;
      });
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _seconds = _studySeconds;
      _endTime = null;
      _pausedTime = null;
    });
    _saveData();
  }

  Widget _buildDayCircle(String dayLabel, int dayIndex) {
    final isStudied = _dayStudied[dayIndex] ?? false;
    return GestureDetector(
      onTap: () {
        setState(() {
          _dayStudied[dayIndex] = !_dayStudied[dayIndex]!;
        });
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isStudied ? Colors.red : Colors.transparent,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                isStudied ? '✓' : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dayLabel,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isRunning = false;
    _stopTimer();
    _saveData();
    _subjectController.dispose();
    super.dispose();
  }

  Widget _buildTimerDisplay() {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    double progress = _isBreak
        ? (_breakSeconds - _seconds) / _breakSeconds
        : (_studySeconds - _seconds) / _studySeconds;
    return SizedBox(
      width: 340,
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: CircularProgressIndicator(
              value: _showEndSpin ? null : progress,
              strokeWidth: 18,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isBreak ? Colors.green : Colors.red,
              ),
            ),
          ),
          // center text inside circle, but a bit higher
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isBreak ? 'Rest' : 'Focus',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _isBreak ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 0),
                  Text(
                    '$minutes:${remainingSeconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: _isBreak ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    Widget timerBody = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerDisplay(),
          // Subject dropdown placed beneath the circle
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Subject: ', style: TextStyle(fontSize: 18, color: Colors.white)),
                DropdownButton<String>(
                  value: _selectedSubject,
                  dropdownColor: Colors.grey[800],
                  items: _subjects.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(color: Colors.white)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSubject = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget recordBody = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total focused: $_totalFocusedMinutes min',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Total sessions: $_secessions',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          // Streak section moved up
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Streak: ${_dayStudied.values.where((v) => v).length} Days',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDayCircle('Mon', 0),
                    _buildDayCircle('Tue', 1),
                    _buildDayCircle('Wed', 2),
                    _buildDayCircle('Thu', 3),
                    _buildDayCircle('Fri', 4),
                    _buildDayCircle('Sat', 5),
                    _buildDayCircle('Sun', 6),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Weekly Study Analytics:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          _buildWeeklyBarChart(),
          const SizedBox(height: 24),


          const SizedBox(height: 16),
          const Text(
            'Study time per subject:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _subjects.length + 1,
            itemBuilder: (context, index) {
              // Last item is the add new subject form
              if (index == _subjects.length) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subjectController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Add',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () {
                          final newSubject = _subjectController.text.trim();
                          if (newSubject.isNotEmpty && !_subjects.contains(newSubject)) {
                            setState(() {
                              _subjects.add(newSubject);
                              _subjectController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        child: const Text('Add', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }

              // Regular subject items
              final subject = _subjects[index];
              return GestureDetector(
                onLongPress: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Subject'),
                      content: Text('Are you sure you want to delete "$subject"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (shouldDelete == true) {
                    setState(() {
                      _subjects.removeAt(index);
                      _subjectMinutes.remove(subject);
                      if (_selectedSubject == subject) {
                        _selectedSubject = _subjects.isNotEmpty ? _subjects.first : '';
                      }
                    });
                    _saveData();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '${_subjectMinutes[subject] ?? 0} min',
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.87)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    Widget settingsBody = Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          // Focus time setting
          Row(
            children: [
              const Text('Focus time:', style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _focusMinutes,
                dropdownColor: Colors.grey[800],
                items: _focusOptions.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text('$m min', style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (val) async {
                  if (val != null) {
                    setState(() {
                      _focusMinutes = val;
                      if (!_isBreak) _seconds = _focusMinutes * 60;
                    });
                    await _saveData();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Break time setting
          Row(
            children: [
              const Text('Break time:', style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _breakMinutes,
                dropdownColor: Colors.grey[800],
                items: _breakOptions.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text('$m min', style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (val) async {
                  if (val != null) {
                    setState(() {
                      _breakMinutes = val;
                      if (_isBreak) _seconds = _breakMinutes * 60;
                    });
                    await _saveData();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // About
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  'Study Timer v1.0',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  'A simple and effective study companion',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    List<Widget> _pages = [timerBody, recordBody, settingsBody];

    if (_isRunning && !_isBreak) {
      // Focus mode
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerDisplay(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _toggleCountdown,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(_isRunning ? 'Pause' : 'Resume'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // Normal UI
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: _pages[_selectedIndex],
        floatingActionButton: _selectedIndex == 0
            ? SizedBox(
                width: 220,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: _toggleCountdown,
                      tooltip: _isRunning ? 'Pause' : 'Start',
                      backgroundColor: Colors.white,
                      child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.black),
                    ),
                    const SizedBox(width: 32),
                    FloatingActionButton(
                      onPressed: _resetTimer,
                      tooltip: 'Reset',
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.replay, color: Colors.black),
                    ),
                  ],
                ),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavBarTapped,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Timer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Record',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    }
  }
}