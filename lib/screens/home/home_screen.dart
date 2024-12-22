// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenflow/main.dart';
import '../auth/login_screen.dart';
import '../tasks/task_detail_screen.dart';

// Navigation state management using enum for type safety
enum NavigationItem {
  home,
  calendar,
  analytics,
  profile,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '';
  NavigationItem _selectedItem = NavigationItem.home;
  
  // Sample task data structure with more detailed information
  final List<Map<String, dynamic>> _todaysTasks = [
    {
      'title': 'Project Planning',
      'deadline': '2:00 PM',
      'priority': 'High',
      'progress': 0.7,
      'description': 'Create project roadmap and milestone definitions',
      'notes': 'Include feedback from last week\'s team meeting',
    },
    {
      'title': 'Team Meeting',
      'deadline': '3:30 PM',
      'priority': 'Medium',
      'progress': 0.0,
      'description': 'Weekly sync with development team',
      'notes': 'Focus on sprint planning and blockers',
    },
    {
      'title': 'Document Review',
      'deadline': '5:00 PM',
      'priority': 'Low',
      'progress': 0.3,
      'description': 'Review and annotate technical specifications',
      'notes': 'Pay special attention to API documentation',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  // Helper method to format the greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(theme, textTheme),
                const SizedBox(height: 32),
                _buildProgressSection(theme, textTheme),
                const SizedBox(height: 32),
                _buildTasksSection(theme, textTheme),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Build the app bar with notification and settings buttons
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      title: const Text('ZenFlow'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implement notifications panel
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // TODO: Navigate to settings screen
          },
        ),
      ],
    );
  }

  // Build the welcome section with user greeting and avatar
  Widget _buildWelcomeSection(ThemeData theme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _username,
                  style: textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildUserAvatar(theme),
        ],
      ),
    );
  }

  // Build the user avatar with first letter of username
  Widget _buildUserAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.secondary,
      child: Text(
        _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build the progress overview section
  Widget _buildProgressSection(ThemeData theme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressCard(theme),
      ],
    );
  }

  // Build the progress metrics card
  Widget _buildProgressCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressMetric('Tasks\nCompleted', '12', theme),
                _buildVerticalDivider(theme),
                _buildProgressMetric('Focus\nTime', '2.5h', theme),
                _buildVerticalDivider(theme),
                _buildProgressMetric('Progress\nRate', '85%', theme),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: 0.85,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              color: theme.colorScheme.secondary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  // Build individual progress metric
  Widget _buildProgressMetric(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build the tasks section with header and list
  Widget _buildTasksSection(ThemeData theme, TextTheme textTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Tasks',
              style: textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all tasks screen
              },
              child: Text(
                'See All',
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _todaysTasks.length,
          itemBuilder: (context, index) => _buildTaskCard(_todaysTasks[index], theme),
        ),
      ],
    );
  }

  // Build individual task card with navigation to detail screen
  Widget _buildTaskCard(Map<String, dynamic> task, ThemeData theme) {
    final priorityColors = {
      'High': theme.colorScheme.error,
      'Medium': ZenFlowColors.accentCoral,
      'Low': theme.colorScheme.secondary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColors[task['priority']]?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task['priority'] as String,
                      style: TextStyle(
                        color: priorityColors[task['priority']],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if ((task['progress'] as double) > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: task['progress'] as double,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  color: theme.colorScheme.secondary,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Build bottom navigation bar
  Widget _buildBottomNavBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedItem.index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedItem = NavigationItem.values[index];
          });
        },
      ),
    );
  }

  // Build vertical divider for progress metrics
  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      height: 40,
      width: 1,
      color: theme.colorScheme.primary.withOpacity(0.1),
    );
  }

  // Show dialog for adding new task
  void _showAddTaskDialog(BuildContext context) {
    // TODO: Implement add task dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Task'),
        content: Text('Task creation dialog will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}