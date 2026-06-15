import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final double amount;
  final String transactionId;
  final String paymentMethod;
  final DateTime dateTime;

  const PaymentConfirmationScreen({
    super.key,
    required this.amount,
    required this.transactionId,
    required this.paymentMethod,
    required this.dateTime,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final monthStr = months[dt.month - 1];
    final dayStr = dt.day.toString().padLeft(2, '0');
    final yearStr = dt.year.toString();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";
    return "$monthStr $dayStr, $yearStr\n${hour.toString().padLeft(2, '0')}:$minuteStr $period";
  }

  Widget buildSuccessHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(
                begin: .8,
                end: 1.1,
              ).animate(controller),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF474DC5).withOpacity(.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 55,
                color: Color(0xFF474DC5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Payment Successful",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your transaction has been processed successfully.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget receiptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE6E6F0),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Amount Paid",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${widget.amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 34,
              color: Color(0xFF474DC5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 40),
          transactionRow(
            "Transaction ID",
            widget.transactionId,
          ),
          transactionRow(
            "Date & Time",
            _formatDateTime(widget.dateTime),
          ),
          transactionRow(
            "Method",
            widget.paymentMethod,
          ),
        ],
      ),
    );
  }

  Widget transactionRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget merchantBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            "https://images.unsplash.com/photo-1512436991641-6745cdb1723f",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black54,
            ],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Trusted Merchant",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            Text(
              "Eco-Restore Initiative",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff474DC5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              "Back To Home",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff474DC5),
              side: const BorderSide(color: Color(0xff474DC5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Receipt download started..."),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(
              Icons.download,
            ),
            label: const Text(
              "Download Receipt",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget securityFooter() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            size: 18,
            color: Color(0xFF474DC5),
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              "Secured by Lavender Payment Gateway",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        title: const Text(
          "Receipt",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF474DC5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildSuccessHeader(),
            const SizedBox(height: 30),
            receiptCard(),
            const SizedBox(height: 24),
            merchantBanner(),
            const SizedBox(height: 24),
            actionButtons(),
            const SizedBox(height: 24),
            securityFooter(),
          ],
        ),
      ),
    );
  }
}
