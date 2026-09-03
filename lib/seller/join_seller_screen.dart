import 'package:flutter/material.dart';

import 'Seller_profile_completion_screen.dart';
import 'otp_screen.dart';

// --- Theme & Color Palette ---
class AppColors {
  static const Color primary = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color secondaryContainer = Color(0xFFD4E6E5);
  static const Color onSecondaryContainer = Color(0xFF576867);
  static const Color onSurface = Color(0xFF1C1B1B);
  static const Color onSurfaceVariant = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
}

class SellOnLuxeScreen extends StatefulWidget {
  const SellOnLuxeScreen({super.key});

  @override
  State<SellOnLuxeScreen> createState() => _SellOnLuxeScreenState();
}

class _SellOnLuxeScreenState extends State<SellOnLuxeScreen> {
  int _selectedBottomNavIndex = 2; // Default to 'Join' tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Seller',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _WhyPartnerSection(),
            _OnboardingSection(),
            _FinalCtaSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// --- 1. Hero Section ---
class _HeroSection extends StatelessWidget {
  const _HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'LUXE PARTNER PROGRAM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSecondaryContainer,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                height: 1.2,
              ),
              children: [
                TextSpan(text: 'Start Selling on '),
                TextSpan(
                  text: 'Luxe',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unlock global markets with a premium, high-conversion platform designed for sophisticated brands and elite artisans.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SellerSignUpOtpScreen(),));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Join as Seller',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Demo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const SizedBox(
                width: 72,
                height: 32,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80'),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80'),
                      ),
                    ),
                    Positioned(
                      left: 40,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=100&q=80'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                    children: [
                      TextSpan(text: 'Trusted by '),
                      TextSpan(text: '5,000+', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' global luxury brands'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 2. Why Partner Section ---
class _WhyPartnerSection extends StatelessWidget {
  const _WhyPartnerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Partner with Serene?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We provide the tools and reach you need to scale your business while maintaining the premium feel of your brand.',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Card 1: Global Reach
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public, color: Colors.white, size: 36),
                const SizedBox(height: 16),
                const Text(
                  'Global Reach',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap into an exclusive audience of over 2 million premium shoppers across 120 countries.',
                  style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Europe', 'Asia', 'North America'].map((region) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        region,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Low Commission
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.payments, color: AppColors.primary, size: 36),
                SizedBox(height: 16),
                Text(
                  'Low Commission',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                SizedBox(height: 8),
                Text(
                  'Enjoy a flat 5% commission rate—one of the lowest in the luxury commerce sector.',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4),
                ),
                Divider(height: 32),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('No hidden fees', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('Weekly payouts', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 3: 24/7 Support
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.support_agent, color: AppColors.primary, size: 36),
                SizedBox(height: 16),
                Text(
                  '24/7 Support',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                SizedBox(height: 8),
                Text(
                  'Dedicated account managers available around the clock to assist with logistics, technical setup, and marketing.',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Onboarding Section ---
class _OnboardingSection extends StatelessWidget {
  const _OnboardingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'num': '1', 'title': 'Apply', 'desc': 'Submit your brand profile for verification by our curators.'},
      {'num': '2', 'title': 'Configure', 'desc': 'Upload your catalog and set your shipping preferences.'},
      {'num': '3', 'title': 'Launch', 'desc': 'Your storefront goes live to our global audience.'},
      {'num': 'icon', 'title': 'Scale', 'desc': 'Receive orders and grow with our marketing support.'},
    ];

    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          const Text(
            'Simple Onboarding',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            'Launch your store in as little as 48 hours.',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final step = steps[index];
              final isLast = step['num'] == 'icon';
              return Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isLast
                          ? const Icon(Icons.trending_up, color: Colors.white)
                          : Text(
                        step['num']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step['title']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['desc']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- 4. Final CTA Section ---
class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            const Text(
              'Ready to elevate your business to the next level?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Join the world\'s most curated marketplace and reach customers who value quality above all else.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SereneCommerceApp()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Join as Seller',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No credit card required to apply.',
              style: TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 5. Footer Section ---
class _FooterSection extends StatelessWidget {
  const _FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Serene Commerce',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          SizedBox(height: 8),
          Text(
            'The premium choice for sellers who demand more from their commerce partner.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          Divider(height: 32),
          Text(
            '© 2024 Serene Commerce Inc. All rights reserved.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}