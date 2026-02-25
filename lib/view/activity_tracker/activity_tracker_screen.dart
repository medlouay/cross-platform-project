import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/dashboard_api.dart';
import 'package:fitnessapp/utils/health_service.dart';
import 'package:fitnessapp/utils/local_notifications.dart';
import 'package:fitnessapp/utils/session.dart';
import 'package:fitnessapp/view/activity_tracker/widgets/latest_activity_row.dart';
import 'package:fitnessapp/view/activity_tracker/widgets/today_target_cell.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityTrackerScreen extends StatefulWidget {
  static String routeName = "/ActivityTrackerScreen";
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  int touchedIndex = -1;
  int _todaySteps = 0;
  int _waterMl = 0;
  int _targetSteps = 0;
  int _targetWaterMl = 0;
  List<Map<String, dynamic>> _weeklySteps = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadTargets();
    _fetchData();
  }

  Future<void> _loadTargets() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetSteps = prefs.getInt('target_steps') ?? 0;
      _targetWaterMl = prefs.getInt('target_water_ml') ?? 0;
    });
  }

  Future<void> _saveTargets({
    required int stepsTarget,
    required int waterTargetMl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('target_steps', stepsTarget);
    await prefs.setInt('target_water_ml', waterTargetMl);
    if (!mounted) return;
    setState(() {
      _targetSteps = stepsTarget;
      _targetWaterMl = waterTargetMl;
    });

    final waterLiters = waterTargetMl > 0
        ? (waterTargetMl / 1000).toStringAsFixed(1)
        : '--';
    await LocalNotifications.showNotification(
      id: 2001,
      title: 'Today targets set',
      body: 'Steps: $stepsTarget, Water: ${waterLiters}L',
    );
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchData() async {
    final userId = Session.userId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Please log in';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final summary = await DashboardApi.fetchSummary(
        userId: userId,
        date: _todayString(),
      );
      final totals = summary['totals'] as Map? ?? {};
      final steps = _numFrom(totals['steps']);
      final water = _numFrom(totals['water_ml']);
      final weekly = (summary['weekly_steps'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() {
        _todaySteps = steps?.round() ?? 0;
        _waterMl = water?.round() ?? 0;
        _weeklySteps = weekly;
        _isLoading = false;
      });
      // Sync steps from device
      try {
        final synced = await HealthService.syncStepsToBackend(userId);
        if (synced != null && mounted) {
          final updated = await DashboardApi.fetchSummary(
            userId: userId,
            date: _todayString(),
          );
          final u = updated['totals'] as Map? ?? {};
          setState(() {
            _todaySteps = _numFrom(u['steps'])?.round() ?? _todaySteps;
          });
        }
      } catch (_) {}
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  num? _numFrom(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '');
  }

  List latestArr = [
    {
      "image": "assets/images/pic_4.png",
      "title": "Drinking 300ml Water",
      "time": "About 1 minutes ago"
    },
    {
      "image": "assets/images/pic_5.png",
      "title": "Eat Snack (Fitbar)",
      "time": "About 3 hours ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Activity Tracker",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: _isLoading ? null : () => _fetchData(),
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primaryColor2.withOpacity(0.3),
                    AppColors.primaryColor1.withOpacity(0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today Target",
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryG,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: _showTargetDialog,
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: AppColors.primaryColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/water_icon.png",
                            value: _formatWaterValue(),
                            title: "Water Intake",
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/foot_icon.png",
                            value: _formatStepsValue(),
                            title: "Foot Steps",
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Activity Progress",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryG),
                        borderRadius: BorderRadius.circular(15)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        items: ["Weekly", "Monthly"]
                            .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 14),
                            )))
                            .toList(),
                        onChanged: (value) {},
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.whiteColor),
                        hint: const Text("Weekly",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.whiteColor, fontSize: 12)),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.5,
                padding: const EdgeInsets.symmetric(vertical: 15 , horizontal: 0),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ]),
                child: BarChart(

                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey,
                          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                          tooltipMargin: 10,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String weekDay;
                            switch (group.x) {
                              case 0:
                                weekDay = 'Sunday';
                                break;
                              case 1:
                                weekDay = 'Monday';
                                break;
                              case 2:
                                weekDay = 'Tuesday';
                                break;
                              case 3:
                                weekDay = 'Wednesday';
                                break;
                              case 4:
                                weekDay = 'Thursday';
                                break;
                              case 5:
                                weekDay = 'Friday';
                                break;
                              case 6:
                                weekDay = 'Saturday';
                                break;
                              default:
                                throw Error();
                            }
                            return BarTooltipItem(
                              '$weekDay\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: (rod.toY - 1).toString(),
                                  style: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                barTouchResponse.spot!.touchedBarGroupIndex;
                          });
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles:  AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles:  AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: getTitles,
                            reservedSize: 38,
                          ),
                        ),
                        leftTitles:  AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: showingGroups(),
                      gridData:  FlGridData(show: false),
                    )

                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Latest Workout",
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See More",
                      style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: latestArr.length,
                  itemBuilder: (context, index) {
                    var wObj = latestArr[index] as Map? ?? {};
                    return LatestActivityRow(wObj: wObj);
                  }),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStepsValue() {
    if (_isLoading) return '...';
    if (_targetSteps > 0) {
      return '$_todaySteps / $_targetSteps';
    }
    return '$_todaySteps';
  }

  String _formatWaterValue() {
    if (_isLoading) return '...';
    final current = _waterMl > 0
        ? (_waterMl / 1000).toStringAsFixed(1)
        : '0.0';
    if (_targetWaterMl > 0) {
      final target = (_targetWaterMl / 1000).toStringAsFixed(1);
      return '$current / ${target}L';
    }
    return '${current}L';
  }

  Future<void> _showTargetDialog() async {
    final stepsController =
        TextEditingController(text: _targetSteps > 0 ? '$_targetSteps' : '');
    final waterController = TextEditingController(
      text: _targetWaterMl > 0 ? '$_targetWaterMl' : '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Today Targets'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Steps target',
                  hintText: 'e.g., 8000',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waterController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Water target (ml)',
                  hintText: 'e.g., 2000',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) return;
    final steps = int.tryParse(stepsController.text.trim()) ?? 0;
    final water = int.tryParse(waterController.text.trim()) ?? 0;
    await _saveTargets(stepsTarget: steps, waterTargetMl: water);
  }

  Widget getTitles(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: AppColors.grayColor,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text =  Text('Sun', style: style);
        break;
      case 1:
        text =  Text('Mon', style: style);
        break;
      case 2:
        text =  Text('Tue', style: style);
        break;
      case 3:
        text =  Text('Wed', style: style);
        break;
      case 4:
        text =  Text('Thu', style: style);
        break;
      case 5:
        text =  Text('Fri', style: style);
        break;
      case 6:
        text =  Text('Sat', style: style);
        break;
      default:
        text =  Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  double _stepsForDay(int index) {
    if (_weeklySteps.isEmpty || index >= _weeklySteps.length) return 0;
    final s = _weeklySteps[index]['steps'];
    if (s is num) return s.toDouble();
    return (num.tryParse(s?.toString() ?? '0') ?? 0).toDouble();
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
    final value = _weeklySteps.isNotEmpty
        ? _stepsForDay(i)
        : [5, 10.5, 5, 7.5, 15, 5.5, 8.5][i];
    final colors = i.isEven ? AppColors.primaryG : AppColors.secondaryG;
    return makeGroupData(i, value.clamp(0, 20).toDouble(), colors,
        isTouched: i == touchedIndex);
  });

  BarChartGroupData makeGroupData(
      int x,
      double y,
      List<Color> barColor,
      {
        bool isTouched = false,

        double width = 22,
        List<int> showTooltips = const [],
      }) {

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(colors: barColor, begin: Alignment.topCenter, end: Alignment.bottomCenter ),
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: AppColors.lightGrayColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
