import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/window_title_bar.dart';
import '../widgets/start_menu.dart';
import '../widgets/system_tray.dart';
import 'apps/terminal_app.dart';
import 'apps/network_scanner.dart';
import 'apps/wifi_scanner.dart';
import 'apps/exploit_db.dart';
import 'apps/crypto_tool.dart';
import 'apps/stealth_mode.dart';
import 'apps/password_cracker.dart';
import 'apps/ddos_attack.dart';
import 'apps/forensics.dart';
import 'apps/database_hacking.dart';
import 'apps/cloud_attacks.dart';

class ZionDesktop extends StatefulWidget {
  const ZionDesktop({super.key});

  @override
  State<ZionDesktop> createState() => _ZionDesktopState();
}

class _ZionDesktopState extends State<ZionDesktop> {
  final List<Map<String, dynamic>> _openWindows = [];
  bool _showStartMenu = false;

  void _openApp(Map<String, dynamic> app) {
    setState(() {
      if (!_openWindows.any((w) => w['name'] == app['name'])) {
        _openWindows.add(app);
      }
      _showStartMenu = false;
    });
  }

  void _closeWindow(String appName) {
    setState(() {
      _openWindows.removeWhere((w) => w['name'] == appName);
    });
  }

  void _minimizeWindow(String appName) {
    setState(() {
      final index = _openWindows.indexWhere((w) => w['name'] == appName);
      if (index != -1) {
        _openWindows[index]['minimized'] = true;
      }
    });
  }

  void _restoreWindow(String appName) {
    setState(() {
      final index = _openWindows.indexWhere((w) => w['name'] == appName);
      if (index != -1) {
        _openWindows[index]['minimized'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isDesktop;
    final activeWindows = _openWindows.where((w) => w['minimized'] != true).toList();
    
    return Scaffold(
      body: Stack(
        children: [
          // خلفية
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF0D2E3B), Color(0xFF061217), Color(0xFF03090C)],
              ),
            ),
          ),
          
          if (isDesktop)
            _buildDesktopLayout()
          else
            _buildMobileLayout(),
          
          // النوافذ المفتوحة
          ...activeWindows.asMap().entries.map((entry) => Positioned(
            left: 80 + entry.key * 30,
            top: 80 + entry.key * 30,
            child: _buildAppWindow(entry.value),
          )),
          
          // Start Menu
          if (_showStartMenu)
            StartMenu(onClose: () => setState(() => _showStartMenu = false)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        const WindowTitleBar(title: 'ZION OS 2027 - Desktop Environment'),
        Expanded(
          child: Row(
            children: [
              const LeftSidebar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const SearchBar(),
                      const SizedBox(height: 30),
                      const WorkspacesPreview(),
                      const SizedBox(height: 40),
                      Expanded(
                        child: AppGrid(
                          onAppTap: (app) => _openApp(app),
                        ),
                      ),
                      const PageIndicator(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const RightSidebar(),
            ],
          ),
        ),
        // Taskbar - شريط المهام
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            border: Border(top: BorderSide(color: const Color(0xFF00BCD4).withOpacity(0.2))),
          ),
          child: Row(
            children: [
              // زر Start
              GestureDetector(
                onTap: () => setState(() => _showStartMenu = !_showStartMenu),
                child: Container(
                  width: 60,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _showStartMenu ? const Color(0xFF00BCD4).withOpacity(0.2) : Colors.transparent,
                  ),
                  child: const Icon(Icons.window, color: Color(0xFF00BCD4), size: 24),
                ),
              ),
              
              // أيقونات التطبيقات المفتوحة
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _openWindows.map((window) => GestureDetector(
                      onTap: () => window['minimized'] ? _restoreWindow(window['name']) : _minimizeWindow(window['name']),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: window['minimized'] 
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0xFF00BCD4).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: window['minimized'] 
                                ? const Color(0xFF00BCD4).withOpacity(0.2)
                                : const Color(0xFF00BCD4).withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(window['icon'], color: const Color(0xFF00BCD4), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              window['name'],
                              style: TextStyle(
                                color: window['minimized'] ? Colors.white54 : Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
              
              // System Tray
              const SystemTray(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        const TopBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const SearchBar(),
                const SizedBox(height: 25),
                const WorkspacesPreview(),
                const SizedBox(height: 35),
                Expanded(
                  child: AppGrid(
                    onAppTap: (app) => _openApp(app),
                  ),
                ),
                const PageIndicator(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const Dock(),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildAppWindow(Map<String, dynamic> app) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 800,
        height: 550,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildWindowHeader(app),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: app['screen'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowHeader(Map<String, dynamic> app) {
    return GestureDetector(
      onPanStart: (details) {},
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF00BCD4).withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _closeWindow(app['name']),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _minimizeWindow(app['name']),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const Expanded(child: SizedBox()),
            Text(
              app['name'],
              style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 12),
            ),
            const Expanded(child: SizedBox()),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Color(0xFF00BCD4)),
              onPressed: () => _closeWindow(app['name']),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

// ============================================
// باقي المكونات (مختصرة للتوفير)
// ============================================
class TopBar extends StatelessWidget {
  const TopBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ZION OS 2027', style: TextStyle(fontSize: 13, color: Color(0xFF00BCD4))),
          Text('SECURE MODE', style: TextStyle(fontSize: 11, color: Color(0xFF00BCD4))),
          Row(
            children: [
              Icon(Icons.network_wifi, size: 14, color: Color(0xFF00BCD4)),
              SizedBox(width: 12),
              Icon(Icons.battery_full, size: 14, color: Color(0xFF00BCD4)),
            ],
          ),
        ],
      ),
    );
  }
}

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      color: Colors.black.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(Icons.grid_view),
          const SizedBox(height: 30),
          _buildButton(Icons.apps),
          const SizedBox(height: 30),
          _buildButton(Icons.settings),
          const SizedBox(height: 30),
          _buildButton(Icons.person),
        ],
      ),
    );
  }
  Widget _buildButton(IconData icon) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: const Color(0xFF00BCD4), size: 22),
  );
}

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.black.withOpacity(0.3),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('NOTIFICATIONS', style: TextStyle(fontSize: 12, color: const Color(0xFF00BCD4).withOpacity(0.7))),
          ),
          Expanded(
            child: ListView(
              children: const [
                _NotificationCard('System Update', 'Zion OS 2027 is ready', '5 min ago'),
                _NotificationCard('Security Alert', 'Unauthorized access blocked', '15 min ago'),
                _NotificationCard('Network', 'Connected to secure network', '1 hour ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title, message, time;
  const _NotificationCard(this.title, this.message, this.time);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ResponsiveWrapper.of(context).isDesktop ? 450 : 350, height: 40,
      child: TextField(
        style: const TextStyle(fontSize: 14, color: Color(0xFF00BCD4)),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF00BCD4)),
          hintText: 'Type to search...',
          hintStyle: const TextStyle(color: Color(0xFF00BCD4), fontSize: 13),
          filled: true, fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class WorkspacesPreview extends StatelessWidget {
  const WorkspacesPreview({super.key});
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isDesktop;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCard(true, isDesktop ? 180 : 160),
        const SizedBox(width: 20),
        _buildCard(false, isDesktop ? 180 : 160),
        if (isDesktop) ...[
          const SizedBox(width: 20), _buildCard(false, 180),
          const SizedBox(width: 20), _buildCard(false, 180),
        ],
      ],
    );
  }
  Widget _buildCard(bool isActive, double width) => Container(
    width: width, height: 110,
    decoration: BoxDecoration(
      color: const Color(0xFF1A2A2F), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isActive ? const Color(0xFF00BCD4).withOpacity(0.6) : Colors.white.withOpacity(0.05), width: 1.5),
      boxShadow: isActive ? [BoxShadow(color: const Color(0xFF00BCD4).withOpacity(0.15), blurRadius: 12)] : [],
    ),
    child: Center(child: Icon(Icons.grid_view, size: 24, color: isActive ? const Color(0xFF00BCD4).withOpacity(0.6) : Colors.white.withOpacity(0.15))),
  );
}

class AppGrid extends StatelessWidget {
  final Function(Map<String, dynamic>) onAppTap;
  const AppGrid({super.key, required this.onAppTap});
  static const List<Map<String, dynamic>> apps = [
    {'name': 'TERMINAL', 'icon': Icons.terminal, 'screen': TerminalApp()},
    {'name': 'NETWORK', 'icon': Icons.network_wifi, 'screen': NetworkScannerApp()},
    {'name': 'WIFI', 'icon': Icons.wifi, 'screen': WiFiScannerApp()},
    {'name': 'EXPLOIT', 'icon': Icons.bug_report, 'screen': ExploitDBApp()},
    {'name': 'CRYPTO', 'icon': Icons.lock, 'screen': CryptoToolApp()},
    {'name': 'STEALTH', 'icon': Icons.visibility_off, 'screen': StealthModeApp()},
    {'name': 'CRACKER', 'icon': Icons.vpn_key, 'screen': PasswordCrackerApp()},
    {'name': 'DDOS', 'icon': Icons.speed, 'screen': DDoSAttackApp()},
    {'name': 'FORENSICS', 'icon': Icons.search, 'screen': ForensicsApp()},
    {'name': 'DATABASE', 'icon': Icons.storage, 'screen': DatabaseHackingApp()},
    {'name': 'CLOUD', 'icon': Icons.cloud, 'screen': CloudAttacksApp()},
    {'name': 'SETTINGS', 'icon': Icons.settings, 'screen': null},
  ];
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isDesktop;
    final crossAxisCount = isDesktop ? 8 : 4;
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: isDesktop ? 30 : 20, crossAxisSpacing: isDesktop ? 25 : 15,
        childAspectRatio: 0.9,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return GestureDetector(
          onTap: () => onAppTap(app),
          child: Column(
            children: [
              Container(
                width: isDesktop ? 60 : 50, height: isDesktop ? 60 : 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
                  boxShadow: [BoxShadow(color: const Color(0xFF00BCD4).withOpacity(0.2), blurRadius: 8)],
                ),
                child: Icon(app['icon'], color: Colors.white, size: isDesktop ? 30 : 26),
              ),
              const SizedBox(height: 8),
              Text(app['name'], style: TextStyle(fontSize: isDesktop ? 12 : 10, color: const Color(0xFFB2EBF2))),
            ],
          ),
        );
      },
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00BCD4), shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.25), shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.1), shape: BoxShape.circle)),
      ],
    );
  }
}

class Dock extends StatelessWidget {
  const Dock({super.key});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 70, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...['TERM', 'NET', 'WIFI', 'LOCK', 'HIDE', 'KEY'].map((name) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                ),
              )),
              Container(margin: const EdgeInsets.symmetric(horizontal: 15), width: 1, color: const Color(0xFF00BCD4).withOpacity(0.2)),
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.apps, color: Color(0xFF00BCD4), size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
