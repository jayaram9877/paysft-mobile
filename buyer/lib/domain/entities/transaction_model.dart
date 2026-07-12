import 'package:equatable/equatable.dart';

enum TransactionType { all, property, bills }
enum TransactionStatus { completed, failed, pending }
enum PaymentMethod { upi, card, netbanking, wallet }

class TransactionModel extends Equatable {
  final String id;
  final String title;
  final String propertyName;
  final double amount;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String transactionNumber;
  final TransactionType transactionType;
  final String? receiptUrl;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.propertyName,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.date,
    required this.transactionNumber,
    required this.transactionType,
    this.receiptUrl,
  });

  String get formattedAmount {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  String get formattedAmountFull => '₹${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.netbanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.pending:
        return 'Pending';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        propertyName,
        amount,
        status,
        paymentMethod,
        date,
        transactionNumber,
        transactionType,
        receiptUrl,
      ];
}

