// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  
  const SettingsScreen({
    Key? key,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // User preferences
  bool _isDarkMode = false;
  bool _enableNotifications = true;
  String _selectedLanguage = 'English';
  double _reminderTime = 9.0; // Default to 9 AM
  String _taskSortPreference = 'Priority';

  // Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _enableNotifications = prefs.getBool('notifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _reminderTime = prefs.getDouble('reminderTime') ?? 9.0;
      _taskSortPreference = prefs.getString('taskSort') ?? 'Priority';
      _nameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _enableNotifications);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setDouble('reminderTime', _reminderTime);
    await prefs.setString('taskSort', _taskSortPreference);
    
    // Only update these if they've changed
    if (_nameController.text.isNotEmpty) {
      await prefs.setString('username', _nameController.text);
    }
    if (_emailController.text.isNotEmpty) {
      await prefs.setString('user_email', _emailController.text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        backgroundColor: ZenFlowColors.secondarySeaBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Call the callback to refresh the app
    widget.onSettingsChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileSection(theme),
          const SizedBox(height: 24),
          _buildPreferencesSection(theme),
          const SizedBox(height: 24),
          _buildNotificationSection(theme),
          const SizedBox(height: 24),
          _buildTaskPreferencesSection(theme),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ZenFlowColors.primaryDarkTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ZenFlowColors.primaryDarkTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
              activeColor: ZenFlowColors.secondarySeaBlue,
            ),
            const Divider(),
            ListTile(
              title: const Text('Language'),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showLanguageDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ZenFlowColors.primaryDarkTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive task reminders and updates'),
              value: _enableNotifications,
              onChanged: (value) => setState(() => _enableNotifications = value),
              activeColor: ZenFlowColors.secondarySeaBlue,
            ),
            const Divider(),
            ListTile(
              title: const Text('Daily Reminder Time'),
              subtitle: Text('${_reminderTime.toInt()}:00'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: _reminderTime,
                  min: 0,
                  max: 23,
                  divisions: 23,
                  label: '${_reminderTime.toInt()}:00',
                  onChanged: _enableNotifications
                      ? (value) => setState(() => _reminderTime = value)
                      : null,
                  activeColor: ZenFlowColors.secondarySeaBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPreferencesSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Preferences',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ZenFlowColors.primaryDarkTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Sort Tasks By'),
              subtitle: Text(_taskSortPreference),
              trailing: DropdownButton<String>(
                value: _taskSortPreference,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _taskSortPreference = newValue);
                  }
                },
                items: ['Priority', 'Due Date', 'Created Date']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'English',
              'Spanish',
              'French',
              'German',
              'Chinese',
            ].map((String language) {
              return ListTile(
                title: Text(language),
                trailing: _selectedLanguage == language
                    ? Icon(Icons.check, color: ZenFlowColors.secondarySeaBlue)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = language);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}