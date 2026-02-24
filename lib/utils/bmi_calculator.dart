import 'package:flutter/material.dart';

class BMICalculator {
  static double calculateBMI(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) return 0;

    // Convert height from cm to meters
    double heightM = heightCm / 100;

    // BMI = weight (kg) / height² (m²)
    double bmi = weightKg / (heightM * heightM);

    return double.parse(bmi.toStringAsFixed(1));
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  static String getBMIDescription(double bmi) {
    if (bmi < 18.5) {
      return 'You are underweight. Focus on muscle building and proper nutrition.';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'You have a healthy weight. Maintain it with balanced exercise.';
    } else if (bmi >= 25 && bmi < 30) {
      return 'You are slightly overweight. Focus on cardio and strength training.';
    } else {
      return 'You are obese. Consult a doctor and start with light exercises.';
    }
  }

  static List<Map<String, dynamic>> getWorkoutPlan(double bmi, int age) {
    String category = getBMICategory(bmi);

    // Adjust intensity based on age
    bool isYoung = age < 30;
    bool isMiddleAge = age >= 30 && age < 50;
    bool isSenior = age >= 50;

    if (category == 'Underweight') {
      return _getUnderweightPlan(isYoung, isMiddleAge, isSenior);
    } else if (category == 'Normal') {
      return _getNormalPlan(isYoung, isMiddleAge, isSenior);
    } else if (category == 'Overweight') {
      return _getOverweightPlan(isYoung, isMiddleAge, isSenior);
    } else {
      return _getObesePlan(isYoung, isMiddleAge, isSenior);
    }
  }

  // Underweight workout plan - Focus on muscle building
  static List<Map<String, dynamic>> _getUnderweightPlan(bool isYoung, bool isMiddleAge, bool isSenior) {
    return [
      {
        'day': 'Monday',
        'focus': 'Upper Body Strength',
        'exercises': [
          {'name': 'Push-ups', 'sets': isYoung ? 4 : (isMiddleAge ? 3 : 2), 'reps': '10-12'},
          {'name': 'Dumbbell Rows', 'sets': 3, 'reps': '12-15'},
          {'name': 'Bench Press', 'sets': 4, 'reps': '8-10'},
          {'name': 'Bicep Curls', 'sets': 3, 'reps': '12-15'},
        ],
      },
      {
        'day': 'Wednesday',
        'focus': 'Lower Body Strength',
        'exercises': [
          {'name': 'Squats', 'sets': 4, 'reps': '10-12'},
          {'name': 'Lunges', 'sets': 3, 'reps': '12 each leg'},
          {'name': 'Leg Press', 'sets': 4, 'reps': '10-12'},
          {'name': 'Calf Raises', 'sets': 3, 'reps': '15-20'},
        ],
      },
      {
        'day': 'Friday',
        'focus': 'Full Body',
        'exercises': [
          {'name': 'Deadlifts', 'sets': 3, 'reps': '8-10'},
          {'name': 'Pull-ups', 'sets': 3, 'reps': '6-8'},
          {'name': 'Shoulder Press', 'sets': 3, 'reps': '10-12'},
          {'name': 'Planks', 'sets': 3, 'reps': '30-60 sec'},
        ],
      },
    ];
  }

  // Normal weight workout plan - Balanced fitness
  static List<Map<String, dynamic>> _getNormalPlan(bool isYoung, bool isMiddleAge, bool isSenior) {
    return [
      {
        'day': 'Monday',
        'focus': 'Cardio & Core',
        'exercises': [
          {'name': 'Running', 'sets': 1, 'reps': isYoung ? '30 min' : (isMiddleAge ? '25 min' : '20 min')},
          {'name': 'Planks', 'sets': 3, 'reps': '45-60 sec'},
          {'name': 'Crunches', 'sets': 3, 'reps': '20-25'},
          {'name': 'Mountain Climbers', 'sets': 3, 'reps': '15-20'},
        ],
      },
      {
        'day': 'Wednesday',
        'focus': 'Strength Training',
        'exercises': [
          {'name': 'Squats', 'sets': 4, 'reps': '12-15'},
          {'name': 'Push-ups', 'sets': 3, 'reps': '15-20'},
          {'name': 'Dumbbell Rows', 'sets': 3, 'reps': '12-15'},
          {'name': 'Lunges', 'sets': 3, 'reps': '12 each leg'},
        ],
      },
      {
        'day': 'Friday',
        'focus': 'HIIT & Flexibility',
        'exercises': [
          {'name': 'Burpees', 'sets': 3, 'reps': '10-15'},
          {'name': 'Jump Squats', 'sets': 3, 'reps': '12-15'},
          {'name': 'Yoga/Stretching', 'sets': 1, 'reps': '15 min'},
          {'name': 'Bicycle Crunches', 'sets': 3, 'reps': '20-25'},
        ],
      },
    ];
  }

  // Overweight workout plan - Focus on fat burning
  static List<Map<String, dynamic>> _getOverweightPlan(bool isYoung, bool isMiddleAge, bool isSenior) {
    return [
      {
        'day': 'Monday',
        'focus': 'Cardio',
        'exercises': [
          {'name': 'Brisk Walking', 'sets': 1, 'reps': isYoung ? '40 min' : (isMiddleAge ? '35 min' : '30 min')},
          {'name': 'Cycling', 'sets': 1, 'reps': '20 min'},
          {'name': 'Jumping Jacks', 'sets': 3, 'reps': '15-20'},
          {'name': 'Step-ups', 'sets': 3, 'reps': '12-15'},
        ],
      },
      {
        'day': 'Wednesday',
        'focus': 'Low-Impact Cardio',
        'exercises': [
          {'name': 'Swimming', 'sets': 1, 'reps': '30 min'},
          {'name': 'Elliptical', 'sets': 1, 'reps': '25 min'},
          {'name': 'Wall Push-ups', 'sets': 3, 'reps': '12-15'},
          {'name': 'Seated Rows', 'sets': 3, 'reps': '12-15'},
        ],
      },
      {
        'day': 'Friday',
        'focus': 'Full Body Circuit',
        'exercises': [
          {'name': 'Bodyweight Squats', 'sets': 3, 'reps': '15-20'},
          {'name': 'Incline Push-ups', 'sets': 3, 'reps': '10-15'},
          {'name': 'High Knees', 'sets': 3, 'reps': '30 sec'},
          {'name': 'Planks', 'sets': 3, 'reps': '30-45 sec'},
        ],
      },
      {
        'day': 'Saturday',
        'focus': 'Active Recovery',
        'exercises': [
          {'name': 'Light Walking', 'sets': 1, 'reps': '30 min'},
          {'name': 'Yoga', 'sets': 1, 'reps': '20 min'},
          {'name': 'Stretching', 'sets': 1, 'reps': '15 min'},
        ],
      },
    ];
  }

  // Obese workout plan - Very low impact, gradual progress
  static List<Map<String, dynamic>> _getObesePlan(bool isYoung, bool isMiddleAge, bool isSenior) {
    return [
      {
        'day': 'Monday',
        'focus': 'Gentle Cardio',
        'exercises': [
          {'name': 'Walking', 'sets': 1, 'reps': isYoung ? '25 min' : (isMiddleAge ? '20 min' : '15 min')},
          {'name': 'Chair Exercises', 'sets': 2, 'reps': '10 min'},
          {'name': 'Arm Circles', 'sets': 2, 'reps': '10-15'},
          {'name': 'Seated Marching', 'sets': 3, 'reps': '1 min'},
        ],
      },
      {
        'day': 'Wednesday',
        'focus': 'Low-Impact Movement',
        'exercises': [
          {'name': 'Water Aerobics', 'sets': 1, 'reps': '20 min'},
          {'name': 'Seated Leg Lifts', 'sets': 2, 'reps': '10-12'},
          {'name': 'Wall Push-ups', 'sets': 2, 'reps': '8-10'},
          {'name': 'Breathing Exercises', 'sets': 3, 'reps': '2 min'},
        ],
      },
      {
        'day': 'Friday',
        'focus': 'Flexibility & Balance',
        'exercises': [
          {'name': 'Chair Yoga', 'sets': 1, 'reps': '15 min'},
          {'name': 'Gentle Stretching', 'sets': 1, 'reps': '15 min'},
          {'name': 'Balance Exercises', 'sets': 2, 'reps': '5 min'},
          {'name': 'Light Walking', 'sets': 1, 'reps': '15 min'},
        ],
      },
    ];
  }

  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return const Color(0xFF4A90E2); // Blue - Underweight
    } else if (bmi >= 18.5 && bmi < 25) {
      return const Color(0xFF50C878); // Green - Normal
    } else if (bmi >= 25 && bmi < 30) {
      return const Color(0xFFFFA500); // Orange - Overweight
    } else {
      return const Color(0xFFE74C3C); // Red - Obese
    }
  }
}