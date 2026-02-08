import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/round_button.dart';

class WhatTrainRow extends StatelessWidget {
  final Map wObj;
  const WhatTrainRow({Key? key, required this.wObj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primaryColor2.withOpacity(0.3),
              AppColors.primaryColor1.withOpacity(0.3)
            ]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wObj["title"].toString(),
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${wObj["exercises"]?.toString() ?? ''} | ${wObj["time"]?.toString() ?? ''}",
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: RoundButton(title: "View More", onPressed: () {}),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Flexible(
                flex: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withOpacity(0.54),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: _buildImage(wObj["image"].toString()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 90,
        height: 90,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 90,
            height: 90,
            color: AppColors.lightGrayColor,
            child: Icon(Icons.fitness_center, color: AppColors.grayColor),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath.isNotEmpty ? imagePath : 'assets/images/placeholder.png',
        width: 90,
        height: 90,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 90,
            height: 90,
            color: AppColors.lightGrayColor,
            child: Icon(Icons.fitness_center, color: AppColors.grayColor),
          );
        },
      );
    }
  }
}
