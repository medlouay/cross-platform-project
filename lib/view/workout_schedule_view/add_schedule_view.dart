import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common_widgets/round_button.dart';
import '../../utils/common.dart';
import '../../utils/schedule_api.dart';
import '../../utils/schedule_notification_service.dart';
import '../../utils/session.dart';
import '../../utils/workout_api.dart';
import '../workour_detail_view/widgets/icon_title_next_row.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  DateTime selectedTime = DateTime.now();
  List<dynamic> workouts = [];
  Map<String, dynamic>? selectedWorkout;
  String selectedDifficulty = "Beginner";
  int? customRepetitions;
  String? customWeights;
  bool isLoading = true;
  bool isSaving = false;

  final List<String> difficulties = [
    "Beginner",
    "Intermediate",
    "Advanced"
  ];

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    try {
      final data = await WorkoutApi.fetchWorkouts();
      setState(() {
        workouts = data;
        isLoading = false;
        if (workouts.isNotEmpty) {
          selectedWorkout = workouts[0];
          selectedDifficulty = selectedWorkout?['difficulty'] ?? 'Beginner';
        }
      });
    } catch (e) {
      print('Error fetching workouts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveSchedule() async {
    if (selectedWorkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a workout')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final scheduledDate = DateFormat('yyyy-MM-dd').format(widget.date);
      final scheduledTime = DateFormat('HH:mm:ss').format(selectedTime);

      final created = await ScheduleApi.createSchedule(
        userId: Session.userId,
        workoutId: selectedWorkout!['id'],
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        duration: selectedWorkout!['duration'],
        difficulty: selectedDifficulty,
        repetitions: customRepetitions,
        weights: customWeights,
      );

      final scheduleId = created['schedule_id'];
      if (scheduleId != null) {
        await ScheduleNotificationService.scheduleFromParts(
          scheduleId: int.parse(scheduleId.toString()),
          scheduledDate: scheduledDate,
          scheduledTime: scheduledTime,
          workoutName: selectedWorkout?['name']?.toString() ?? 'Workout',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule added successfully!')),
      );

      // Return true to indicate success
      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add schedule')),
      );
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
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
              "assets/icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
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
      backgroundColor: AppColors.whiteColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/date.png",
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                          style: TextStyle(
                              color: AppColors.grayColor, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Time",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: media.width * 0.35,
                      child: CupertinoDatePicker(
                        onDateTimeChanged: (newDate) {
                          setState(() {
                            selectedTime = newDate;
                          });
                        },
                        initialDateTime: selectedTime,
                        use24hFormat: false,
                        minuteInterval: 1,
                        mode: CupertinoDatePickerMode.time,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Details Workout",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    IconTitleNextRow(
                        icon: "assets/icons/choose_workout.png",
                        title: "Choose Workout",
                        time: selectedWorkout?['name'] ?? "Select",
                        color: AppColors.lightGrayColor,
                        onPressed: () {
                          showWorkoutPicker();
                        }),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                        icon: "assets/icons/difficulity_icon.png",
                        title: "Difficulty",
                        time: selectedDifficulty,
                        color: AppColors.lightGrayColor,
                        onPressed: () {
                          showDifficultyPicker();
                        }),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                        icon: "assets/icons/repetitions.png",
                        title: "Custom Repetitions",
                        time: customRepetitions?.toString() ?? "",
                        color: AppColors.lightGrayColor,
                        onPressed: () {
                          showRepetitionsPicker();
                        }),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                        icon: "assets/icons/repetitions.png",
                        title: "Custom Weights",
                        time: customWeights ?? "",
                        color: AppColors.lightGrayColor,
                        onPressed: () {
                          showWeightsDialog();
                        }),
                    Spacer(),
                    RoundGradientButton(
                      title: isSaving ? "Saving..." : "Save",
                      onPressed: isSaving ? () {} : saveSchedule,
                    ),
                    const SizedBox(height: 20),
                  ]),
            ),
    );
  }

  void showWorkoutPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Select Workout",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return ListTile(
                      title: Text(workout['name'] ?? ''),
                      subtitle: Text(
                          '${workout['duration']} min • ${workout['difficulty']}'),
                      selected: selectedWorkout?['id'] == workout['id'],
                      onTap: () {
                        setState(() {
                          selectedWorkout = workout;
                          selectedDifficulty = workout['difficulty'] ?? 'Beginner';
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDifficultyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Select Difficulty",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: difficulties.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(difficulties[index]),
                      selected: selectedDifficulty == difficulties[index],
                      onTap: () {
                        setState(() {
                          selectedDifficulty = difficulties[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showRepetitionsPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Select Repetitions",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      customRepetitions = (index + 1) * 5;
                    });
                  },
                  children: List.generate(
                    20,
                    (index) => Center(
                      child: Text('${(index + 1) * 5} reps'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Done"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showWeightsDialog() {
    final controller = TextEditingController(text: customWeights);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Custom Weights"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "e.g., 10kg, 20lbs",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customWeights = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
