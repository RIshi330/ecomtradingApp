import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  int _currentNavIndex = 2; // Offers tab selected
  bool _isCopied = false;
  final String _referralCode = 'EASE-824X-W';

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    setState(() {
      _isCopied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ShopEase',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hero Illustration Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuD1VuIbUyNSfO9ctR8mC6Q4CSIm0npMwCpSGDdwtHUNIkuF7h8zv8DDOKj_i8Too0iin2vyqLJ5jVG6hmIqo0kWDZAeVylVJMvvDoaahv6PMtrgumhyJ0Cb7Q_VCWHqeu8AtBLF8tg_88-l0ToZF-okD2UpYI_HhPPI1ifSGGgbZ6ApQyj60crLyU9vOkuS7u_W4GgsTdsiRX6li_6cCXbJEk-Fs245u8_wZuiIJJrhwqlfHnSK3Ck6Nu75gfXdzRxlbYXq5rfIvPs',
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Share the Love Header
                const Text(
                  'Share the Love',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1B1B),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3E4949),
                        height: 1.5,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        TextSpan(
                            text:
                            'Invite your friends to ShopEase and you both get '),
                        TextSpan(
                          text: '\$20',
                          style: TextStyle(
                            color: Color(0xFF006565),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' when they make their first purchase.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Referral Code Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFBDC9C8).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'YOUR UNIQUE CODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF3E4949),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _referralCode,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006565),
                                letterSpacing: 1.2,
                              ),
                            ),
                            InkWell(
                              onTap: _copyToClipboard,
                              borderRadius: BorderRadius.circular(4),
                              child: Row(
                                children: [
                                  Icon(
                                    _isCopied
                                        ? Icons.check
                                        : Icons.content_copy,
                                    size: 18,
                                    color: const Color(0xFF006565),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isCopied ? 'COPIED' : 'COPY',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF006565),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // How It Works Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1B1B),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Step 1
                const HowItWorksStep(
                  icon: Icons.send,
                  title: '1. Invite Friends',
                  subtitle:
                  'Share your link or code via WhatsApp, Email, or Social Media.',
                  showLine: true,
                ),

                // Step 2
                const HowItWorksStep(
                  icon: Icons.person_add,
                  title: '2. They Sign Up',
                  subtitle:
                  'Your friend signs up and completes their first order of \$50 or more.',
                  showLine: true,
                ),

                // Step 3
                const HowItWorksStep(
                  icon: Icons.card_giftcard,
                  title: '3. You Get Reward',
                  subtitle:
                  'Once the order is confirmed, we\'ll credit \$20 to your ShopEase wallet.',
                  showLine: false,
                ),
                const SizedBox(height: 32),

                // Terms & Conditions Tile
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EDED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.help_outline,
                                color: Color(0xFF3E4949)),
                            SizedBox(width: 12),
                            Text(
                              'Referral Terms & Conditions',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1C1B1B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, color: Color(0xFF3E4949)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom CTA "Share Now"
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF9F8).withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFBDC9C8).withOpacity(0.3),
                  ),
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Share Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Stepper Widget reproducing the step-line connector
class HowItWorksStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showLine;

  const HowItWorksStep({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFD4E6E5),
                child: Icon(icon, size: 20, color: const Color(0xFF006565)),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFD4E6E5),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3E4949),
                      height: 1.4,
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
}