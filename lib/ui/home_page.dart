import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutodo/controllers/tasks_controller.dart';
import 'package:flutodo/services/theme_service.dart';
import 'package:flutodo/ui/add_task_page.dart';
import 'package:flutodo/ui/task_page.dart';
import 'package:flutodo/ui/theme.dart';
import 'package:flutodo/ui/widgets/button.dart';
import 'package:flutodo/ui/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tasksController = Get.put(TasksController());
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    _tasksController.getTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.colorScheme.background,
      body: Column(
        children: [
          _taskBar(),
          _dateBar(),
          const SizedBox(height: 10),
          _tasks()
        ]
      )
    );
  }

  _tasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _tasksController.tasksList.length,
          itemBuilder: (_, index) {
            Task task = _tasksController.tasksList[index];
            if ((task.repeat=='Daily') ||
              (task.repeat=='Weekly' && _selectedDate.weekday==DateTime.parse(DateFormat("dd.MM.yyyy").parse(task.date!).toString()).weekday) ||
              (task.repeat=='Monthly' && _selectedDate.month==int.parse(task.date!.split(".")[1])) ||
              (task.date==DateFormat("dd.MM.yyyy").format(_selectedDate))) {
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                              children: [
                                GestureDetector(
                                    onTap: () async {
                                      await Get.to(()=>TaskPage(taskId: "${task.id}"));
                                      _tasksController.getTask(task.id);
                                    },
                                    onLongPress: () {
                                      _showBottomSheet(context, task);
                                    },
                                    child: TaskTile(task)
                                )
                              ]
                          )
                      )
                  )
              );
            } else {
              return Container();
            }
          }
        );
      })
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted==1
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
        color: Get.isDarkMode ? darkGreyClr : Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]
              ),
            ),
            const Spacer(),
            task.isCompleted==1
              ? Container()
              : _bottomSheetButton(
                label: "Task Completed",
                onTap: () {
                  _tasksController.markTaskCompleted(task.id!);
                  Get.back();
                },
                clr: primaryClr,
                context: context
                ),
            _bottomSheetButton(
                label: "Delete Task",
                onTap: () {
                  _tasksController.delete(task);
                  Get.back();
                },
                clr: Colors.red[400]!,
                context: context
            ),
            const SizedBox(height: 20),
            _bottomSheetButton(
                label: "Close",
                onTap: () {
                  Get.back();
                },
                clr: Colors.white,
                isClose: true,
                context: context
            ),
            const SizedBox(height: 10)
          ]
        )
      )
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

  _dateBar() {
    return Container(
        margin: const EdgeInsets.only(top: 20, left: 20),
        child: DatePicker(
            DateTime.now(),
            height: 100,
            width: 80,
            initialSelectedDate: DateTime.now(),
            selectionColor: primaryClr,
            selectedTextColor: Colors.white,
            dateTextStyle: GoogleFonts.lato(
                textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey
                )
            ),
            dayTextStyle: GoogleFonts.lato(
                textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey
                )
            ),
            monthTextStyle: GoogleFonts.lato(
                textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey
                )
            ),
            onDateChange: (date){
              setState(() {
                _selectedDate = date;
              });
            }
        )
    );
  }

  _taskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text("Today",
                style: headingStyle,
              )
            ],
          ),
          MyButton(label: "+ Add Task", onTap: () async {
            await Get.to(() => const AddTaskPage());
            _tasksController.getTasks();
          })
        ],
      ),
    );
  }

  _appBar(){
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.colorScheme.background,
      leading: GestureDetector(
        onTap: (){
          ThemeService().switchTheme();
        },
        child: Icon(Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
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
}
