import 'package:flutter/material.dart';
import '../../domain/entities/transaction_model.dart';

class TransactionsProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  static const List<String> tabs = ['All', 'Property', 'Bills'];

  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  List<TransactionModel> get transactions => _filteredTransactions;

  // Filter states (temporary - for UI selection)
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? get tempStartDate => _tempStartDate;
  DateTime? get tempEndDate => _tempEndDate;
  DateTime? get appliedStartDate => _selectedStartDate;
  DateTime? get appliedEndDate => _selectedEndDate;

  PaymentMethod? _tempPaymentMethod;
  PaymentMethod? _selectedPaymentMethod;
  PaymentMethod? get tempPaymentMethod => _tempPaymentMethod;
  PaymentMethod? get appliedPaymentMethod => _selectedPaymentMethod;

  TransactionStatus? _tempStatus;
  TransactionStatus? _selectedStatus;
  TransactionStatus? get tempStatus => _tempStatus;
  TransactionStatus? get appliedStatus => _selectedStatus;

  String? _tempPropertyName;
  String? _selectedPropertyName;
  String? get tempPropertyName => _tempPropertyName;
  String? get appliedPropertyName => _selectedPropertyName;

  // Get unique property names for filter
  List<String> get availablePropertyNames {
    return _allTransactions.map((t) => t.propertyName).toSet().toList()..sort();
  }

  bool get hasActiveFilters =>
      _selectedStartDate != null ||
      _selectedEndDate != null ||
      _selectedPaymentMethod != null ||
      _selectedStatus != null ||
      _selectedPropertyName != null;

  bool get hasPendingFilters =>
      _tempStartDate != _selectedStartDate ||
      _tempEndDate != _selectedEndDate ||
      _tempPaymentMethod != _selectedPaymentMethod ||
      _tempStatus != _selectedStatus ||
      _tempPropertyName != _selectedPropertyName;

  TransactionsProvider() {
    _initializeTransactions();
    // Initialize temporary filters
    _tempStartDate = _selectedStartDate;
    _tempEndDate = _selectedEndDate;
    _tempPaymentMethod = _selectedPaymentMethod;
    _tempStatus = _selectedStatus;
    _tempPropertyName = _selectedPropertyName;
  }

  void _initializeTransactions() {
    // Mock data - replace with actual API call
    _allTransactions = [
      TransactionModel(
        id: '1',
        title: 'Milestone Payment - Roof Level',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 500000,
        status: TransactionStatus.completed,
        paymentMethod: PaymentMethod.upi,
        date: DateTime(2024, 11, 15),
        transactionNumber: 'TXN123456789',
        transactionType: TransactionType.property,
        receiptUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      TransactionModel(
        id: '2',
        title: 'Maintenance Payment',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 15000,
        status: TransactionStatus.completed,
        paymentMethod: PaymentMethod.card,
        date: DateTime(2024, 11, 10),
        transactionNumber: 'TXN123456790',
        transactionType: TransactionType.property,
        receiptUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      TransactionModel(
        id: '3',
        title: 'Electricity Bill',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 3500,
        status: TransactionStatus.completed,
        paymentMethod: PaymentMethod.upi,
        date: DateTime(2024, 11, 5),
        transactionNumber: 'TXN123456791',
        transactionType: TransactionType.bills,
        receiptUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      TransactionModel(
        id: '4',
        title: 'Water Bill',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 1200,
        status: TransactionStatus.failed,
        paymentMethod: PaymentMethod.netbanking,
        date: DateTime(2024, 11, 1),
        transactionNumber: 'TXN123456792',
        transactionType: TransactionType.bills,
      ),
      TransactionModel(
        id: '5',
        title: 'Milestone Payment - Foundation',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 1000000,
        status: TransactionStatus.completed,
        paymentMethod: PaymentMethod.upi,
        date: DateTime(2024, 10, 25),
        transactionNumber: 'TXN123456793',
        transactionType: TransactionType.property,
        receiptUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      TransactionModel(
        id: '6',
        title: 'Property Tax',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 25000,
        status: TransactionStatus.completed,
        paymentMethod: PaymentMethod.card,
        date: DateTime(2024, 10, 20),
        transactionNumber: 'TXN123456794',
        transactionType: TransactionType.bills,
        receiptUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      TransactionModel(
        id: '7',
        title: 'Milestone Payment - First Floor',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 750000,
        status: TransactionStatus.completed,
        paymentMethod: PaymentMethod.upi,
        date: DateTime(2024, 10, 15),
        transactionNumber: 'TXN123456795',
        transactionType: TransactionType.property,
        receiptUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
      TransactionModel(
        id: '8',
        title: 'Internet Bill',
        propertyName: 'Prestige Lakeside Habitat',
        amount: 999,
        status: TransactionStatus.completed,
        paymentMethod: PaymentMethod.wallet,
        date: DateTime(2024, 10, 10),
        transactionNumber: 'TXN123456796',
        transactionType: TransactionType.bills,
        receiptUrl: 'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
      ),
    ];
    _applyFilters();
  }

  void onTabChanged(int index) {
    _selectedTabIndex = index;
    _applyFilters();
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _tempStartDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _tempEndDate = date;
    notifyListeners();
  }

  void setPaymentMethodFilter(PaymentMethod? method) {
    _tempPaymentMethod = method;
    notifyListeners();
  }

  void setStatusFilter(TransactionStatus? status) {
    _tempStatus = status;
    notifyListeners();
  }

  void setPropertyNameFilter(String? propertyName) {
    _tempPropertyName = propertyName;
    notifyListeners();
  }

  void applyFilters() {
    _selectedStartDate = _tempStartDate;
    _selectedEndDate = _tempEndDate;
    _selectedPaymentMethod = _tempPaymentMethod;
    _selectedStatus = _tempStatus;
    _selectedPropertyName = _tempPropertyName;
    _applyFilters();
    notifyListeners();
  }

  void clearAllFilters() {
    _tempStartDate = null;
    _tempEndDate = null;
    _tempPaymentMethod = null;
    _tempStatus = null;
    _tempPropertyName = null;
    notifyListeners();
  }

  void resetToAppliedFilters() {
    _tempStartDate = _selectedStartDate;
    _tempEndDate = _selectedEndDate;
    _tempPaymentMethod = _selectedPaymentMethod;
    _tempStatus = _selectedStatus;
    _tempPropertyName = _selectedPropertyName;
    notifyListeners();
  }

  void _applyFilters() {
    TransactionType? typeFilter;

    switch (_selectedTabIndex) {
      case 1:
        typeFilter = TransactionType.property;
        break;
      case 2:
        typeFilter = TransactionType.bills;
        break;
      default:
        typeFilter = null;
    }

    _filteredTransactions = _allTransactions.where((transaction) {
      // Tab filter (transaction type)
      bool matchesType = typeFilter == null || transaction.transactionType == typeFilter;

      // Date range filter (use applied filters)
      bool matchesDateRange = true;
      if (_selectedStartDate != null) {
        final startDate = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
        final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        matchesDateRange = matchesDateRange && transactionDate.isAfter(startDate.subtract(const Duration(days: 1)));
      }
      if (_selectedEndDate != null) {
        final endDate = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);
        final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        matchesDateRange = matchesDateRange && transactionDate.isBefore(endDate.add(const Duration(days: 1)));
      }

      // Payment method filter
      bool matchesPaymentMethod = _selectedPaymentMethod == null || transaction.paymentMethod == _selectedPaymentMethod;

      // Status filter
      bool matchesStatus = _selectedStatus == null || transaction.status == _selectedStatus;

      // Property name filter
      bool matchesProperty = _selectedPropertyName == null || transaction.propertyName == _selectedPropertyName;

      return matchesType && matchesDateRange && matchesPaymentMethod && matchesStatus && matchesProperty;
    }).toList();

    // Sort by date (newest first)
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
  }

  double get totalAmountPaid {
    return _filteredTransactions
        .where((t) => t.status == TransactionStatus.completed)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  int get transactionCount => _filteredTransactions.length;

  String get formattedTotalAmount {
    final total = totalAmountPaid;
    return '₹${total.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}

