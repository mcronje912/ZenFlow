// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenflow/main.dart';
import '../auth/login_screen.dart';
import '../tasks/task_detail_screen.dart';
import '../../services/storage_service.dart';
import '../../services/quote_service.dart';
import '../../widgets/custom_drawer.dart';  // Import the custom drawer

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
  final StorageService _storageService = StorageService();
  String _username = 'User'; // Default username
  NavigationItem _selectedItem = NavigationItem.home;
  List<Map<String, dynamic>> _todaysTasks = [];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _username = prefs.getString('username') ?? 'User';
      });
    } catch (e) {
      print('Error loading username: $e');
      // Keep default username if there's an error
    }
  }

  Future<void> _loadTasks() async {
    final tasks = await _storageService.getTasks();
    setState(() {
      _todaysTasks = tasks;
    });
  }

  Future<void> _addTask(Map<String, dynamic> newTask) async {
    await _storageService.addTask(newTask);
    await _loadTasks(); // Reload tasks to update UI
  }

  Future<void> _updateTaskProgress(String taskId, double progress) async {
    final taskIndex = _todaysTasks.indexWhere((task) => task['id'] == taskId);
    if (taskIndex != -1) {
      final updatedTask = Map<String, dynamic>.from(_todaysTasks[taskIndex]);
      updatedTask['progress'] = progress;
      await _storageService.updateTask(taskId, updatedTask);
      await _loadTasks();
    }
  }

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
      drawer: const CustomDrawer(), // Add the custom drawer here
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(theme, textTheme),
                const SizedBox(height: 24),
                const _QuoteCard(),
                const SizedBox(height: 24),
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

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.white,
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text('ZenFlow'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
          color: Colors.white,
          ),
          onPressed: () {
            // TODO: Implement notifications panel
          },
        ),
      ],
    );
  }

  // Rest of your existing HomeScreen code remains the same...
  // Include all other methods exactly as they are in your current home_screen.dart
  
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

  Widget _buildProgressSection(ThemeData theme, TextTheme textTheme) {
    // Calculate completion metrics
    final completedTasks = _todaysTasks.where((task) => task['progress'] == 1.0).length;
    final completionRate = _todaysTasks.isEmpty ? 0.0 : 
        (completedTasks / _todaysTasks.length * 100).toStringAsFixed(0);

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
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProgressMetric('Tasks\nCompleted', '$completedTasks', theme),
                    _buildVerticalDivider(theme),
                    _buildProgressMetric('Total\nTasks', '${_todaysTasks.length}', theme),
                    _buildVerticalDivider(theme),
                    _buildProgressMetric('Completion\nRate', '$completionRate%', theme),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: _todaysTasks.isEmpty ? 0.0 : completedTasks / _todaysTasks.length,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  color: theme.colorScheme.secondary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
        _todaysTasks.isEmpty
            ? Center(
                child: Text(
                  'No tasks yet. Add some using the + button!',
                  style: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary.withOpacity(0.6),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _todaysTasks.length,
                itemBuilder: (context, index) =>
                    _buildTaskCard(_todaysTasks[index], theme),
              ),
      ],
    );
  }

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
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
          // Reload tasks after returning from detail screen
          _loadTasks();
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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

  Widget _buildVerticalDivider(ThemeData theme) {
    return Container(
      height: 40,
      width: 1,
      color: theme.colorScheme.primary.withOpacity(0.1),
    );
  }

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

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'Medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedPriority,
              isExpanded: true,
              items: ['Low', 'Medium', 'High'].map((String priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedPriority = newValue;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final newTask = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'priority': selectedPriority,
                  'progress': 0.0,
                  'deadline': '2:00 PM', // You might want to add a time picker
                  'subtasks': [], // Initialize empty subtasks list
                  'notes': '', // Initialize empty notes
                };
                await _addTask(newTask);
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Add this widget inside your HomeScreen class

class _QuoteCard extends StatefulWidget {
  const _QuoteCard({Key? key}) : super(key: key);

  @override
  _QuoteCardState createState() => _QuoteCardState();
}
class _QuoteCardState extends State<_QuoteCard> {
  Quote? _quote;
  bool _isLoading = true;
  String? _error;
  final double cardHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    print('QuoteCard: Starting new quote load');
    
    if (_quote == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final quote = await QuoteService.getQuoteByTags(['inspirational', 'wisdom']);
      print('QuoteCard: New quote received: ${quote.content}');
      
      if (mounted) {
        setState(() {
          _quote = quote;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      print('QuoteCard: Error loading quote: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load quote. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: cardHeight,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCardContent(theme),
        ),
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ZenFlowColors.errorBrickRed,
              ),
            ),
            TextButton(
              onPressed: _loadQuote,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: ZenFlowColors.secondarySeaBlue,
                    size: 32,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _loadQuote,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.refresh,
                          color: ZenFlowColors.secondarySeaBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _quote?.content ?? '',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: ZenFlowColors.primaryDarkTeal,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              Text(
                _quote?.author != null ? '- ${_quote!.author}' : '',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ZenFlowColors.primaryDarkTeal.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}