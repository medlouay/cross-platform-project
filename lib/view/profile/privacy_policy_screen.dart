import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          "Privacy Policy",
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Last Updated: February 16, 2026",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              _buildSection(
                context,
                "1. Information We Collect",
                "We collect information you provide directly to us, including:\n\n"
                    "• Personal information (name, email, phone number)\n"
                    "• Health data (height, weight, age, fitness goals)\n"
                    "• Profile pictures and photos you upload\n"
                    "• Workout history and activity data",
              ),

              _buildSection(
                context,
                "2. How We Use Your Information",
                "We use the information we collect to:\n\n"
                    "• Provide and improve our fitness services\n"
                    "• Personalize your workout experience\n"
                    "• Track your fitness progress\n"
                    "• Send you notifications about your goals\n"
                    "• Communicate with you about updates",
              ),

              _buildSection(
                context,
                "3. Data Security",
                "We implement appropriate security measures to protect your personal information. "
                    "Your data is encrypted during transmission and stored securely on our servers.",
              ),

              _buildSection(
                context,
                "4. Information Sharing",
                "We do not sell, trade, or rent your personal information to third parties. "
                    "We may share your information only:\n\n"
                    "• With your explicit consent\n"
                    "• To comply with legal obligations\n"
                    "• To protect our rights and safety",
              ),

              _buildSection(
                context,
                "5. Your Rights",
                "You have the right to:\n\n"
                    "• Access your personal data\n"
                    "• Update or correct your information\n"
                    "• Delete your account and data\n"
                    "• Opt-out of promotional communications",
              ),

              _buildSection(
                context,
                "6. Data Retention",
                "We retain your personal information for as long as your account is active "
                    "or as needed to provide you services. You can request deletion of your "
                    "data at any time through the app settings.",
              ),

              _buildSection(
                context,
                "7. Children's Privacy",
                "Our service is not intended for children under 13 years of age. "
                    "We do not knowingly collect personal information from children under 13.",
              ),

              _buildSection(
                context,
                "8. Changes to This Policy",
                "We may update this privacy policy from time to time. We will notify you "
                    "of any changes by posting the new policy on this page and updating "
                    "the 'Last Updated' date.",
              ),

              _buildSection(
                context,
                "9. Contact Us",
                "If you have any questions about this Privacy Policy, please contact us at:\n\n"
                    "Email: support@fitnessapp.com\n"
                    "Phone: +1 (555) 123-4567",
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primaryColor1.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryColor1,
                      size: 24,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "By using our app, you agree to this Privacy Policy.",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}