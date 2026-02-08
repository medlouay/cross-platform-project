import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/activity/widgets/upcoming_workout_row.dart';
import 'package:fitnessapp/view/activity/widgets/what_train_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../common_widgets/round_button.dart';
import '../workour_detail_view/workour_detail_view.dart';
import '../../utils/workout_api.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List latestArr = [];
  List whatArr = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final workouts = await WorkoutApi.fetchWorkouts();
      // Debug: print the API response to console
      print('API response:');
      print(workouts);

      // Map API data to expected widget fields for UI
      List mapped = workouts.map((w) {
        // Build image: use network URL if photo exists, else use a local placeholder asset
        String imagePath;
        if (w['photo'] != null && w['photo'].toString().isNotEmpty) {
          imagePath = '${dotenv.env['ENDPOINT']}/workouts/uploads/${w['photo']}';
        } else {
          imagePath = 'assets/images/placeholder.png';
        }
        return {
          'title': w['name'] ?? '',
          'image': imagePath,
          'time': w['duration'] != null ? '${w['duration']} min' : '',
          ...w,
        };
      }).toList();

      setState(() {
        latestArr = mapped;
        whatArr = mapped;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          // ...existing code...
          return [
            // ...existing code...
          ];
        },
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMsg != null
                      ? Center(child: Text(errorMsg!))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                width: 50,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: AppColors.grayColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(3)),
                              ),
                              SizedBox(height: media.width * 0.05),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor2.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Daily Workout Schedule",
                                      style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      height: 25,
                                      child: RoundButton(
                                        title: "Check",
                                        onPressed: () {},
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: media.width * 0.05),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Upcoming Workout",
                                    style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
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
                                    return UpcomingWorkoutRow(wObj: wObj);
                                  }),
                              SizedBox(height: media.width * 0.05),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "What Do You Want to Train",
                                    style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: whatArr.length,
                                  itemBuilder: (context, index) {
                                    var wObj = whatArr[index] as Map? ?? {};
                                    return InkWell(
                                      onTap: () async {
                                        // Fetch workout details by ID
                                        try {
                                          final workout =
                                              await WorkoutApi.fetchWorkoutById(
                                                  wObj['id'].toString());
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WorkoutDetailView(
                                                      dObj: workout),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to load workout details')),
                                          );
                                        }
                                      },
                                      child: WhatTrainRow(wObj: wObj),
                                    );
                                  }),
                              SizedBox(height: media.width * 0.1),
                            ],
                          ),
                        ),
            )),
      ),
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: AppColors.whiteColor,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        color: AppColors.whiteColor.withOpacity(0.5),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: AppColors.whiteColor,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
