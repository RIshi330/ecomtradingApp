import 'package:flutter/material.dart';

// ---------------------------------------------------------------------
// Main widget that shows a loader overlay while fetching data
// ---------------------------------------------------------------------
class SereneLoaderScreen extends StatefulWidget {
  const SereneLoaderScreen({super.key});

  @override
  State<SereneLoaderScreen> createState() => _SereneLoaderScreenState();
}

class _SereneLoaderScreenState extends State<SereneLoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isLoading = true;
  String _statusMessage = 'Loading data...';

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // Simulate fetching data
    _fetchData();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  // Simulates an asynchronous data fetch operation
  Future<void> _fetchData() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 3));

      // Update status messages during fetch
      setState(() {
        _statusMessage = 'Processing data...';
      });

      await Future.delayed(const Duration(seconds: 1));

      // Data fetch complete
      setState(() {
        _isLoading = false;
        _statusMessage = 'Data loaded successfully!';
      });

      // Navigate to the next screen after a brief moment
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => const DashboardScreen()),
        // );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // --------------------------------------------
          // Background content (blurred/grayscale overlay)
          // --------------------------------------------
          const Opacity(
            opacity: 0.3,
            child: IgnorePointer(
              // child: DashboardBackground(),
            ),
          ),

          // --------------------------------------------
          // Loader overlay (centered)
          // --------------------------------------------
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Spinning loader
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RotationTransition(
                          turns: _spinController,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.teal.shade700.withOpacity(0.2),
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.teal.shade700,
                                    width: 3,
                                  ),
                                ),
                                child: const ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 0.5,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.transparent,
                                              width: 3,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.transparent,
                                              width: 3,
                                            ),
                                            left: BorderSide(
                                              color: Colors.transparent,
                                              width: 3,
                                            ),
                                            right: BorderSide(
                                              color: Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.business_center,
                          color: Colors.teal,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status message
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1C),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Please wait while we fetch your data',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3E4949),
                      fontFamily: 'Inter',
                    ),
                  ),

                  if (!_isLoading && _statusMessage.contains('successfully'))
                    const SizedBox(height: 16),
                  if (!_isLoading && _statusMessage.contains('successfully'))
                    const Icon(
                      Icons.check_circle,
                      color: Colors.teal,
                      size: 32,
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
