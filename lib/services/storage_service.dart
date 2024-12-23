// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// StorageService handles all local data persistence operations for the ZenFlow app.
/// It provides methods for storing and retrieving user data, tasks, settings,
/// and authentication information using SharedPreferences.
class StorageService {
  // Storage key constants
  static const String USER_PROFILE_KEY = 'user_profile';
  static const String TASKS_KEY = 'tasks';
  static const String SETTINGS_KEY = 'settings';
  static const String AUTH_TOKEN_KEY = 'auth_token';

  // User Profile Methods
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_PROFILE_KEY, jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(USER_PROFILE_KEY);
    if (profileString != null) {
      return jsonDecode(profileString) as Map<String, dynamic>;
    }
    return null;
  }

  // Task Management Methods
  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TASKS_KEY, jsonEncode(tasks));
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString(TASKS_KEY);
    if (tasksString != null) {
      final List<dynamic> decodedTasks = jsonDecode(tasksString);
      return decodedTasks.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    final tasks = await getTasks();
    // Ensure task has an ID if not provided
    if (!task.containsKey('id')) {
      task['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task['id'] == taskId);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task['id'] == taskId);
    await saveTasks(tasks);
  }

  Future<Map<String, dynamic>?> getTask(String taskId) async {
    final tasks = await getTasks();
    return tasks.firstWhere(
      (task) => task['id'] == taskId,
      orElse: () => {},
    );
  }

  // Settings Management Methods
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SETTINGS_KEY, jsonEncode(settings));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(SETTINGS_KEY);
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> updateSettings(String key, dynamic value) async {
    final settings = await getSettings();
    settings[key] = value;
    await saveSettings(settings);
  }

  // Authentication Methods
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AUTH_TOKEN_KEY, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AUTH_TOKEN_KEY);
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AUTH_TOKEN_KEY);
  }

  // User Authentication State
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // General Data Management
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> clearTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TASKS_KEY);
  }

  // Task Statistics Methods
  Future<Map<String, dynamic>> getTaskStatistics() async {
    final tasks = await getTasks();
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => 
      (task['progress'] as double?) == 1.0 || 
      task['isCompleted'] == true
    ).length;
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'completionRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
    };
  }
}