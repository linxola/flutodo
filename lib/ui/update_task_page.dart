import 'package:flutodo/controllers/tasks_controller.dart';
import 'package:flutodo/ui/theme.dart';
import 'package:flutodo/ui/widgets/button.dart';
import 'package:flutodo/ui/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

class UpdateTaskPage extends StatefulWidget {
  final Task task;
  const UpdateTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  State<UpdateTaskPage> createState() => _UpdateTaskPageState();
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  final TasksController _tasksController = Get.put(TasksController());
  final List<int> _remindList = [5, 15, 30, 45, 60, 120, 180, 240, 300, 360];
  final List<String> _repeatList = ["None", "Daily", "Weekly", "Monthly"];
  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    Task task = widget.task;
    int taskId = task.id!.toInt();
    String title = task.title.toString();
    String note = task.note.toString();
    DateTime selectedDate = DateTime.parse(DateFormat("dd.MM.yyyy").parse(task.date!).toString());
    String startTime = task.startTime.toString();
    String endTime = task.endTime.toString();
    int selectedRemind = task.remind!.toInt();
    String selectedRepeat = task.repeat.toString();
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController noteController = TextEditingController(text: note);

    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Task",
                style: headingStyle,
              ),
              MyInputField(
                  title: "Title",
                  hint: title,
                  controller: titleController
              ),
              MyInputField(
                  title: "Note",
                  hint: note,
                  controller: noteController
              ),
              MyInputField(
                  title: "Date",
                  hint: DateFormat("dd.MM.yyyy").format(selectedDate),
                  widget: IconButton(
                      icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey
                      ),
                      onPressed: () {
                        selectedDate = _getDateFromUser(selectedDate);
                      }
                  )
              ),
              Row(
                children: [
                  Expanded(
                      child: MyInputField(
                        title: "Start Time",
                        hint: startTime,
                        widget: IconButton(
                          onPressed: () {
                            startTime = _getTimeFormUser(isStartTime: true, startTime: startTime, endTime: endTime);
                          },
                          icon: const Icon(
                              Icons.access_time_rounded,
                              color: Colors.grey
                          ),
                        ),
                      )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: MyInputField(
                        title: "End Time",
                        hint: endTime,
                        widget: IconButton(
                          onPressed: () {
                            endTime = _getTimeFormUser(isStartTime: false, startTime: startTime, endTime: endTime);
                          },
                          icon: const Icon(
                              Icons.access_time_rounded,
                              color: Colors.grey
                          ),
                        ),
                      )
                  )
                ],
              ),
              MyInputField(
                title: "Remind",
                hint: selectedRemind>60 ? "${selectedRemind~/60} hours early" : "$selectedRemind minutes early",
                widget: DropdownButton(
                    icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey
                    ),
                    iconSize: 32,
                    elevation: 4,
                    style: subTitleStyle,
                    underline: Container(height: 0),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRemind = int.parse(newValue!);
                      });
                    },
                    items: _remindList.map<DropdownMenuItem<String>>((int value){
                      return DropdownMenuItem<String>(
                          value: value.toString(),
                          child: value>60 ? Text("${value~/60} hours") : Text("$value minutes")
                      );
                    }).toList()
                ),
              ),
              MyInputField(
                title: "Repeat",
                hint: selectedRepeat,
                widget: DropdownButton(
                    icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey
                    ),
                    iconSize: 32,
                    elevation: 4,
                    style: subTitleStyle,
                    underline: Container(height: 0),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRepeat = newValue!;
                      });
                    },
                    items: _repeatList.map<DropdownMenuItem<String>>((String? value){
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value!, style: const TextStyle(color: Colors.grey))
                      );
                    }).toList()
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  MyButton(label: "Update Task", onTap: ()=>_validateDate(
                    titleController,
                    noteController,
                    taskId,
                    selectedDate,
                    startTime,
                    endTime,
                    selectedRemind,
                    selectedRepeat
                  ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _validateDate(TextEditingController titleController, TextEditingController noteController, int taskId, DateTime selectedDate, String startTime, String endTime, int selectedRemind, String selectedRepeat) {
    if (titleController.text.isNotEmpty && noteController.text.isNotEmpty) {
      _addTaskToDb(titleController, noteController, taskId, selectedDate, startTime, endTime, selectedRemind, selectedRepeat);
      Get.back();
    } else if (titleController.text.isEmpty || noteController.text.isEmpty) {
      Get.snackbar("Required", "All fields are required",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: const Icon(Icons.warning_amber_rounded, color: pinkClr)
      );
    }
  }

  _addTaskToDb(TextEditingController titleController, TextEditingController noteController, int taskId, DateTime selectedDate, String startTime, String endTime, int selectedRemind, String selectedRepeat) async {
    await _tasksController.updateTask(
        task: Task(
            id: taskId,
            note: noteController.text,
            title: titleController.text,
            date: DateFormat("dd.MM.yyyy").format(selectedDate),
            startTime: startTime,
            endTime: endTime,
            remind: selectedRemind,
            repeat: selectedRepeat,
            color: _selectedColor
        )
    );
  }

  _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Color",
            style: titleStyle
        ),
        const SizedBox(height: 8),
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            return GestureDetector(
              onTap: (){
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                    radius: 14,
                    backgroundColor: index==0 ? primaryClr : index==1 ? pinkClr : yellowClr,
                    child: _selectedColor==index ? const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 16,
                    ) : Container()
                ),
              ),
            );
          }
          ),
        )
      ],
    );
  }

  _appBar(BuildContext context){
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.colorScheme.background,
      leading: GestureDetector(
          onTap: (){
            Get.back();
          },
          child: Icon(Icons.arrow_back_ios,
            size: 20,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          )
      ),
      actions: const [
        CircleAvatar(
          backgroundImage: AssetImage(
              "images/user_icon.png"
          ),
        ),
        SizedBox(width: 20,)
      ],
    );
  }

  _getDateFromUser(DateTime selectedDate) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1991),
        lastDate: DateTime(2112),
        builder: (context, child) {
          return Get.isDarkMode ? Theme(
            data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                    primary: primaryClr
                )
            ), child: child!,
          ) : Theme(data: Theme.of(context), child: child!);
        }
    );

    if (pickerDate!=null) {
      return selectedDate = pickerDate;
    } else {
      print("It's null or something is wrong");
    }
  }

  _getTimeFormUser({required bool isStartTime, required String startTime, required String endTime}) async {
    var pickedTime = await _showTimePicker(startTime);
    String formattedTime = pickedTime.format(context);
    if (pickedTime==null) {
      print("Time canceled");
    } else if (isStartTime==true) {
      return startTime = formattedTime;
    } else if (isStartTime==false) {
      return endTime = formattedTime;
    }
  }

  _showTimePicker(String startTime) {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(startTime.split(":").first),
            minute: int.parse(startTime.split(":")[1])
        ),
        builder: (context, child) {
          return Get.isDarkMode ? Theme(
            data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                    primary: primaryClr
                )
            ), child: child!,
          ) : Theme(data: Theme.of(context), child: child!);
        }
    );
  }
}
