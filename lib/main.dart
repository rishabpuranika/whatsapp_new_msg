import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      title: 'InstaNewMsg',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF25D366),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  
  String _selectedCountryCode = '91';
  List<String> _recentNumbers = [];
  bool _isLoading = false;
  
  late AnimationController _animController;
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
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _phoneFocusNode.dispose();
    _animController.dispose();
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
      _showSnackBar('Please enter a phone number');
      return;
    }
    
    if (phone.length < 5) {
      _showSnackBar('Please enter a valid phone number');
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
        _showSnackBar('Could not open WhatsApp');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _useRecentNumber(String fullNumber) {
    // Find matching country code
    for (final country in _countryCodes) {
      if (fullNumber.startsWith(country['code']!)) {
        setState(() {
          _selectedCountryCode = country['code']!;
          _phoneController.text = fullNumber.substring(country['code']!.length);
        });
        return;
      }
    }
    // Fallback
    _phoneController.text = fullNumber;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2D3748),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF1A2744),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildCard(),
                  if (_recentNumbers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRecentSection(),
                  ],
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF25D366), Color(0xFF128C7E)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25D366).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'InstaNewMsg',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Send WhatsApp messages without saving contacts',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2744).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone Number Input
          Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Country Code Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    dropdownColor: const Color(0xFF2D3748),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    items: _countryCodes.map((country) {
                      return DropdownMenuItem(
                        value: country['code'],
                        child: Text(
                          '${country['flag']} +${country['code']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCountryCode = value!);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Phone Input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF25D366),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Message Input
          Text(
            'Message (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            maxLines: 3,
            maxLength: 1000,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Type your message here...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF25D366),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            ),
          ),
          const SizedBox(height: 24),
          
          // Send Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _openWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF25D366).withOpacity(0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Open in WhatsApp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2744).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Numbers',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              TextButton(
                onPressed: _clearRecentNumbers,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_recentNumbers.map((number) => _buildRecentItem(number))),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String number) {
    return InkWell(
      onTap: () => _useRecentNumber(number),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              '+$number',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: const Color(0xFF25D366).withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Tap to open WhatsApp and start chatting instantly',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.4),
      ),
    );
  }
}
