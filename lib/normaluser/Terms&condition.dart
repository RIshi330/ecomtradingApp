import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F8).withOpacity(0.8),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Color(0xFF006565),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF006565)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Updated Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E6E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Last Updated: October 24, 2023',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF576867),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Subtitle Paragraph
                  const Text(
                    'Please read these terms carefully before using ShopEase. By accessing our platform, you agree to be bound by these legal obligations.',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Color(0xFF3E4949),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Section 1: Introduction
                  const TermsSection(
                    icon: Icons.info_outline,
                    title: 'Introduction',
                    content:
                    'Welcome to ShopEase. These Terms and Conditions govern your use of our website and mobile application. ShopEase provides a digital marketplace for premium goods. By creating an account or making a purchase, you confirm your acceptance of these terms in their entirety. If you do not agree, please refrain from using our services.',
                  ),
                  const SizedBox(height: 24),

                  // Section 2: User Obligations
                  const UserObligationsSection(),
                  const SizedBox(height: 24),

                  // Visual Break / Decorative Image Card
                  Container(
                    height: 192,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCNBzWlQgSLnUhZ_5c64afM7cA4sEc5JEg1bIzU4F9JRs_HsAeB5Px7OPBy5J5h1D9GD6SgNvVFpsE_F4NPYSOI_yHEXXJQNNefg8tH8bTUAUBm0oRrzwpp38BJOavkBx5WcZ0MX3IiXh4l6imxReRg1Nmo2AWZgGkxgxPxJnFihTMNzEqH9__y-icUFURZpnXBxTeLOwMkOm2ozpBVh8THu_YlTBu3Vxgxg-esWLANTysGbDbs8ldnMdQm5GLoMobNUBXUcClzUxo',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.bottomLeft,
                      child: const Text(
                        'Building a secure commerce ecosystem together.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 3: Intellectual Property
                  const IntellectualPropertySection(),
                  const SizedBox(height: 24),

                  // Section 4: Limitation of Liability
                  const TermsSection(
                    icon: Icons.gavel_outlined,
                    title: 'Limitation of Liability',
                    content:
                    'To the maximum extent permitted by law, ShopEase shall not be liable for any indirect, incidental, special, or consequential damages resulting from your use or inability to use the platform. We provide our services on an "as is" and "as available" basis without any warranties of any kind.',
                  ),
                  const SizedBox(height: 24),

                  // Section 5: Governing Law
                  const TermsSection(
                    icon: Icons.public_outlined,
                    title: 'Governing Law',
                    content:
                    'These terms are governed by and construed in accordance with the laws of the State of Delaware, without regard to its conflict of law principles. Any disputes arising from these terms shall be subject to the exclusive jurisdiction of the state and federal courts located within that jurisdiction.',
                  ),
                  const SizedBox(height: 32),

                  // Contact CTA Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E6E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Have Questions?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF576867),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Our support team is available 24/7 to help clarify any part of these terms.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF576867),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Contact Support',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: const Color(0xFFF0EDED),
              child: Column(
                children: [
                  const Text(
                    '© 2023 SHOP-EASE INC.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF6E7979),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF006565),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Cookie Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF006565),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Generic Terms Section Container
class TermsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const TermsSection({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF006565).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF006565)),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF3E4949),
            ),
          ),
        ),
      ],
    );
  }
}

// Specialized Section: User Obligations with Numbered List
class UserObligationsSection extends StatelessWidget {
  const UserObligationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF006565).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_user_outlined,
                  color: Color(0xFF006565)),
            ),
            const SizedBox(width: 12),
            const Text(
              'User Obligations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: const [
              _ObligationRow(
                number: '01.',
                text:
                'You must be at least 18 years of age to create an account and conduct transactions independently.',
              ),
              SizedBox(height: 16),
              _ObligationRow(
                number: '02.',
                text:
                'You are responsible for maintaining the confidentiality of your account credentials and all activities under your profile.',
              ),
              SizedBox(height: 16),
              _ObligationRow(
                number: '03.',
                text:
                'Users agree not to use the platform for any fraudulent or illegal purposes, including unauthorized data scraping.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ObligationRow extends StatelessWidget {
  final String number;
  final String text;

  const _ObligationRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006565),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF3E4949),
            ),
          ),
        ),
      ],
    );
  }
}

// Specialized Section: Intellectual Property with Callout Quote
class IntellectualPropertySection extends StatelessWidget {
  const IntellectualPropertySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF006565).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.copyright_outlined,
                  color: Color(0xFF006565)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Intellectual Property',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All content on the ShopEase platform, including text, graphics, logos, and software, is the property of Serene Commerce Inc. or its content suppliers and is protected by international copyright laws.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF3E4949),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EDED),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border(
                    left: BorderSide(color: Color(0xFF006565), width: 4),
                  ),
                ),
                child: const Text(
                  '"ShopEase" and the ShopEase logo are registered trademarks. Any unauthorized use of these marks is strictly prohibited.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF3E4949),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}