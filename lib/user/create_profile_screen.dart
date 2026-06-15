import 'package:flutter/material.dart';

class CreateProfileScreen extends StatelessWidget {
  final String email;
  final bool isRecruiter;
  final bool mergeRequired;

  const CreateProfileScreen({
    super.key,
    required this.email,
    required this.isRecruiter,
    required this.mergeRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: Center(
        child: Text(
          'Create Profile Screen\nEmail: $email\nRecruiter: $isRecruiter\nMerge Required: $mergeRequired',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
