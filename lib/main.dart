import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const InstaNewMsgApp());
}

class InstaNewMsgApp extends StatelessWidget {
  const InstaNewMsgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsAppNewMsg',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF25D366),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  String _selectedCountryCode = '91';
  List<String> _recentNumbers = [];
  bool _isLoading = false;
  
  // Animations
  late AnimationController _bgAnimController;
  late AnimationController _fadeAnimController;
  late Animation<double> _fadeAnim;

  // Country codes list
  final List<Map<String, String>> _countryCodes = [
    {'code': '91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '971', 'name': 'UAE', 'flag': '🇦🇪'},
    {'code': '966', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': '65', 'name': 'Singapore', 'flag': '🇸🇬'},
    {'code': '61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': '49', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': '33', 'name': 'France', 'flag': '🇫🇷'},
    {'code': '81', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': '86', 'name': 'China', 'flag': '🇨🇳'},
    {'code': '55', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': '27', 'name': 'South Africa', 'flag': '🇿🇦'},
    {'code': '234', 'name': 'Nigeria', 'flag': '🇳🇬'},
    {'code': '254', 'name': 'Kenya', 'flag': '🇰🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentNumbers();
    
    // Background Animation
    _bgAnimController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Fade In Animation
    _fadeAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeAnimController,
      curve: Curves.easeOutQuart,
    );
    _fadeAnimController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _bgAnimController.dispose();
    _fadeAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('recent_numbers');
    if (stored != null) {
      setState(() {
        _recentNumbers = List<String>.from(json.decode(stored));
      });
    }
  }

  Future<void> _saveRecentNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    _recentNumbers.remove(number);
    _recentNumbers.insert(0, number);
    if (_recentNumbers.length > 5) {
      _recentNumbers = _recentNumbers.sublist(0, 5);
    }
    await prefs.setString('recent_numbers', json.encode(_recentNumbers));
    setState(() {});
  }

  Future<void> _clearRecentNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_numbers');
    setState(() {
      _recentNumbers = [];
    });
  }

  Future<void> _openWhatsApp() async {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      _showSnackBar('Please enter a phone number', isError: true);
      return;
    }
    
    if (phone.length < 5) {
      _showSnackBar('Please enter a valid phone number', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final fullNumber = '$_selectedCountryCode$phone';
    await _saveRecentNumber(fullNumber);

    final message = _messageController.text.trim();
    final encodedMessage = Uri.encodeComponent(message);
    
    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=$fullNumber'
        '${message.isNotEmpty ? '&text=$encodedMessage' : ''}'
        '&type=phone_number&app_absent=0';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open WhatsApp', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _useRecentNumber(String fullNumber) {
    for (final country in _countryCodes) {
      if (fullNumber.startsWith(country['code']!)) {
        setState(() {
          _selectedCountryCode = country['code']!;
          _phoneController.text = fullNumber.substring(country['code']!.length);
        });
        return;
      }
    }
    _phoneController.text = fullNumber;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent.withOpacity(0.8) : const Color(0xFF2D3748),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildPhoneInput(),
                            const SizedBox(height: 20),
                            _buildMessageInput(),
                            const SizedBox(height: 24),
                            _buildSendButton(),
                          ],
                        ),
                      ),
                      if (_recentNumbers.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildRecentSection(),
                      ],
                      const SizedBox(height: 30),
                      Text(
                        'Start a chat without saving the number',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F2027),
                Color.lerp(const Color(0xFF203A43), const Color(0xFF2C5364), _bgAnimController.value)!,
                const Color(0xFF2C5364),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF25D366).withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withOpacity(0.15),
                        blurRadius: 100,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1),
                        blurRadius: 100,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF25D366).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25D366).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Quick Message',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECIPIENT\'S PHONE NUMBER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    dropdownColor: const Color(0xFF1F2937),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.5)),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: _countryCodes.map((country) {
                      return DropdownMenuItem(
                        value: country['code'],
                        child: Text('${country['flag']} +${country['code']}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCountryCode = value!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '000 000 0000',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.paste_rounded, color: Colors.white.withOpacity(0.5), size: 20),
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) {
                          _phoneController.text = data!.text!.replaceAll(RegExp(r'[^0-9]'), '');
                        }
                      },
                      tooltip: 'Paste',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MESSAGE (OPTIONAL)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 3,
            minLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Type your hello...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                onPressed: () => _messageController.clear(),
                tooltip: 'Clear',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _openWhatsApp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Open in WhatsApp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white.withOpacity(0.9)),
                ],
              ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              GestureDetector(
                onTap: _clearRecentNumbers,
                child: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.5), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentNumbers.length,
            separatorBuilder: (c, i) => Divider(color: Colors.white.withOpacity(0.1), height: 20),
            itemBuilder: (context, index) {
              final number = _recentNumbers[index];
              return InkWell(
                onTap: () => _useRecentNumber(number),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '+$number',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.north_west_rounded, color: Colors.white.withOpacity(0.3), size: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
