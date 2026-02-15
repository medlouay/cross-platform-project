import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/profile_api.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class PersonalDataScreen extends StatefulWidget {
  final String? currentFirstName;
  final String? currentLastName;
  final String? currentEmail;
  final String? currentPhoneNumber;

  const PersonalDataScreen({
    Key? key,
    this.currentFirstName,
    this.currentLastName,
    this.currentEmail,
    this.currentPhoneNumber,
  }) : super(key: key);

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current values
    _firstNameController.text = widget.currentFirstName ?? '';
    _lastNameController.text = widget.currentLastName ?? '';
    _emailController.text = widget.currentEmail ?? '';
    _phoneController.text = widget.currentPhoneNumber ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updatePersonalData() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      _showMessage("First name, last name, and email are required");
      return;
    }

    // Email validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showMessage("Please enter a valid email address");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ProfileApi.updatePersonalData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phone.isNotEmpty ? phone : null,
      );

      if (!mounted) return;
      _showMessage("Personal data updated successfully");

      // Return the updated values to the previous screen
      Navigator.pop(context, {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phone,
      });
    } catch (e) {
      print('Error updating personal data: $e');
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
          "Personal Data",
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
                  "Update Your Personal Information",
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
                  textEditingController: _firstNameController,
                  hintText: "First Name",
                  icon: "assets/icons/p_personal.png",
                  textInputType: TextInputType.name,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  textEditingController: _lastNameController,
                  hintText: "Last Name",
                  icon: "assets/icons/p_personal.png",
                  textInputType: TextInputType.name,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  textEditingController: _emailController,
                  hintText: "Email",
                  icon: "assets/icons/message_icon.png",
                  textInputType: TextInputType.emailAddress,
                ),

                SizedBox(height: media.width * 0.04),

                RoundTextField(
                  textEditingController: _phoneController,
                  hintText: "Phone Number (Optional)",
                  icon: "assets/icons/p_contact.png",
                  textInputType: TextInputType.phone,
                ),

                SizedBox(height: media.width * 0.1),

                RoundGradientButton(
                  title: _isLoading ? "Updating..." : "Save Changes",
                  onPressed: _isLoading ? () {} : _updatePersonalData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}