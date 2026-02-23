import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/theme_provider.dart';
import 'package:fitnessapp/utils/profile_api.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  String _language = 'English';
  String _measurementUnit = 'Metric';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _smsNotifications = prefs.getBool('sms_notifications') ?? false;
      _language = prefs.getString('language') ?? 'English';
      _measurementUnit = prefs.getString('measurement_unit') ?? 'Metric';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('sms_notifications', _smsNotifications);
    await prefs.setString('language', _language);
    await prefs.setString('measurement_unit', _measurementUnit);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate clearing cache
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context); // Close loading dialog

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _resetSettings() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.grayColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      setState(() {
        _notificationsEnabled = true;
        _emailNotifications = true;
        _pushNotifications = true;
        _smsNotifications = false;
        _language = 'English';
        _measurementUnit = 'Metric';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to default'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              const Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you absolutely sure?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This action cannot be undone. This will permanently delete your account and remove all your data from our servers.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All your data will be lost forever',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.grayColor),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete Forever',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 15),
                Text('Deleting your account...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await ProfileApi.deleteAccount();

      // Clear all local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login and clear all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          "Settings",
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
              // Appearance Section
              _buildSectionTitle("Appearance"),
              const SizedBox(height: 10),
              Container(
                decoration: _buildCardDecoration(),
                child: Column(
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _buildSwitchTile(
                          title: "Dark Mode",
                          subtitle: "Enable dark theme",
                          icon: Icons.dark_mode,
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Notifications Section
              _buildSectionTitle("Notifications"),
              const SizedBox(height: 10),
              Container(
                decoration: _buildCardDecoration(),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: "Enable Notifications",
                      subtitle: "Receive all notifications",
                      icon: Icons.notifications,
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                          if (!value) {
                            _emailNotifications = false;
                            _pushNotifications = false;
                            _smsNotifications = false;
                          }
                        });
                        _saveSettings();
                      },
                    ),
                    if (_notificationsEnabled) ...[
                      Divider(height: 1),
                      _buildSwitchTile(
                        title: "Email Notifications",
                        subtitle: "Receive updates via email",
                        icon: Icons.email,
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() => _emailNotifications = value);
                          _saveSettings();
                        },
                      ),
                      Divider(height: 1),
                      _buildSwitchTile(
                        title: "Push Notifications",
                        subtitle: "Receive push notifications",
                        icon: Icons.notifications_active,
                        value: _pushNotifications,
                        onChanged: (value) {
                          setState(() => _pushNotifications = value);
                          _saveSettings();
                        },
                      ),
                      Divider(height: 1),
                      _buildSwitchTile(
                        title: "SMS Notifications",
                        subtitle: "Receive updates via SMS",
                        icon: Icons.sms,
                        value: _smsNotifications,
                        onChanged: (value) {
                          setState(() => _smsNotifications = value);
                          _saveSettings();
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Preferences Section
              _buildSectionTitle("Preferences"),
              const SizedBox(height: 10),
              Container(
                decoration: _buildCardDecoration(),
                child: Column(
                  children: [
                    _buildSelectTile(
                      title: "Language",
                      subtitle: _language,
                      icon: Icons.language,
                      onTap: () => _showLanguageDialog(),
                    ),
                    Divider(height: 1),
                    _buildSelectTile(
                      title: "Measurement Units",
                      subtitle: _measurementUnit,
                      icon: Icons.straighten,
                      onTap: () => _showMeasurementDialog(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Data & Storage Section
              _buildSectionTitle("Data & Storage"),
              const SizedBox(height: 10),
              Container(
                decoration: _buildCardDecoration(),
                child: Column(
                  children: [
                    _buildActionTile(
                      title: "Clear Cache",
                      subtitle: "Free up storage space",
                      icon: Icons.delete_outline,
                      onTap: _clearCache,
                    ),
                    Divider(height: 1),
                    _buildActionTile(
                      title: "Download Data",
                      subtitle: "Export your fitness data",
                      icon: Icons.download,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download feature coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Account Section
              _buildSectionTitle("Account"),
              const SizedBox(height: 10),
              Container(
                decoration: _buildCardDecoration(),
                child: Column(
                  children: [
                    _buildActionTile(
                      title: "Reset Settings",
                      subtitle: "Restore default settings",
                      icon: Icons.restore,
                      onTap: _resetSettings,
                      iconColor: Colors.orange,
                    ),
                    Divider(height: 1),
                    _buildActionTile(
                      title: "Delete Account",
                      subtitle: "Permanently delete your account",
                      icon: Icons.delete_forever,
                      onTap: _showDeleteAccountDialog,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      "Fitness App",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        fontSize: 11,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        )
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryColor1, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor1,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryColor1, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryColor1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryColor1,
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: iconColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
            _buildLanguageOption('Arabic'),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _language = result);
      _saveSettings();
    }
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _language,
      activeColor: AppColors.primaryColor1,
      onChanged: (value) => Navigator.pop(context, value),
    );
  }

  Future<void> _showMeasurementDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Measurement Unit'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Metric (kg, cm)'),
              value: 'Metric',
              groupValue: _measurementUnit,
              activeColor: AppColors.primaryColor1,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('Imperial (lb, ft)'),
              value: 'Imperial',
              groupValue: _measurementUnit,
              activeColor: AppColors.primaryColor1,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _measurementUnit = result);
      _saveSettings();
    }
  }
}