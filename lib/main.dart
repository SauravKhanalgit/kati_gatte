import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_tray/system_tray.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await initSystemTray();
  _startDateRefreshTimer();
}

// Global navigator key for showing dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Auto-refresh timer to update date at midnight
void _startDateRefreshTimer() {
  Timer.periodic(const Duration(minutes: 1), (timer) {
    final now = DateTime.now();
    // Refresh at midnight
    if (now.hour == 0 && now.minute == 0) {
      initSystemTray();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(elevation: 2),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SizedBox.shrink(),
      routes: {
        '/calendar': (context) => const CalendarScreen(),
        '/converter': (context) => const DateConverterScreen(),
      },
    );
  }
}

Future<void> initSystemTray() async {
  final systemTray = SystemTray();

  // Get current Nepali date
  final now = NepaliDateTime.now();
  final nowAD = DateTime.now();

  String nepaliDate = NepaliDateFormat("yyyy MMM dd").format(now);
  String nepaliDay = NepaliDateFormat("EEEE").format(now);
  String adDate =
      "${nowAD.year}-${nowAD.month.toString().padLeft(2, '0')}-${nowAD.day.toString().padLeft(2, '0')}";

  // Initialize tray with Nepali date
  await systemTray.initSystemTray(
    iconPath: "assets/tray_icon.png",
    title: ' $nepaliDate',
  );

  // Build enhanced dropdown menu
  final menu = Menu();
  await menu.buildFrom([
    // Header with full date
    MenuItemLabel(label: '📅 $nepaliDay', enabled: false),
    MenuItemLabel(label: 'BS: $nepaliDate', enabled: false),
    MenuItemLabel(label: 'AD: $adDate', enabled: false),
    MenuSeparator(),

    // Copy options
    MenuItemLabel(
      label: '📋 Copy Nepali Date',
      onClicked: (menuItem) async {
        await Clipboard.setData(ClipboardData(text: nepaliDate));
        _showNotification('Copied: $nepaliDate');
      },
    ),
    MenuItemLabel(
      label: '📋 Copy AD Date',
      onClicked: (menuItem) async {
        await Clipboard.setData(ClipboardData(text: adDate));
        _showNotification('Copied: $adDate');
      },
    ),
    MenuItemLabel(
      label: '📋 Copy Both Dates',
      onClicked: (menuItem) async {
        final both = 'BS: $nepaliDate | AD: $adDate';
        await Clipboard.setData(ClipboardData(text: both));
        _showNotification('Copied both dates!');
      },
    ),
    MenuSeparator(),

    // Calendar and Converter
    MenuItemLabel(
      label: '�️  Open Full Calendar',
      onClicked: (menuItem) async {
        _openCalendarWindow();
      },
    ),
    MenuItemLabel(
      label: '🔄 Date Converter',
      onClicked: (menuItem) async {
        _openConverterWindow();
      },
    ),
    MenuSeparator(),

    // Utilities
    MenuItemLabel(
      label: '🔄 Refresh Date',
      onClicked: (menuItem) async {
        await initSystemTray();
        _showNotification('Date refreshed!');
      },
    ),
    MenuItemLabel(
      label: 'ℹ️  About',
      onClicked: (menuItem) async {
        _showAboutDialog();
      },
    ),
    MenuSeparator(),
    MenuItemLabel(
      label: '❌ Quit',
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

  await systemTray.setContextMenu(menu);
}

// Helper functions
void _showNotification(String message) {
  final context = navigatorKey.currentContext;
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void _openCalendarWindow() {
  navigatorKey.currentState?.pushNamed('/calendar');
}

void _openConverterWindow() {
  navigatorKey.currentState?.pushNamed('/converter');
}

void _showAboutDialog() {
  final context = navigatorKey.currentContext;
  if (context != null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📅 Kati Gatte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nepali Calendar System Tray App'),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            const Text('Features:'),
            const Text('• Live Nepali & AD dates'),
            const Text('• Quick copy to clipboard'),
            const Text('• Date converter (BS ↔ AD)'),
            const Text('• Full calendar view'),
            const Text('• Public holidays'),
            const SizedBox(height: 16),
            Text(
              'Developed with ❤️ in Nepal',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Enhanced Calendar Screen with beautiful UI
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  NepaliDateTime selectedDate = NepaliDateTime.now();

  // Nepali public holidays (BS 2081)
  final Map<String, String> holidays = {
    '2081-01-01': 'नयाँ वर्ष (New Year)',
    '2081-01-11': 'लोकतन्त्र दिवस (Democracy Day)',
    '2081-03-03': 'महिला दिवस (Women\'s Day)',
    '2081-08-15': 'संविधान दिवस (Constitution Day)',
    '2081-09-01': 'दशैं (Dashain)',
    '2081-10-15': 'तिहार (Tihar)',
  };

  bool _isHoliday(NepaliDateTime date) {
    String dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return holidays.containsKey(dateKey);
  }

  String? _getHolidayName(NepaliDateTime date) {
    String dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return holidays[dateKey];
  }

  @override
  Widget build(BuildContext context) {
    final isHoliday = _isHoliday(selectedDate);
    final holidayName = _getHolidayName(selectedDate);
    final adDate = selectedDate.toDateTime();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Nepali Calendar'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Go to Today',
            onPressed: () {
              setState(() {
                selectedDate = NepaliDateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Beautiful Date Display Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHoliday
                    ? [Colors.red.shade400, Colors.orange.shade400]
                    : [Colors.deepOrange.shade400, Colors.orange.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    NepaliDateFormat('EEEE').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NepaliDateFormat('yyyy MMMM dd').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AD: ${adDate.year}-${adDate.month.toString().padLeft(2, '0')}-${adDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (isHoliday) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.celebration, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            holidayName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Info Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Month',
                    NepaliDateFormat('MMMM').format(selectedDate),
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Day',
                    selectedDate.day.toString(),
                    Icons.today,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Year',
                    selectedDate.year.toString(),
                    Icons.event,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Date Picker
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: NepaliCupertinoDatePicker(
                  maximumYear: 2100,
                  minimumYear: 2000,
                  dateOrder: DateOrder.ymd,
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

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final dateText = NepaliDateFormat(
                      'yyyy MMMM dd, EEEE',
                    ).format(selectedDate);
                    await Clipboard.setData(ClipboardData(text: dateText));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied: $dateText'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Nepali Date'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final adDateText =
                        '${adDate.year}-${adDate.month.toString().padLeft(2, '0')}-${adDate.day.toString().padLeft(2, '0')}';
                    await Clipboard.setData(ClipboardData(text: adDateText));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied: $adDateText'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Copy AD Date'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/converter');
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Date Converter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Advanced Date Converter Screen
class DateConverterScreen extends StatefulWidget {
  const DateConverterScreen({super.key});

  @override
  State<DateConverterScreen> createState() => _DateConverterScreenState();
}

class _DateConverterScreenState extends State<DateConverterScreen> {
  bool isBStoAD = true;
  NepaliDateTime? nepaliDate = NepaliDateTime.now();
  DateTime? adDate = DateTime.now();

  void _convertDate() {
    setState(() {
      if (isBStoAD && nepaliDate != null) {
        adDate = nepaliDate!.toDateTime();
      } else if (!isBStoAD && adDate != null) {
        nepaliDate = NepaliDateTime.fromDateTime(adDate!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔄 Date Converter'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Conversion Direction Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Conversion Direction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('BS → AD'),
                          icon: Icon(Icons.arrow_forward),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('AD → BS'),
                          icon: Icon(Icons.arrow_back),
                        ),
                      ],
                      selected: {isBStoAD},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          isBStoAD = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.input,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBStoAD ? 'Nepali Date (BS)' : 'English Date (AD)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isBStoAD) {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: adDate ?? DateTime.now(),
                            firstDate: DateTime(1970),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              adDate = picked;
                              nepaliDate = NepaliDateTime.fromDateTime(picked);
                            });
                          }
                        } else {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: adDate ?? DateTime.now(),
                            firstDate: DateTime(1970),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              adDate = picked;
                            });
                          }
                        }
                        _convertDate();
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Select Date'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBStoAD
                            ? NepaliDateFormat(
                                'yyyy MMMM dd, EEEE',
                              ).format(nepaliDate!)
                            : '${adDate!.year}-${adDate!.month.toString().padLeft(2, '0')}-${adDate!.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Conversion Arrow
            Icon(
              Icons.arrow_downward_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 24),

            // Output Date
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.output,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBStoAD ? 'English Date (AD)' : 'Nepali Date (BS)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        isBStoAD
                            ? '${adDate!.year}-${adDate!.month.toString().padLeft(2, '0')}-${adDate!.day.toString().padLeft(2, '0')}'
                            : NepaliDateFormat(
                                'yyyy MMMM dd, EEEE',
                              ).format(nepaliDate!),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final textToCopy = isBStoAD
                            ? '${adDate!.year}-${adDate!.month.toString().padLeft(2, '0')}-${adDate!.day.toString().padLeft(2, '0')}'
                            : NepaliDateFormat(
                                'yyyy MMMM dd',
                              ).format(nepaliDate!);
                        await Clipboard.setData(
                          ClipboardData(text: textToCopy),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied: $textToCopy'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Result'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.today, size: 18),
                  label: const Text('Today'),
                  onPressed: () {
                    setState(() {
                      nepaliDate = NepaliDateTime.now();
                      adDate = DateTime.now();
                      _convertDate();
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.event, size: 18),
                  label: const Text('New Year 2082'),
                  onPressed: () {
                    setState(() {
                      nepaliDate = NepaliDateTime(2082, 1, 1);
                      adDate = nepaliDate!.toDateTime();
                      _convertDate();
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Switch Direction'),
                  onPressed: () {
                    setState(() {
                      isBStoAD = !isBStoAD;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
