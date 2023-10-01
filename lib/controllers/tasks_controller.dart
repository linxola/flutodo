import 'package:flutodo/db/db_helper.dart';
import 'package:flutodo/services/notification_service.dart';
import 'package:get/get.dart';

import '../models/task.dart';

class TasksController extends GetxController {

  var tasksList = <Task>[].obs;
  var currentTask = <Task>[].obs;

  // get all the data from table
  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.queryAll();
    tasksList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  void getTask(int? id) async {
    List<Map<String, dynamic>> query = await DBHelper.queryTask(id!);
    currentTask.assignAll(query.map((data) => Task.fromJson(data)).toList());
  }

  // create new task
  Future<int> addTask({required Task task}) async {
    int taskId =  await DBHelper.insert(task);
    NotificationService().scheduledNotification(
        taskId,
        task
    );
    return taskId;
  }

  Future<int> updateTask({required Task task}) async {
    print(task.id);
    await NotificationService().cancel(task.id);
    int taskId =  await DBHelper.update(task);
    NotificationService().scheduledNotification(
        taskId,
        task
    );
    getTask(task.id);
    getTasks();
    return taskId;
  }

  void markTaskCompleted(int id) async {
    await NotificationService().cancel(id);
    await DBHelper.updateComplete(id);
    getTasks();
  }

  // delete a task
  void delete(Task task) {
    DBHelper.delete(task);
    getTasks();
  }
}