// lib/screens/tasks/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:zenflow/main.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late double _progress;
  late List<Map<String, dynamic>> _subtasks;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _progress = widget.task['progress'] ?? 0.0;
    // Initialize with sample subtasks - in a real app, this would come from a database
    _subtasks = [
      {'title': 'Research phase', 'isCompleted': true},
      {'title': 'Initial draft', 'isCompleted': false},
      {'title': 'Review with team', 'isCompleted': false},
    ];
    _noteController = TextEditingController(text: widget.task['notes'] ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return '#D84727'; // ZenFlow error red
      case 'medium':
        return '#EF7B45'; // ZenFlow accent coral
      case 'low':
        return '#5EB1BF'; // ZenFlow secondary sea blue
      default:
        return '#5EB1BF';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // This ensures the back button appears
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Using iOS-style back arrow for cleaner look
          color: Colors.white, // Ensuring the back button is visible
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: ZenFlowColors.primaryDarkTeal, // Using our app's primary color
        elevation: 0, // Removing shadow for a cleaner look
        title: const Text(
          'Task Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'AdventPro',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Implement delete functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.task['title'],
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(_getPriorityColor(widget.task['priority']).substring(1, 7), radix: 16) + 0xFF000000).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.task['priority'],
                          style: TextStyle(
                            color: Color(int.parse(_getPriorityColor(widget.task['priority']).substring(1, 7), radix: 16) + 0xFF000000),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Due ${widget.task['deadline']}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              color: theme.colorScheme.secondary,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subtasks Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subtasks',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subtasks.length,
                    itemBuilder: (context, index) {
                      final subtask = _subtasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          value: subtask['isCompleted'],
                          onChanged: (bool? value) {
                            setState(() {
                              _subtasks[index]['isCompleted'] = value;
                              // Update progress based on completed subtasks
                              _progress = _subtasks.where((task) => task['isCompleted']).length / _subtasks.length;
                            });
                          },
                          title: Text(
                            subtask['title'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: subtask['isCompleted'] ? TextDecoration.lineThrough : null,
                              color: subtask['isCompleted']
                                  ? theme.colorScheme.primary.withOpacity(0.5)
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  ),
                  
                  // Notes Section
                  const SizedBox(height: 24),
                  Text(
                    'Notes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add your notes here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _progress = 1.0;
                    for (var subtask in _subtasks) {
                      subtask['isCompleted'] = true;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                ),
                child: const Text('Mark as Complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}