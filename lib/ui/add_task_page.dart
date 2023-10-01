import 'package:flutodo/controllers/tasks_controller.dart';
import 'package:flutodo/ui/theme.dart';
import 'package:flutodo/ui/widgets/button.dart';
import 'package:flutodo/ui/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TasksController _tasksController = Get.put(TasksController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _endTime = "23:59";
  String _startTime = DateFormat("HH:mm").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 15, 30, 45, 60, 120, 180, 240, 300, 360];
  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];
  int _selectedColor = 0;
  @override
  Widget build(BuildContext context) {
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
                "Add Task",
                style: headingStyle,
              ),
              MyInputField(
                title: "Title",
                hint: "Enter your title",
                controller: _titleController
              ),
              MyInputField(
                title: "Note",
                hint: "Enter your note",
                controller: _noteController
              ),
              MyInputField(
                title: "Date",
                hint: DateFormat("dd.MM.yyyy").format(_selectedDate),
                widget: IconButton(
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey
                    ),
                    onPressed: () {
                      _getDateFromUser();
                    }
                  )
              ),
              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: "Start Time",
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFormUser(isStartTime: true);
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
                        hint: _endTime,
                        widget: IconButton(
                          onPressed: () {
                            _getTimeFormUser(isStartTime: false);
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
                hint: _selectedRemind>60 ? "${_selectedRemind~/60} hours early" : "$_selectedRemind minutes early",
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
                      _selectedRemind = int.parse(newValue!);
                    });
                  },
                  items: remindList.map<DropdownMenuItem<String>>((int value){
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: value>60 ? Text("${value~/60} hours") : Text("$value minutes")
                    );
                  }).toList()
                ),
              ),
              MyInputField(
                title: "Repeat",
                hint: _selectedRepeat,
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
                        _selectedRepeat = newValue!;
                      });
                    },
                    items: repeatList.map<DropdownMenuItem<String>>((String? value){
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
                  MyButton(label: "Create Task", onTap: ()=>_validateDate())
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar("Required", "All fields are required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(Icons.warning_amber_rounded, color: pinkClr)
      );
    }
  }

  _addTaskToDb() async {
    await _tasksController.addTask(
      task: Task(
        note: _noteController.text,
        title: _titleController.text,
        date: DateFormat("dd.MM.yyyy").format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        isCompleted: 0
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
  
  _getDateFromUser() async {
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
     setState(() {
       _selectedDate = pickerDate;
     });
    } else {
      print("It's null or something is wrong");
    }
  }

  _getTimeFormUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String formattedTime = pickedTime.format(context);
    if (isStartTime==true) {
      setState(() {
        _startTime = formattedTime;
      });
    } else if (isStartTime==false) {
      setState(() {
        _endTime = formattedTime;
      });
    }
  }

  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(":").first),
        minute: int.parse(_startTime.split(":")[1])
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
