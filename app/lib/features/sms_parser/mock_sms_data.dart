import 'dart:math';

class MockSmsData {
  static List<Map<String, dynamic>> getMockMessages() {
    final random = Random(42); // Deterministic for dev
    final now = DateTime.now();
    final messages = <Map<String, dynamic>>[];
    
    // Generate ~50 transactions over the last 30 days
    for (int i = 0; i < 50; i++) {
      final daysAgo = random.nextInt(30);
      final hoursAgo = random.nextInt(24);
      final date = now.subtract(Duration(days: daysAgo, hours: hoursAgo));
      
      // Known payees (frequent)
      final isFrequent = random.nextDouble() > 0.4;
      String payee = isFrequent ? 'Coffee House' : 'Fresh Mart';
      double amount = isFrequent ? 450.0 + random.nextInt(50) : 1200.0 + random.nextInt(500);
      
      if (random.nextDouble() > 0.8) {
        payee = 'UnknownVendor_${random.nextInt(1000)}';
        amount = 5000.0 + random.nextInt(10000); // Higher amount for unknown
      }

      final body = "Sent Rs. ${amount.toStringAsFixed(2)} to $payee from UPI.";
      
      messages.add({
        'sender': 'VM-UPIINFO',
        'body': body,
        'date': date,
      });
    }

    // Sort by date descending
    messages.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return messages;
  }
}
