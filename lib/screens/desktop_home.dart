import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
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

class ZionDesktop extends StatelessWidget {
  const ZionDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isDesktop;
    
    return Scaffold(
      body: Stack(
        children: [
          // خلفية متدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF0D2E3B),
                  Color(0xFF061217),
                  Color(0xFF03090C),
                ],
              ),
            ),
          ),
          
          // تخطيط مرن حسب حجم الشاشة
          if (isDesktop)
            _buildDesktopLayout()
          else
            _buildMobileLayout(),
        ],
      ),
    );
  }

  // ============================================
  // تخطيط سطح المكتب - مثل GNOME بالضبط
  // ============================================
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        const TopBar(),
        Expanded(
          child: Row(
            children: [
              // الشريط الجانبي الأيسر (Activities)
              const LeftSidebar(),
              
              // المحتوى الرئيسي
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
                      const Expanded(child: AppGrid()),
                      const PageIndicator(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // الشريط الجانبي الأيمن (الإشعارات)
              const RightSidebar(),
            ],
          ),
        ),
        const Dock(),
        const SizedBox(height: 15),
      ],
    );
  }

  // ============================================
  // تخطيط المحمول
  // ============================================
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
                const Expanded(child: AppGrid()),
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
}

// ============================================
// الشريط العلوي (Top Bar)
// ============================================
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: Colors.black.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ZION OS 2027', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF00BCD4))),
          const Text('SECURE MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF00BCD4))),
          const Spacer(),
          // أيقونات النظام
          const Row(
            children: [
              Icon(Icons.network_wifi, size: 14, color: Color(0xFF00BCD4)),
              SizedBox(width: 12),
              Icon(Icons.battery_full, size: 14, color: Color(0xFF00BCD4)),
              SizedBox(width: 12),
              Icon(Icons.security, size: 14, color: Color(0xFF00BCD4)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// الشريط الجانبي الأيسر (Activities)
// ============================================
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
          _buildSidebarButton(Icons.grid_view, 'Activities'),
          const SizedBox(height: 30),
          _buildSidebarButton(Icons.apps, 'Apps'),
          const SizedBox(height: 30),
          _buildSidebarButton(Icons.settings, 'Settings'),
          const SizedBox(height: 30),
          _buildSidebarButton(Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSidebarButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF00BCD4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF00BCD4), size: 22),
      ),
    );
  }
}

// ============================================
// الشريط الجانبي الأيمن (Notifications)
// ============================================
class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.black.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'NOTIFICATIONS',
              style: TextStyle(fontSize: 12, color: const Color(0xFF00BCD4).withOpacity(0.7), letterSpacing: 1),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                NotificationCard(title: 'System Update', message: 'Zion OS 2027 is ready', time: '5 min ago'),
                NotificationCard(title: 'Security Alert', message: 'Unauthorized access blocked', time: '15 min ago'),
                NotificationCard(title: 'Network', message: 'Connected to secure network', time: '1 hour ago'),
                NotificationCard(title: 'Storage', message: 'Cleaned 2.5GB of cache', time: '2 hours ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  
  const NotificationCard({super.key, required this.title, required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
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

// ============================================
// شريط البحث (Search Bar)
// ============================================
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ResponsiveWrapper.of(context).isDesktop ? 450 : 350,
      height: 40,
      child: TextField(
        style: const TextStyle(fontSize: 14, color: Color(0xFF00BCD4)),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF00BCD4)),
          hintText: 'Type to search...',
          hintStyle: const TextStyle(color: Color(0xFF00BCD4), fontSize: 13),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ============================================
// معاينة أسطح المكتب (Workspaces Preview)
// ============================================
class WorkspacesPreview extends StatelessWidget {
  const WorkspacesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isDesktop;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWorkspaceCard(isActive: true, width: isDesktop ? 180 : 160),
        const SizedBox(width: 20),
        _buildWorkspaceCard(isActive: false, width: isDesktop ? 180 : 160),
        if (isDesktop) ...[
          const SizedBox(width: 20),
          _buildWorkspaceCard(isActive: false, width: 180),
          const SizedBox(width: 20),
          _buildWorkspaceCard(isActive: false, width: 180),
        ],
      ],
    );
  }

  Widget _buildWorkspaceCard({required bool isActive, required double width}) {
    return Container(
      width: width,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A2F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? const Color(0xFF00BCD4).withOpacity(0.6) : Colors.white.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF00BCD4).withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Icon(
          Icons.grid_view,
          size: 24,
          color: isActive ? const Color(0xFF00BCD4).withOpacity(0.6) : Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }
}

// ============================================
// شبكة التطبيقات (App Grid)
// ============================================
class AppGrid extends StatelessWidget {
  const AppGrid({super.key});

  static const List<Map<String, dynamic>> apps = [
    {'name': 'TERMINAL', 'icon': Icons.terminal},
    {'name': 'NETWORK', 'icon': Icons.network_wifi},
    {'name': 'WIFI', 'icon': Icons.wifi},
    {'name': 'EXPLOIT', 'icon': Icons.bug_report},
    {'name': 'CRYPTO', 'icon': Icons.lock},
    {'name': 'STEALTH', 'icon': Icons.visibility_off},
    {'name': 'CRACKER', 'icon': Icons.vpn_key},
    {'name': 'DDOS', 'icon': Icons.speed},
    {'name': 'FORENSICS', 'icon': Icons.search},
    {'name': 'DATABASE', 'icon': Icons.storage},
    {'name': 'CLOUD', 'icon': Icons.cloud},
    {'name': 'SETTINGS', 'icon': Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isDesktop;
    final crossAxisCount = isDesktop ? 8 : 4;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: isDesktop ? 30 : 20,
        crossAxisSpacing: isDesktop ? 25 : 15,
        childAspectRatio: 0.9,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isDesktop ? 60 : 50,
              height: isDesktop ? 60 : 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF00BCD4), Color(0xFF006064)],
                ),
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BCD4).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Icon(apps[index]['icon'], color: Colors.white, size: isDesktop ? 30 : 26),
            ),
            const SizedBox(height: 8),
            Text(
              apps[index]['name'],
              style: TextStyle(
                fontSize: isDesktop ? 12 : 10,
                color: const Color(0xFFB2EBF2),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

// ============================================
// مؤشر الصفحات (Page Indicator)
// ============================================
class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: Color(0xFF00BCD4), shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.25), shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: const Color(0xFF00BCD4).withOpacity(0.1), shape: BoxShape.circle),
        ),
      ],
    );
  }
}

// ============================================
// الشريط السفلي (Dock) - زجاجي مثل GNOME
// ============================================
class Dock extends StatelessWidget {
  const Dock({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dockApps = [
      {'name': 'TERM', 'icon': Icons.terminal},
      {'name': 'NET', 'icon': Icons.network_wifi},
      {'name': 'WIFI', 'icon': Icons.wifi},
      {'name': 'LOCK', 'icon': Icons.lock},
      {'name': 'HIDE', 'icon': Icons.visibility_off},
      {'name': 'KEY', 'icon': Icons.vpn_key},
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.15), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...dockApps.map((app) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF00BCD4), Color(0xFF006064)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(app['icon'], color: Colors.white, size: 26),
                    ),
                  )),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                width: 1,
                color: const Color(0xFF00BCD4).withOpacity(0.2),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apps, color: Color(0xFF00BCD4), size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
