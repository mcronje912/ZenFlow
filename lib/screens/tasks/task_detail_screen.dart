// lib/screens/tasks/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:zenflow/main.dart';
import '../../services/storage_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final StorageService _storageService = StorageService();
  late double _progress;
  late List<Map<String, dynamic>> _subtasks;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _progress = widget.task['progress'] ?? 0.0;
    _subtasks = List<Map<String, dynamic>>.from(widget.task['subtasks'] ?? []);
    _noteController = TextEditingController(text: widget.task['notes'] ?? '');
  }

  @override
  void dispose() {
    _saveTask();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: ZenFlowColors.backgroundLightBlue,
      appBar: AppBar(
        backgroundColor: ZenFlowColors.primaryDarkTeal,
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            _saveTask();
            Navigator.pop(context);
          },
        ),
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await _storageService.deleteTask(widget.task['id']);
              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Task Header
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task['title'] ?? 'New Task',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ZenFlowColors.primaryDarkTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.task['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.task['description'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: ZenFlowColors.primaryDarkTeal.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(widget.task['priority'])
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.task['priority'] ?? 'Medium',
                      style: TextStyle(
                        color: _getPriorityColor(widget.task['priority']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress Section
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ZenFlowColors.primaryDarkTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: ZenFlowColors.primaryDarkTeal.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ZenFlowColors.secondarySeaBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      color: ZenFlowColors.secondarySeaBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subtasks Section
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtasks',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: ZenFlowColors.primaryDarkTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: ZenFlowColors.secondarySeaBlue,
                        ),
                        onPressed: _showAddSubtaskDialog,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                if (_subtasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      'No subtasks yet. Add some using the + button!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ZenFlowColors.primaryDarkTeal.withOpacity(0.6),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subtasks.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: ZenFlowColors.primaryDarkTeal.withOpacity(0.1),
                    ),
                    itemBuilder: (context, index) {
                      final subtask = _subtasks[index];
                      return CheckboxListTile(
                        value: subtask['isCompleted'] ?? false,
                        onChanged: (value) => _toggleSubtask(index, value),
                        title: Text(
                          subtask['title'],
                          style: TextStyle(
                            decoration: subtask['isCompleted'] == true
                                ? TextDecoration.lineThrough
                                : null,
                            color: subtask['isCompleted'] == true
                                ? ZenFlowColors.primaryDarkTeal.withOpacity(0.5)
                                : ZenFlowColors.primaryDarkTeal,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: ZenFlowColors.secondarySeaBlue,
                        checkColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notes Section
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ZenFlowColors.primaryDarkTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Add notes here...',
                      hintStyle: TextStyle(
                        color: ZenFlowColors.primaryDarkTeal.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ZenFlowColors.secondarySeaBlue.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ZenFlowColors.secondarySeaBlue,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ZenFlowColors.primaryDarkTeal.withOpacity(0.2),
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    style: TextStyle(
                      color: ZenFlowColors.primaryDarkTeal,
                    ),
                    onChanged: (_) => _saveTask(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveTask();
          Navigator.pop(context);
        },
        backgroundColor: ZenFlowColors.secondarySeaBlue,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _toggleSubtask(int index, bool? value) {
    setState(() {
      _subtasks[index]['isCompleted'] = value;
      _updateProgress();
    });
    _saveTask();
  }

  void _showAddSubtaskDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Subtask',
          style: TextStyle(
            color: ZenFlowColors.primaryDarkTeal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: 'Subtask Title',
            hintText: 'Enter subtask description',
            labelStyle: TextStyle(
              color: ZenFlowColors.primaryDarkTeal.withOpacity(0.7),
            ),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addSubtask(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ZenFlowColors.primaryDarkTeal),
            ),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _addSubtask(textController.text);
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: ZenFlowColors.secondarySeaBlue,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addSubtask(String title) {
    setState(() {
      _subtasks.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'isCompleted': false,
      });
      _updateProgress();
    });
    _saveTask();
  }

  void _updateProgress() {
    if (_subtasks.isEmpty) {
      setState(() => _progress = 0.0);
      return;
    }
    
    final completedTasks = _subtasks.where((task) => task['isCompleted'] == true).length;
    setState(() => _progress = completedTasks / _subtasks.length);
  }

  Future<void> _saveTask() async {
    final updatedTask = Map<String, dynamic>.from(widget.task);
    updatedTask['progress'] = _progress;
    updatedTask['notes'] = _noteController.text;
    updatedTask['subtasks'] = _subtasks;
    
    await _storageService.updateTask(widget.task['id'], updatedTask);
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase() ?? 'medium') {
      case 'high':
        return ZenFlowColors.errorBrickRed;
      case 'medium':
        return ZenFlowColors.accentCoral;
      case 'low':
        return ZenFlowColors.secondarySeaBlue;
      default:
        return ZenFlowColors.secondarySeaBlue;
    }
  }
}