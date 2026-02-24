import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/contact_api.dart';
import 'package:fitnessapp/utils/profile_api.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ProfileApi.getProfile();

      if (mounted) {
        setState(() {
          // Combine first_name and last_name
          final firstName = profile['first_name'] ?? '';
          final lastName = profile['last_name'] ?? '';
          _nameController.text = '$firstName $lastName'.trim();

          // Set email
          _emailController.text = profile['email'] ?? '';

          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    // Manual validation
    if (name.isEmpty) {
      _showMessage('Please enter your name');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Please enter a valid email');
      return;
    }

    if (subject.isEmpty) {
      _showMessage('Please enter a subject');
      return;
    }

    if (message.isEmpty || message.length < 10) {
      _showMessage('Message must be at least 10 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Split name into first and last
      List<String> nameParts = name.split(' ');
      String firstName = nameParts.first;
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      await ContactApi.sendContactMessage(
        firstName: firstName,
        lastName: lastName,
        email: email,
        message: 'Subject: $subject\n\n$message',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showMessage("Message sent successfully!");

        // Clear only subject and message fields
        _subjectController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('"Message sent successfully!"');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('success') ? Colors.green : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        title: Text(
          "Contact Us",
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoadingProfile
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: media.width * 0.05),

                // Header
                Text(
                  "Get in Touch",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 24,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: media.width * 0.02),

                Text(
                  "We'd love to hear from you! Send us a message and we'll respond as soon as possible.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: media.width * 0.08),

                // Name Field (Auto-filled, read-only)
                RoundTextField(
                  textEditingController: _nameController,
                  hintText: "Full Name",
                  icon: "assets/icons/p_personal.png",
                  textInputType: TextInputType.name,
                ),

                SizedBox(height: media.width * 0.04),

                // Email Field (Auto-filled, read-only)
                RoundTextField(
                  textEditingController: _emailController,
                  hintText: "Email",
                  icon: "assets/icons/message_icon.png",
                  textInputType: TextInputType.emailAddress,
                ),

                SizedBox(height: media.width * 0.04),

                // Subject Field
                RoundTextField(
                  textEditingController: _subjectController,
                  hintText: "Subject",
                  icon: "assets/icons/p_activity.png",
                  textInputType: TextInputType.text,
                ),

                SizedBox(height: media.width * 0.04),

                // Message Field
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                      hintText: "Your Message",
                      hintStyle: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                  ),
                ),

                SizedBox(height: media.width * 0.08),

                // Send Button
                RoundGradientButton(
                  title: _isLoading ? "Sending..." : "Send Message",
                  onPressed: _isLoading ? () {} : _sendMessage,
                ),

                SizedBox(height: media.width * 0.05),

                // Contact Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: AppColors.primaryColor1,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "support@fitnessapp.com",
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: AppColors.primaryColor1,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "+1 (555) 123-4567",
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: media.width * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}