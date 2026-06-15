import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer,
                borderRadius:
                    BorderRadius.circular(
                        20),
              ),

              child: const Text(
                "Last Updated: October 24, 2023",
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Please read these terms carefully before using ShopEase. By accessing our platform, you agree to be bound by these legal obligations.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 30),

            buildSection(
              icon: Icons.info,
              title: "Introduction",
              content:
                  "Welcome to ShopEase. These Terms and Conditions govern your use of our website and mobile application. ShopEase provides a digital marketplace for premium goods. By creating an account or making a purchase, you confirm your acceptance of these terms in their entirety.",
            ),

            const SizedBox(height: 24),

            buildSection(
              icon: Icons.verified_user,
              title: "User Obligations",
              content:
                  "Users must be at least 18 years old. You are responsible for maintaining account confidentiality and agree not to use the platform for fraudulent or illegal activities.",
            ),

            const SizedBox(height: 24),

            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                        20),
                image:
                    const DecorationImage(
                  image: NetworkImage(
                    "https://picsum.photos/900/500",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            buildSection(
              icon: Icons.payment,
              title:
                  "Payments & Billing",
              content:
                  "All payments must be completed using approved payment methods. ShopEase reserves the right to suspend transactions suspected of fraud or abuse.",
            ),

            const SizedBox(height: 24),

            buildSection(
              icon: Icons.local_shipping,
              title:
                  "Shipping & Delivery",
              content:
                  "Estimated delivery dates are provided for convenience and may vary due to logistics, weather, or operational constraints.",
            ),

            const SizedBox(height: 24),

            buildSection(
              icon: Icons.undo,
              title:
                  "Returns & Refunds",
              content:
                  "Eligible products may be returned according to our return policy. Refund processing times depend on payment providers and banks.",
            ),

            const SizedBox(height: 24),

            buildSection(
              icon: Icons.lock,
              title:
                  "Privacy Policy",
              content:
                  "Your personal information is handled according to our Privacy Policy. We implement reasonable security measures to protect user data.",
            ),

            const SizedBox(height: 24),

            buildSection(
              icon: Icons.gavel,
              title:
                  "Limitation of Liability",
              content:
                  "ShopEase shall not be liable for indirect, incidental, or consequential damages resulting from use of the platform.",
            ),

            const SizedBox(height: 24),

            buildSection(
              icon: Icons.update,
              title:
                  "Changes To Terms",
              content:
                  "We reserve the right to modify these Terms & Conditions at any time. Continued use of the platform constitutes acceptance of the revised terms.",
            ),

            const SizedBox(height: 40),

            SizedBox(
              width:
                  double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(
                      context);
                },
                child: const Text(
                  "I Understand",
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
              16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                16),
        border: Border.all(
          color: AppTheme.outline.withOpacity(0.5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Row(
            children: [

              CircleAvatar(
                backgroundColor: AppTheme.secondaryContainer,
                child: Icon(
                  icon,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(
                  width: 12),

              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
              height: 16),

          Text(
            content,
            style:
                const TextStyle(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
