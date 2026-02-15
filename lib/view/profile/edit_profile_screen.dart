import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/profile_api.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final String? currentHeight;
  final String? currentWeight;
  final String? currentAge;

  const EditProfileScreen({
    Key? key,
    this.currentHeight,
    this.currentWeight,
    this.currentAge,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current values if they exist
    _heightController.text = widget.currentHeight ?? '';
    _weightController.text = widget.currentWeight ?? '';
    _ageController.text = widget.currentAge ?? '';
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    final age = _ageController.text.trim();

    if (height.isEmpty || weight.isEmpty || age.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    // Validate numbers
    final heightNum = int.tryParse(height);
    final weightNum = int.tryParse(weight);
    final ageNum = int.tryParse(age);

    if (heightNum == null || weightNum == null || ageNum == null) {
      _showMessage("Please enter valid numbers");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ProfileApi.updateProfile(
        height: heightNum,
        weight: weightNum,
        age: ageNum,
      );

      if (!mounted) return;
      _showMessage("Profile updated successfully");

      // Return the updated values to the previous screen
      Navigator.pop(context, {
        'height': height,
        'weight': weight,
        'age': age,
      });
    } catch (e) {
      print('Error updating profile: $e');
      _showMessage('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: media.width * 0.05),

                const Text(
                  "Update Your Information",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: media.width * 0.05),

                RoundTextField(
                  textEditingController: _heightController,
                  hintText: "Height (cm)",
                  icon: "assets/icons/p_personal.png",
                  textInputType: TextInputType.number,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  textEditingController: _weightController,
                  hintText: "Weight (kg)",
                  icon: "assets/icons/p_activity.png",
                  textInputType: TextInputType.number,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  textEditingController: _ageController,
                  hintText: "Age (years)",
                  icon: "assets/icons/p_personal.png",
                  textInputType: TextInputType.number,
                ),

                SizedBox(height: media.width * 0.1),

                RoundGradientButton(
                  title: _isLoading ? "Updating..." : "Save Changes",
                  onPressed: _isLoading ? () {} : _updateProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}