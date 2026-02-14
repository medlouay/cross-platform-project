import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/step_detail_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/workout_api.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Map eObj;
  const ExercisesStepDetails({Key? key, required this.eObj}) : super(key: key);

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  List stepArr = [];
  bool isLoading = true;
  String? errorMsg;
  Map<String, dynamic> exerciseData = {};

  @override
  void initState() {
    super.initState();
    loadExerciseDetails();
  }

  Future<void> loadExerciseDetails() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      // Check if we have an exercise ID to fetch from API
      if (widget.eObj['id'] != null) {
        final exercise = await WorkoutApi.fetchExerciseById(
          widget.eObj['id'].toString()
        );
        
        exerciseData = exercise;
        
        // Map steps from API
        if (exercise['steps'] != null) {
          stepArr = (exercise['steps'] as List).asMap().entries.map((entry) {
            var step = entry.value;
            return {
              'no': (entry.key + 1).toString().padLeft(2, '0'),
              'title': step['title'] ?? '',
              'detail': step['description'] ?? '',
            };
          }).toList();
        }
      } else {
        // Use data passed directly (fallback)
        exerciseData = Map<String, dynamic>.from(widget.eObj);
        if (widget.eObj['steps'] != null) {
          stepArr = (widget.eObj['steps'] as List).asMap().entries.map((entry) {
            var step = entry.value;
            return {
              'no': (entry.key + 1).toString().padLeft(2, '0'),
              'title': step['title'] ?? '',
              'detail': step['description'] ?? '',
            };
          }).toList();
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading exercise details: $e');
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
        // Use passed data as fallback
        exerciseData = Map<String, dynamic>.from(widget.eObj);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: AppColors.whiteColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    bool isNetworkImage = (exerciseData["image"]?.toString().startsWith('http') ?? false);
    String imageUrl = exerciseData["image"]?.toString() ?? "";
    String title = exerciseData["title"]?.toString() ?? widget.eObj["title"]?.toString() ?? "";
    String value = exerciseData["value"]?.toString() ?? widget.eObj["value"]?.toString() ?? "";

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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryG),
                        borderRadius: BorderRadius.circular(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: isNetworkImage
                          ? Image.network(
                              imageUrl,
                              width: media.width,
                              height: media.width * 0.43,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/video_temp.png",
                                  width: media.width,
                                  height: media.width * 0.43,
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              imageUrl.isNotEmpty 
                                  ? imageUrl 
                                  : "assets/images/video_temp.png",
                              width: media.width,
                              height: media.width * 0.43,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                        color: AppColors.blackColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      "assets/icons/play_icon.png",
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                title,
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "$value | 390 Calories Burn",
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Descriptions",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              ReadMoreText(
                exerciseData['description']?.toString() ?? 
                'A jumping jack, also known as a star jump and called a side-straddle hop in the US military, is a physical jumping exercise performed by jumping to a position with the legs spread wide.',
                trimLines: 4,
                colorClickableText: AppColors.blackColor,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read More ...',
                trimExpandedText: ' Read Less',
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
                moreStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 15,
              ),
              if (stepArr.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "How To Do It",
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "${stepArr.length} Steps",
                        style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                      ),
                    )
                  ],
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: stepArr.length,
                  itemBuilder: ((context, index) {
                    var sObj = stepArr[index] as Map? ?? {};

                    return StepDetailRow(
                      sObj: sObj,
                      isLast: stepArr.last == sObj,
                    );
                  }),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}