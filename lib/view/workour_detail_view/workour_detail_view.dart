import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/exercises_set_section.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/icon_title_next_row.dart';
import 'package:fitnessapp/view/workout_schedule_view/workout_schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../common_widgets/round_button.dart';
import 'exercises_stpe_details.dart';

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  const WorkoutDetailView({Key? key, required this.dObj}) : super(key: key);

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  List youArr = [];
  List exercisesArr = [];
  bool isLoading = true;
  String workoutImageUrl = "";

  @override
  void initState() {
    super.initState();
    loadWorkoutData();
  }

  void loadWorkoutData() {
    setState(() {
      isLoading = true;
    });

    try {
      // Handle workout image
      if (widget.dObj['photo'] != null &&
          widget.dObj['photo'].toString().isNotEmpty) {
        workoutImageUrl =
            '${dotenv.env['ENDPOINT']}/workouts/uploads/${widget.dObj['photo']}';
      } else if (widget.dObj['image'] != null &&
          widget.dObj['image'].toString().isNotEmpty) {
        // Fallback to 'image' field if 'photo' doesn't exist
        if (widget.dObj['image'].toString().startsWith('http')) {
          workoutImageUrl = widget.dObj['image'].toString();
        } else {
          workoutImageUrl =
              '${dotenv.env['ENDPOINT']}/workouts/uploads/${widget.dObj['image']}';
        }
      }

      // Map materials from API to youArr format
      if (widget.dObj['materials'] != null) {
        youArr = (widget.dObj['materials'] as List).map((mat) {
          String imagePath;
          if (mat['image'] != null && mat['image'].toString().isNotEmpty) {
            imagePath =
                '${dotenv.env['ENDPOINT']}/workouts/uploads/${mat['image']}';
          } else {
            imagePath = 'assets/images/placeholder.png';
          }

          return {
            'image': imagePath,
            'title': mat['title'] ?? '',
          };
        }).toList();
      }

      // Map sets and exercises from API to exercisesArr format
      if (widget.dObj['sets'] != null) {
        exercisesArr = (widget.dObj['sets'] as List).map((set) {
          List exercises = [];

          if (set['exercises'] != null) {
            exercises = (set['exercises'] as List).map((ex) {
              String imagePath;
              if (ex['image'] != null && ex['image'].toString().isNotEmpty) {
                imagePath =
                    '${dotenv.env['ENDPOINT']}/workouts/uploads/${ex['image']}';
              } else {
                imagePath = 'assets/images/placeholder.png';
              }

              return {
                'image': imagePath,
                'title': ex['title'] ?? '',
                'value': ex['value'] ?? '',
                'id': ex['id'], // Keep the ID for fetching exercise details
              };
            }).toList();
          }

          return {
            'name': set['name'] ?? 'Set',
            'set': exercises,
          };
        }).toList();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading workout data: $e');
      setState(() {
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
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              pinned: false,
              expandedHeight: media.height * 0.4, // Takes more vertical space
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full-width workout image
                    workoutImageUrl.isNotEmpty
                        ? Image.network(
                            workoutImageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: AppColors.primaryG),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading workout image: $error');
                              return Image.asset(
                                "assets/images/detail_top.png",
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            "assets/images/detail_top.png",
                            fit: BoxFit.cover,
                          ),
                    // Gradient overlay for better button visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.3],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: Container(
                margin: const EdgeInsets.all(8),
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/icons/back_icon.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: Image.asset(
                      "assets/icons/more_icon.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: isLoading
                ? Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: AppColors.grayColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.dObj["name"]?.toString() ??
                                            widget.dObj["title"]?.toString() ??
                                            "",
                                        style: TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "${exercisesArr.length} Sets | ${widget.dObj["duration"]?.toString() ?? "0"} min | 320 Calories Burn",
                                        style: TextStyle(
                                            color: AppColors.grayColor,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Image.asset(
                                    "assets/icons/fav_icon.png",
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            IconTitleNextRow(
                                icon: "assets/icons/time_icon.png",
                                title: "Schedule Workout",
                                time: "5/27, 09:00 AM",
                                color: AppColors.primaryColor2.withOpacity(0.3),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, WorkoutScheduleView.routeName);
                                }),
                            SizedBox(
                              height: media.width * 0.02,
                            ),
                            IconTitleNextRow(
                                icon: "assets/icons/difficulity_icon.png",
                                title: "Difficulty",
                                time: widget.dObj["difficulty"]?.toString() ??
                                    "Beginner",
                                color:
                                    AppColors.secondaryColor2.withOpacity(0.3),
                                onPressed: () {}),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            if (youArr.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "You'll Need",
                                    style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "${youArr.length} Items",
                                      style: TextStyle(
                                          color: AppColors.grayColor,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: media.width * 0.5,
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: youArr.length,
                                    itemBuilder: (context, index) {
                                      var yObj = youArr[index] as Map? ?? {};
                                      bool isNetworkImage = yObj["image"]
                                          .toString()
                                          .startsWith('http');

                                      return Container(
                                          margin: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: media.width * 0.35,
                                                width: media.width * 0.35,
                                                decoration: BoxDecoration(
                                                    color: AppColors
                                                        .lightGrayColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                alignment: Alignment.center,
                                                child: isNetworkImage
                                                    ? Image.network(
                                                        yObj["image"]
                                                            .toString(),
                                                        width:
                                                            media.width * 0.2,
                                                        height:
                                                            media.width * 0.2,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              size:
                                                                  media.width *
                                                                      0.2);
                                                        },
                                                      )
                                                    : Image.asset(
                                                        yObj["image"]
                                                            .toString(),
                                                        width:
                                                            media.width * 0.2,
                                                        height:
                                                            media.width * 0.2,
                                                        fit: BoxFit.contain,
                                                      ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  yObj["title"].toString(),
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.blackColor,
                                                      fontSize: 12),
                                                ),
                                              )
                                            ],
                                          ));
                                    }),
                              ),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Exercises",
                                  style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "${exercisesArr.length} Sets",
                                    style: TextStyle(
                                        color: AppColors.grayColor,
                                        fontSize: 12),
                                  ),
                                )
                              ],
                            ),
                            ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: exercisesArr.length,
                                itemBuilder: (context, index) {
                                  var sObj = exercisesArr[index] as Map? ?? {};
                                  return ExercisesSetSection(
                                    sObj: sObj,
                                    onPressed: (obj) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ExercisesStepDetails(
                                            eObj: obj,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                            SizedBox(
                              height: media.width * 0.1,
                            ),
                          ],
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RoundGradientButton(
                                title: "Start Workout", onPressed: () {})
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
