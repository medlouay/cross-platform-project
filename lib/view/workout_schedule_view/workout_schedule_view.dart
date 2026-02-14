import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../utils/common.dart';
import '../../utils/schedule_api.dart';
import 'add_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  static String routeName = "/WorkoutScheduleView";
  const WorkoutScheduleView({Key? key}) : super(key: key);

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;

  List selectDayEventArr = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    fetchSchedulesForDate();
  }

  Future<void> fetchSchedulesForDate() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDateAppBBar);
      final schedules = await ScheduleApi.fetchSchedulesByDate(dateStr);

      setState(() {
        selectDayEventArr = schedules.map((schedule) {
          // Parse time (HH:mm:ss format from DB)
          final timeParts = schedule['scheduled_time'].toString().split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          // Create full datetime
          final scheduledDateTime = DateTime(
            _selectedDateAppBBar.year,
            _selectedDateAppBBar.month,
            _selectedDateAppBBar.day,
            hour,
            minute,
          );

          // Format time for display
          final timeStr = DateFormat('hh:mm a').format(scheduledDateTime);

          String imagePath = '';
          if (schedule['workout_photo'] != null &&
              schedule['workout_photo'].toString().isNotEmpty) {
            imagePath =
                '${dotenv.env['ENDPOINT']}/workouts/uploads/${schedule['workout_photo']}';
          }

          return {
            'id': schedule['id'],
            'workout_id': schedule['workout_id'],
            'name': schedule['workout_name'] ?? 'Workout',
            'start_time': timeStr,
            'date': scheduledDateTime,
            'status': schedule['status'],
            'difficulty': schedule['difficulty'],
            'duration': schedule['duration'],
            'image': imagePath,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching schedules: $e');
      setState(() {
        selectDayEventArr = [];
        isLoading = false;
      });
    }
  }

  Future<void> markScheduleAsCompleted(int scheduleId) async {
    try {
      await ScheduleApi.markAsCompleted(scheduleId.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout marked as completed!')),
      );
      fetchSchedulesForDate(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as completed')),
      );
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await ScheduleApi.deleteSchedule(scheduleId.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule deleted')),
      );
      fetchSchedulesForDate(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete schedule')),
      );
    }
  }

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
        title: Text(
          "Workout Schedule",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
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
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/icons/ArrowLeft.png",
                  width: 15,
                  height: 15,
                )),
            training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/icons/ArrowRight.png",
                  width: 15,
                  height: 15,
                )),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'en',
            initialDate: DateTime.now(),
            calendarEventColor: AppColors.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            onDateSelected: (date) {
              _selectedDateAppBBar = date;
              fetchSchedulesForDate();
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: AppColors.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: media.width * 1.5,
                      child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var availWidth = (media.width * 1.2) - (80 + 40);
                            var slotArr = selectDayEventArr.where((wObj) {
                              return (wObj["date"] as DateTime).hour == index;
                            }).toList();

                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      getTime(index * 60),
                                      style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (slotArr.isNotEmpty)
                                    Expanded(
                                        child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: slotArr.map((sObj) {
                                        var min =
                                            (sObj["date"] as DateTime).minute;
                                        var pos = (min / 60) * 2 - 1;

                                        bool isCompleted =
                                            sObj['status'] == 'completed';

                                        return Align(
                                          alignment: Alignment(pos, 0),
                                          child: InkWell(
                                            onTap: () {
                                              showScheduleDialog(sObj);
                                            },
                                            child: Container(
                                              height: 35,
                                              width: availWidth * 0.5,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: isCompleted
                                                        ? [
                                                            Colors.green,
                                                            Colors.green
                                                                .shade700
                                                          ]
                                                        : AppColors.secondaryG),
                                                borderRadius:
                                                    BorderRadius.circular(17.5),
                                              ),
                                              child: Row(
                                                children: [
                                                  if (isCompleted)
                                                    Icon(Icons.check_circle,
                                                        size: 16,
                                                        color: AppColors
                                                            .whiteColor),
                                                  if (isCompleted)
                                                    SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      "${sObj["name"].toString()}, ${sObj["start_time"].toString()}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .whiteColor,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ))
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: AppColors.grayColor.withOpacity(0.2),
                              height: 1,
                            );
                          },
                          itemCount: 24),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddScheduleView(
                        date: _selectedDateAppBBar,
                      )));

          // Refresh schedules if a new one was added
          if (result == true) {
            fetchSchedulesForDate();
          }
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }

  void showScheduleDialog(Map sObj) {
    bool isCompleted = sObj['status'] == 'completed';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
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
                          "assets/icons/closed_btn.png",
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Text(
                      "Workout Schedule",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showDeleteConfirmation(sObj['id']);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColors.lightGrayColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.delete,
                            size: 20, color: Colors.red.shade400),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  sObj["name"].toString(),
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Image.asset(
                    "assets/icons/time_workout.png",
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${DateFormat('E, dd MMM').format(sObj["date"])} | ${sObj["start_time"]}",
                    style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                  )
                ]),
                if (sObj['difficulty'] != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.fitness_center, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Difficulty: ${sObj['difficulty']}",
                      style:
                          TextStyle(color: AppColors.grayColor, fontSize: 12),
                    )
                  ]),
                ],
                if (isCompleted) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Completed",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 15),
                if (!isCompleted)
                  RoundGradientButton(
                      title: "Mark Done",
                      onPressed: () {
                        Navigator.pop(context);
                        markScheduleAsCompleted(sObj['id']);
                      }),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmation(int scheduleId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Schedule"),
          content: Text("Are you sure you want to delete this schedule?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteSchedule(scheduleId);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}