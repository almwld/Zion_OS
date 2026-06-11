import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'services/preferences_service.dart';
import 'widgets/radar_widget.dart';
import 'widgets/battery_popup.dart';
import 'widgets/quick_settings.dart';
import 'screens/settings_screen.dart';

class ResponsiveDesktop extends StatefulWidget {
  const ResponsiveDesktop({super.key});

  @override
  State<ResponsiveDesktop> createState() => _ResponsiveDesktopState();
}

class _ResponsiveDesktopState extends State<ResponsiveDesktop> {
  final GlobalKey _radarKey = GlobalKey();
  bool _showQuickSettings = false;
  bool _showBatteryInfo = false;

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    
    return Scaffold(
      backgroundColor: prefs.isDarkMode ? Colors.black : Colors.grey[100],
      body: Stack(
        children: [
          // Wallpaper
          Container(
            decoration: BoxDecoration(
              image: prefs.useCustomWallpaper && prefs.wallpaperPath.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(prefs.wallpaperPath)),
                      fit: BoxFit.cover,
                      colorFilter: prefs.wallpaperBlur > 0
                          ? ColorFilter.mode(
                              Colors.black.withOpacity(prefs.wallpaperBlur / 20),
                              BlendMode.darken,
                            )
                          : null,
                    )
                  : null,
              color: prefs.isDarkMode ? Colors.black : Colors.grey[100],
            ),
          ),
          
          Column(
            children: [
              // Top Bar
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: (prefs.isDarkMode ? Colors.black : Colors.white).withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: prefs.isDarkMode ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyan, Colors.teal],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Z',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Zion OS',
                          style: TextStyle(
                            fontSize: 18 * prefs.fontScale,
                            fontWeight: FontWeight.bold,
                            color: prefs.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    
                    // System Tray
                    Row(
                      children: [
                        // WiFi Icon
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.wifi,
                            color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 5),
                        
                        // Battery with Popup
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showBatteryInfo = !_showBatteryInfo;
                              _showQuickSettings = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _showBatteryInfo
                                  ? (prefs.isDarkMode ? Colors.white24 : Colors.black12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.battery_full,
                                  color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '85%',
                                  style: TextStyle(
                                    fontSize: 12 * prefs.fontScale,
                                    color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        
                        // Time with Quick Settings
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showQuickSettings = !_showQuickSettings;
                              _showBatteryInfo = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _showQuickSettings
                                  ? (prefs.isDarkMode ? Colors.white24 : Colors.black12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('hh:mm a').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 12 * prefs.fontScale,
                                    fontWeight: FontWeight.w500,
                                    color: prefs.isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd/MM').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 10 * prefs.fontScale,
                                    color: prefs.isDarkMode ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Desktop Content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Categories
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCategoryButton('attack'.tr(), Colors.red, prefs, Icons.bug_report),
                            const SizedBox(width: 20),
                            _buildCategoryButton('defense'.tr(), Colors.blue, prefs, Icons.shield),
                            const SizedBox(width: 20),
                            _buildCategoryButton('analysis'.tr(), Colors.green, prefs, Icons.analytics),
                            const SizedBox(width: 20),
                            _buildCategoryButton('tools'.tr(), Colors.orange, prefs, Icons.build),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Welcome Message
                      Text(
                        'welcome'.tr(),
                        style: TextStyle(
                          fontSize: 24 * prefs.fontScale,
                          fontWeight: FontWeight.bold,
                          color: prefs.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Text(
                        'description'.tr(),
                        style: TextStyle(
                          fontSize: 14 * prefs.fontScale,
                          color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Dock
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: (prefs.isDarkMode ? Colors.black : Colors.white).withOpacity(0.8),
                  border: Border(
                    top: BorderSide(
                      color: prefs.isDarkMode ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDockIcon(Icons.terminal, 'Terminal', prefs),
                    const SizedBox(width: 30),
                    _buildDockIcon(Icons.wifi, 'WiFi', prefs),
                    const SizedBox(width: 30),
                    _buildDockIcon(Icons.security, 'Security', prefs),
                    const SizedBox(width: 30),
                    _buildDockIcon(Icons.folder, 'Files', prefs),
                    const SizedBox(width: 30),
                    _buildDockIcon(Icons.settings, 'Settings', prefs, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          
          // Floating Radar Widget
          if (prefs.radarVisible)
            Positioned(
              left: prefs.radarPositionX,
              top: prefs.radarPositionY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  prefs.setRadarPosition(
                    (prefs.radarPositionX + details.delta.dx).clamp(0, MediaQuery.of(context).size.width - 180),
                    (prefs.radarPositionY + details.delta.dy).clamp(60, MediaQuery.of(context).size.height - 240),
                  );
                },
                child: const RadarWidget(),
              ),
            ),
          
          // Battery Popup
          if (_showBatteryInfo)
            Positioned(
              right: 20,
              top: 70,
              child: BatteryPopup(
                onClose: () => setState(() => _showBatteryInfo = false),
              ),
            ),
          
          // Quick Settings
          if (_showQuickSettings)
            Positioned(
              right: 20,
              top: 70,
              child: QuickSettings(
                onClose: () => setState(() => _showQuickSettings = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, Color color, PreferencesService prefs, IconData icon) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14 * prefs.fontScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDockIcon(IconData icon, String label, PreferencesService prefs, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          if (prefs.showAppNames)
            Text(
              label,
              style: TextStyle(
                fontSize: 10 * prefs.fontScale,
                color: prefs.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}
