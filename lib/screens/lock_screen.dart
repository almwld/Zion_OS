import 'package:flutter/material.dart';
import 'desktop_home.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String _correctPin = "1234";
  String _errorMessage = "";
  String _currentTime = "";
  String _currentDate = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          _currentDate = "${_getDayName(now.weekday)} ${now.day} ${_getMonthName(now.month)}";
        });
        _updateDateTime();
      }
    });
  }

  String _getDayName(int weekday) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  void _unlock() async {
    if (_pinController.text == _correctPin) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ZionDesktop()),
        );
      }
    } else {
      setState(() {
        _errorMessage = "PIN INCORRECT";
        _pinController.clear();
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _errorMessage = "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF0D2E3B), Color(0xFF03090C)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF00BCD4)),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Zion OS...',
                        style: TextStyle(color: const Color(0xFF00BCD4), fontSize: isSmallScreen ? 12 : 14),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: SizedBox(
                    height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo - حجم متناسب
                          Container(
                            width: screenWidth * 0.18,
                            height: screenWidth * 0.18,
                            constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00BCD4).withOpacity(0.5),
                                  blurRadius: screenWidth * 0.05,
                                  spreadRadius: screenWidth * 0.01,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Z",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.09,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          // Title
                          Text(
                            "ZION OS 2027",
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00BCD4),
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Date
                          Text(
                            _currentDate,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          // Time
                          Text(
                            _currentTime,
                            style: TextStyle(
                              fontSize: screenWidth * 0.12,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF00BCD4),
                              letterSpacing: 4,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.06),
                          
                          // PIN Input
                          Container(
                            width: screenWidth * 0.6,
                            constraints: const BoxConstraints(maxWidth: 280),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.5)),
                            ),
                            child: TextField(
                              controller: _pinController,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF00BCD4),
                                fontSize: screenWidth * 0.06,
                                letterSpacing: 10,
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              decoration: const InputDecoration(
                                hintText: "••••",
                                hintStyle: TextStyle(color: Colors.white30, fontSize: 24),
                                border: InputBorder.none,
                                counterText: "",
                              ),
                              onSubmitted: (_) => _unlock(),
                            ),
                          ),
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          SizedBox(height: screenHeight * 0.04),
                          
                          // Number Pad - شبكة متجاوبة
                          Container(
                            width: screenWidth * 0.7,
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 3,
                              mainAxisSpacing: screenHeight * 0.015,
                              crossAxisSpacing: screenWidth * 0.03,
                              childAspectRatio: 1.2,
                              children: [
                                _buildButton("1", screenWidth),
                                _buildButton("2", screenWidth),
                                _buildButton("3", screenWidth),
                                _buildButton("4", screenWidth),
                                _buildButton("5", screenWidth),
                                _buildButton("6", screenWidth),
                                _buildButton("7", screenWidth),
                                _buildButton("8", screenWidth),
                                _buildButton("9", screenWidth),
                                _buildButton("", screenWidth),
                                _buildButton("0", screenWidth),
                                _buildButton("⌫", screenWidth),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Fingerprint hint
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint,
                                color: const Color(0xFF00BCD4).withOpacity(0.5),
                                size: screenWidth * 0.05,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Touch ID / Face ID",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: screenWidth * 0.025,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildButton(String num, double screenWidth) {
    return GestureDetector(
      onTap: () {
        if (num == "⌫") {
          if (_pinController.text.isNotEmpty) {
            _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
          }
        } else if (num.isNotEmpty) {
          if (_pinController.text.length < 4) {
            _pinController.text += num;
            if (_pinController.text.length == 4) _unlock();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              color: const Color(0xFF00BCD4),
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
