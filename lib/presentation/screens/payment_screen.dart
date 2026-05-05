import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/utils/bilingual_helper.dart';

enum PaymentMethod { card, googlePay }

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const PaymentScreen({super.key, required this.eventData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.card;
  bool _isConfirming = false;
  bool _bookingConfirmed = false;

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    if (_isConfirming) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save your booking.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    if (_selectedMethod == PaymentMethod.card && !_isCardFormComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid card credentials.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isConfirming = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      await _saveBooking(user.uid);
    } catch (e) {
      debugPrint('Booking save failed: $e');
      if (!mounted) return;
      setState(() => _isConfirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isConfirming = false;
      _bookingConfirmed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking confirmed'),
        backgroundColor: Colors.green,
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _saveBooking(String userId) async {
    final eventId =
        (widget.eventData['id'] ?? widget.eventData['Event_Id'] ?? '')
            .toString()
            .trim();
    final resolvedTitle = BilingualHelper.getText(
      widget.eventData['Title'],
      context,
    );
    final title = resolvedTitle.isNotEmpty ? resolvedTitle : 'Event';
    final bookingKey = _safeBookingKey(eventId.isNotEmpty ? eventId : title);
    final bookingId = '${userId}_$bookingKey';

    await FirebaseFirestore.instance
        .collection('User_Bookings')
        .doc(bookingId)
        .set({
          'User_Id': userId,
          'id': eventId,
          'Title': widget.eventData['Title'] ?? title,
          'Category': widget.eventData['Category'],
          'Image_Url':
              widget.eventData['Image_Url'] ?? widget.eventData['Image'],
          'Location_Address':
              widget.eventData['Location_Address'] ??
              widget.eventData['Location_Name'],
          'Price': widget.eventData['Price'] ?? widget.eventData['price'],
          'Schedule': widget.eventData['Schedule'],
          'Payment_Method': _selectedMethod == PaymentMethod.card
              ? 'Credit Card'
              : 'Google Pay',
          'Status': 'Confirmed',
          'Booked_At': Timestamp.now(),
        }, SetOptions(merge: true));
  }

  String _safeBookingKey(String value) {
    final cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (cleaned.isNotEmpty) return cleaned;
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool _isCardFormComplete() {
    final cardNumber = _cardNumberController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final expiry = _expiryController.text.trim();
    final cvc = _cvcController.text.trim();

    return _cardHolderController.text.trim().isNotEmpty &&
        cardNumber.length >= 13 &&
        RegExp(r'^\d{2}\s*/\s*\d{2}$').hasMatch(expiry) &&
        RegExp(r'^\d{3,4}$').hasMatch(cvc);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = BilingualHelper.getText(
      widget.eventData['Title'],
      context,
    );
    final eventTitle = resolvedTitle.isNotEmpty ? resolvedTitle : 'Event';
    final rawPrice = BilingualHelper.getText(
      widget.eventData['Price'] ?? widget.eventData['price'],
      context,
    );
    final eventPrice = rawPrice.trim().isNotEmpty ? '$rawPrice SAR' : '150 SAR';

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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _bookingConfirmed
            ? _buildConfirmationState(eventTitle)
            : _buildBookingForm(eventTitle, eventPrice),
      ),
    );
  }

  Widget _buildBookingForm(String eventTitle, String eventPrice) {
    return SingleChildScrollView(
      key: const ValueKey('booking-form'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: $eventPrice',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodTile(
              method: PaymentMethod.card,
              icon: Icons.credit_card,
              title: 'Credit Card',
              subtitle: 'Enter your card credentials',
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              method: PaymentMethod.googlePay,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Google Pay',
              subtitle: 'Confirm using Google Pay',
            ),
            const SizedBox(height: 24),
            if (_selectedMethod == PaymentMethod.card) ...[
              const Text(
                'Card Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 16),
              _buildCredentialField(
                controller: _cardHolderController,
                label: 'Name on Card',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 12),
              _buildCredentialField(
                controller: _cardNumberController,
                label: 'Card Number',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCredentialField(
                      controller: _expiryController,
                      label: 'MM / YY',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 /]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCredentialField(
                      controller: _cvcController,
                      label: 'CVC',
                      icon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Google Pay selected. Press confirm to complete your booking.',
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isConfirming ? null : _confirmBooking,
                icon: _isConfirming
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.white,
                      ),
                label: Text(
                  _isConfirming ? 'Confirming...' : 'Confirm Booking',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _selectedMethod == method;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.iconGrey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.iconGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationState(String eventTitle) {
    return Center(
      key: const ValueKey('booking-confirmed'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 84),
            const SizedBox(height: 20),
            const Text(
              'Booking confirmed',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              eventTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Returning to your event...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
