import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_manager.dart';
import 'core/services/notification_service.dart';
import 'core/services/backup_service.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  final backupService = BackupService();
  notificationService.init();
  await backupService.init();
  runApp(ZionOSApp(
    notificationService: notificationService,
    backupService: backupService,
  ));
}

class ZionOSApp extends StatelessWidget {
  final NotificationService notificationService;
  final BackupService backupService;
  
  const ZionOSApp({
    super.key,
    required this.notificationService,
    required this.backupService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        Provider.value(value: backupService),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Zion OS 2027',
            debugShowCheckedModeBanner: false,
            theme: themeManager.getThemeData(),
            home: const LockScreen(),
          );
        },
      ),
    );
  }
}
