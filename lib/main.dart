import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

void main() async {
  runApp(const MyApp());
  await initSystemTray();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SizedBox.shrink(),
    );
  }
}

Future<void> initSystemTray() async {
  final systemTray = SystemTray();

  // Get current Nepali date
  String nepaliDate = NepaliDateFormat(
    "yyyy MMM dd",
  ).format(NepaliDateTime.now());

  // Initialize tray
  await systemTray.initSystemTray(
    iconPath: "assets/tray_icon.png",
    title: ' $nepaliDate',
  );

  // Build dropdown menu with date as title
  final menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: nepaliDate,
      enabled: false, // Disabled so it acts like a title
    ),
    MenuSeparator(),
    MenuItemLabel(
      label: 'Refresh Date',
      onClicked: (menuItem) async {
        final today = NepaliDateFormat(
          "yyyy MMM dd",
        ).format(NepaliDateTime.now());
        nepaliDate = today;
        
        // Rebuild menu with updated date
        final newMenu = Menu();
        await newMenu.buildFrom([
          MenuItemLabel(label: '📅 $today', enabled: false),
          MenuSeparator(),
          MenuItemLabel(
            label: 'Refresh Date',
            onClicked: (item) async => initSystemTray(),
          ),
          MenuItemLabel(
            label: 'Quit',
            onClicked: (item) async => systemTray.destroy(),
          ),
        ]);
        await systemTray.setContextMenu(newMenu);
        systemTray.popUpContextMenu();
      },
    ),
    MenuItemLabel(
      label: 'Quit',
      onClicked: (menuItem) async {
        systemTray.destroy();
      },
    ),
  ]);

  // Register click to expand menu
  systemTray.registerSystemTrayEventHandler((eventName) async {
    if (eventName == kSystemTrayEventClick) {
      systemTray.popUpContextMenu();
    }
  });

  // Attach context menu
  await systemTray.setContextMenu(menu);
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  NepaliDateTime selectedDate = NepaliDateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nepali Calendar - ${NepaliDateFormat('yyyy MMM dd').format(selectedDate)}",
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.30,
          ),
          child: Center(
            child: NepaliCupertinoDatePicker(
              maximumYear: 2100,
              minimumYear: 2000,
              dateOrder: DateOrder.ydm,
              initialDate: selectedDate,
              onDateChanged: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
