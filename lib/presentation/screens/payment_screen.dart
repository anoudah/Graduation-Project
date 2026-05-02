import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/theme.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const PaymentScreen({super.key, required this.eventData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final CardFormEditController controller = CardFormEditController();

  @override
  void initState() {
    super.initState();
    // Initialize Stripe with your publishable key
    // Note: In a real app, get this from environment variables or secure storage
    Stripe.publishableKey = 'pk_test_your_publishable_key_here'; // Replace with actual key
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    try {
      // Step 1: Validate card details (basic check)
      final cardDetails = controller.details;
      if (cardDetails?.number == null || cardDetails!.number!.isEmpty) {
        throw Exception('Please enter valid card details');
      }

      // Step 2: Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Step 3: Simulate payment success (in real app, this would be server-side)
      // For demo purposes, always succeed
      const isSuccess = true;

      if (isSuccess) {
        // Step 4: Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Booking confirmed.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to previous screen
        }
      } else {
        throw Exception('Payment declined');
      }
    } catch (e) {
      // Step 5: Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventTitle = widget.eventData['Title'] ?? 'Event';
    final eventPrice = widget.eventData['Price'] != null ? '${widget.eventData['Price']} SAR' : '150 SAR';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(color: AppColors.textMain),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Display event title
            Text(
              eventTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            // Step 2: Display price
            Text(
              'Price: $eventPrice',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            // Step 3: Card input field using CardFormField
            const Text(
              'Card Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            CardFormField(
              controller: controller,
              style: CardFormStyle(
                backgroundColor: AppColors.white,
                borderColor: AppColors.textSecondary,
                borderRadius: 8,
                textColor: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 32),
            // Step 4: Pay Now button
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}