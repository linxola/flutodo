import 'package:flutodo/ui/theme.dart';
import 'package:flutodo/ui/update_task_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/tasks_controller.dart';
import '../models/task.dart';
import 'home_page.dart';

class TaskPage extends StatefulWidget {
  final String? taskId;
  const TaskPage({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _tasksController = Get.put(TasksController());
  bool _loading = true;
  var _data = <Task>[];

  void fetchData() async {
    _tasksController.getTask(int.parse(widget.taskId.toString()));
    _data = await _tasksController.currentTask;
    setState(() => _loading = false);
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? const CircularProgressIndicator() : Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.colorScheme.background,
        leading: IconButton(
          onPressed: ()=>Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Get.isDarkMode ? Colors.white : Colors.black
          )
        )
      ),
      body: Center(
        child: Obx(() {
          final Task task = _data.first;
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _task(task),
              _bottomButtons(task)
            ],
          );
        })
      )
    );
  }

  _task(task) {
    return Container(
        height: 530,
        width: 300,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _getBGClr(task.color)
        ),
        child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 40),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.text_format, size: 50, color: Colors.white,),
                      Text("Title", style: TextStyle(fontSize: 30, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(task.title, style: const TextStyle(fontSize: 20, color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.sticky_note_2_rounded, size: 50, color: Colors.white),
                      Text("Description", style: TextStyle(fontSize: 30, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(task.note, style: const TextStyle(fontSize: 20, color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.calendar_today_outlined, size: 40, color: Colors.white),
                      Text("Date", style: TextStyle(fontSize: 30, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(task.date.trim(), style: const TextStyle(fontSize: 20, color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.access_time_rounded, size: 30, color: Colors.white),
                          Text("Start Time", style: TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.access_time_rounded, size: 30, color: Colors.white),
                          Text("End Time", style: TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(task.startTime, style: const TextStyle(fontSize: 20, color: Colors.white)),
                      Text(task.endTime, style: const TextStyle(fontSize: 20, color: Colors.white))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.add_alert_rounded, size: 30, color: Colors.white),
                          Text("Remind", style: TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.repeat_rounded, size: 30, color: Colors.white),
                          Text("Repeat", style: TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                            task.remind>60 ? "${task.remind~/60} hours" : "${task.remind} minutes",
                            style: const TextStyle(fontSize: 20, color: Colors.white)
                        ),
                        Text(task.repeat, style: const TextStyle(fontSize: 20, color: Colors.white))
                      ]
                  )
                ]
            )
        )
    );
  }

  _bottomButtons(task) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _bottomSheetButton(
              label: "Edit Task",
              onTap: () {
                Get.to(()=>UpdateTaskPage(task: task));
              },
              clr: yellowClr,
              context: context
          ),
          _bottomSheetButton(
              label: "Delete Task",
              onTap: () {
                _tasksController.delete(task);
                Get.to(()=>const HomePage());
              },
              clr: Colors.red[400]!,
              context: context
          )
        ],
      ),
    );
  }

  _bottomSheetButton({
    required String label,
    required Function() onTap,
    required Color clr,
    required BuildContext context,
    bool isClose = false
  }) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: 55,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2,
                    color: isClose==true ? Get.isDarkMode ? Colors.grey[600]! : Colors.grey[300]! : clr
                ),
                borderRadius: BorderRadius.circular(20),
                color: isClose==true ? Colors.transparent : clr
            ),
            child: Center(
              child: Text(
                  label,
                  style: isClose ? titleStyle : titleStyle.copyWith(color: Colors.white)
              ),
            )
        )
    );
  }

  _getBGClr(int no) {
    switch (no) {
      case 0:
        return bluishClr;
      case 1:
        return pinkClr;
      case 2:
        return yellowClr;
      default:
        return bluishClr;
    }
  }
}
