import 'dart:io';
import 'package:flutter/material.dart';


class SereneCommerceApp extends StatelessWidget {
  const SereneCommerceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serene Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFCF9F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006565),
          primary: const Color(0xFF006565),
          surface: const Color(0xFFFCF9F8),
        ),
      ),
      home: const SellerProfileScreen(),
    );
  }
}

// ==========================================
// DATA MODEL
// ==========================================
class SellerProfileModel {
  final String businessName;
  final String regNumber;
  final String businessCategory;
  final String primaryContact;
  final String contactEmail;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;

  SellerProfileModel({
    required this.businessName,
    required this.regNumber,
    required this.businessCategory,
    required this.primaryContact,
    required this.contactEmail,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
  });

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'regNumber': regNumber,
      'businessCategory': businessCategory,
      'primaryContact': primaryContact,
      'contactEmail': contactEmail,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }
}

// ==========================================
// API SERVICE (MOCK / FULLY FUNCTIONAL)
// ==========================================
class SellerProfileService {
  Future<Map<String, dynamic>> completeSellerProfile({
    required SellerProfileModel profile,
    File? verificationDocument,
  }) async {
    // Simulate network latency
    await Future.delayed(const Duration(seconds: 2));

    // Simple backend validation simulation
    if (profile.businessName.isEmpty || profile.contactEmail.isEmpty) {
      return {
        'success': false,
        'message': 'Please fill out all required fields before submitting.',
      };
    }

    return {
      'success': true,
      'message': 'Seller profile created successfully!',
      'data': profile.toJson(),
    };
  }
}

// ==========================================
// SELLER PROFILE SCREEN WIDGET
// ==========================================
class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({Key? key}) : super(key: key);

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  File? _selectedDocument;

  // Form Key & Controllers
  final _formKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _businessNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  String _selectedCategory = 'btc';

  // Step 2 Controllers
  final _primaryContactController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 3 Controllers
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  // Color Tokens
  static const Color primaryColor = Color(0xFF006565);
  static const Color surfaceColor = Color(0xFFFCF9F8);
  static const Color containerLowest = Colors.white;
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color onSurfaceVariant = Color(0xFF3E4949);
  static const Color secondaryContainer = Color(0xFFD4E6E5);

  final List<String> _stepTitles = [
    'Company Details',
    'Contact Information',
    'Address & Verification'
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _regNumberController.dispose();
    _primaryContactController.dispose();
    _contactEmailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    final profileModel = SellerProfileModel(
      businessName: _businessNameController.text.trim(),
      regNumber: _regNumberController.text.trim(),
      businessCategory: _selectedCategory,
      primaryContact: _primaryContactController.text.trim(),
      contactEmail: _contactEmailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zip: _zipController.text.trim(),
    );

    final service = SellerProfileService();
    final response = await service.completeSellerProfile(
      profile: profileModel,
      verificationDocument: _selectedDocument,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Profile completed successfully!'),
          backgroundColor: primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Submission failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primaryColor),
          onPressed: () {},
        ),
        title: const Text(
          'Serene Commerce',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              _buildProgressHeader(),
              const SizedBox(height: 24),
              _buildFormCard(),
              const SizedBox(height: 24),
              _buildAtmosphericCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    double progress = (_currentStep + 1) / 3;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 0${_currentStep + 1} OF 03',
              style: const TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              _stepTitles[_currentStep].toUpperCase(),
              style: const TextStyle(
                color: onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFEAE7E7),
            valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: containerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Seller Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1B1B),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Provide your business details to start selling on Serene Commerce.',
              style: TextStyle(fontSize: 13, color: onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStepView(),
            ),
            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE5E2E1)),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _previousStep,
                    child: const Text(
                      'Back',
                      style: TextStyle(color: primaryColor, fontSize: 16),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    _currentStep == 2 ? 'Complete Profile' : 'Save & Continue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'BUSINESS NAME',
          hint: 'Legal Entity Name',
          controller: _businessNameController,
          validator: (val) => (val == null || val.isEmpty) ? 'Business name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'REGISTRATION NUMBER',
          hint: 'Tax ID / Registration',
          controller: _regNumberController,
          validator: (val) => (val == null || val.isEmpty) ? 'Registration number is required' : null,
        ),
        const SizedBox(height: 20),
        const Text(
          'BUSINESS CATEGORY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCategoryOption(
                type: 'btc',
                title: 'B2C Retail',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryOption(
                type: 'btb',
                title: 'B2B Wholesale',
                icon: Icons.business_center_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryOption({
    required String type,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? secondaryContainer.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1C1B1B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'PRIMARY CONTACT NAME',
          hint: 'Full Name',
          controller: _primaryContactController,
          validator: (val) => (val == null || val.isEmpty) ? 'Contact name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'CONTACT EMAIL',
          hint: 'email@company.com',
          keyboardType: TextInputType.emailAddress,
          controller: _contactEmailController,
          validator: (val) {
            if (val == null || val.isEmpty) return 'Email is required';
            if (!val.contains('@')) return 'Enter a valid email address';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'PHONE NUMBER',
          hint: '+1 (555) 000-0000',
          keyboardType: TextInputType.phone,
          controller: _phoneController,
          validator: (val) => (val == null || val.isEmpty) ? 'Phone number is required' : null,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'HQ STREET ADDRESS',
          hint: '123 Corporate Blvd, Suite 100',
          controller: _addressController,
          validator: (val) => (val == null || val.isEmpty) ? 'Street address is required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                label: 'CITY',
                hint: 'City',
                controller: _cityController,
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                label: 'STATE',
                hint: 'State',
                controller: _stateController,
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                label: 'POSTAL CODE',
                hint: '00000',
                controller: _zipController,
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAtmosphericCards() {
    return Column(
      children: [
        _buildImageCard(
          tag: 'RELIABILITY',
          color: const Color(0xFF006565),
        ),
        const SizedBox(height: 16),
        _buildImageCard(
          tag: 'INNOVATION',
          color: const Color(0xFF008080),
        ),
      ],
    );
  }

  Widget _buildImageCard({required String tag, required Color color}) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}