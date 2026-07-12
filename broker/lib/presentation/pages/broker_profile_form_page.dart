import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/indian_states_cities.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/broker_kyc_provider.dart';
import '../widgets/primary_blue_button.dart';
import 'documents_upload_page.dart';

class BrokerProfileFormPage extends StatefulWidget {
  const BrokerProfileFormPage({super.key});

  @override
  State<BrokerProfileFormPage> createState() => _BrokerProfileFormPageState();
}

class _BrokerProfileFormPageState extends State<BrokerProfileFormPage> {
  final _legalName = TextEditingController();
  final _pan = TextEditingController();
  final _reraNumber = TextEditingController();
  final _locality = TextEditingController();
  final _bankAccount = TextEditingController();
  final _bankIfsc = TextEditingController();
  final _bankHolder = TextEditingController();
  final _bankName = TextEditingController();
  String _entityType = 'individual';
  String? _state;
  String? _city;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrokerKycProvider>().clearErrorIfAny();
    });
    for (final c in [
      _legalName,
      _pan,
      _reraNumber,
      _locality,
      _bankAccount,
      _bankIfsc,
      _bankHolder,
      _bankName,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _legalName.dispose();
    _pan.dispose();
    _reraNumber.dispose();
    _locality.dispose();
    _bankAccount.dispose();
    _bankIfsc.dispose();
    _bankHolder.dispose();
    _bankName.dispose();
    super.dispose();
  }

  // Every field is mandatory before the user can continue.
  bool get _canSubmit =>
      _legalName.text.trim().isNotEmpty &&
      BrokerKycProvider.isValidPan(_pan.text) &&
      _reraNumber.text.trim().isNotEmpty &&
      _state != null &&
      _city != null &&
      _locality.text.trim().isNotEmpty;

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_canSubmit) return;
    final kyc = context.read<BrokerKycProvider>();
    final address = '${_locality.text.trim()}, $_city, $_state';
    final ok = kyc.saveProfileDraft(
      legalName: _legalName.text,
      entityType: _entityType,
      pan: _pan.text,
      registeredAddress: address,
      reraAgentNumber: _reraNumber.text,
      reraAgentState: _state,
      bankAccountNumber: _bankAccount.text,
      bankIfsc: _bankIfsc.text,
      bankAccountHolderName: _bankHolder.text,
      bankName: _bankName.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DocumentsUploadPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(kyc.errorMessage ?? 'Could not save profile')),
      );
    }
  }

  Future<void> _pickFromList(String title, List<String> options,
      String? current, ValueChanged<String> onPick) async {
    if (options.isEmpty) return;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.backgroundWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: options.length,
                itemBuilder: (ctx, i) {
                  final o = options[i];
                  final selected = o == current;
                  return ListTile(
                    title: Text(o),
                    trailing: selected
                        ? const Icon(Icons.check, color: AppColors.primaryBlue)
                        : null,
                    shape: selected
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.primaryBlue),
                          )
                        : null,
                    onTap: () => Navigator.pop(ctx, o),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimaryDark,
        automaticallyImplyLeading: false,
        title: Text('Profile Details', style: theme.titleStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('Your details'),
            const SizedBox(height: 14),
            _label('Legal Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _legalName,
              textCapitalization: TextCapitalization.words,
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, 'As per your PAN'),
            ),
            const SizedBox(height: 18),
            _label('Entity Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                _entityChip('individual', 'Individual', theme),
                const SizedBox(width: 12),
                _entityChip('firm', 'Firm', theme),
              ],
            ),
            const SizedBox(height: 18),
            _label('PAN'),
            const SizedBox(height: 8),
            TextField(
              controller: _pan,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(10),
                _UpperCaseFormatter(),
              ],
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, 'ABCDE1234F'),
            ),
            const SizedBox(height: 18),
            _label('RERA Agent Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _reraNumber,
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, 'e.g. A0123456789'),
            ),
            const SizedBox(height: 28),

            _section('Locality details'),
            const SizedBox(height: 14),
            _label('State'),
            const SizedBox(height: 8),
            _dropdownField(
              theme,
              value: _state,
              hint: 'Select State',
              onTap: () => _pickFromList(
                'Select State',
                IndianStatesCities.allStates,
                _state,
                (v) => setState(() {
                  _state = v;
                  _city = null; // reset city when state changes
                }),
              ),
            ),
            const SizedBox(height: 18),
            _label('City'),
            const SizedBox(height: 8),
            _dropdownField(
              theme,
              value: _city,
              hint: _state == null ? 'Select a state first' : 'Select City',
              enabled: _state != null,
              onTap: () => _pickFromList(
                'Select City',
                _state == null
                    ? const []
                    : IndianStatesCities.getCitiesForState(_state!),
                _city,
                (v) => setState(() => _city = v),
              ),
            ),
            const SizedBox(height: 18),
            _label('Locality'),
            const SizedBox(height: 8),
            TextField(
              controller: _locality,
              textCapitalization: TextCapitalization.words,
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, 'Area / street / building'),
            ),
            const SizedBox(height: 28),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _section('Bank details'),
                const SizedBox(width: 8),
                Text(
                  '(optional)',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Account Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _bankAccount,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(18),
              ],
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, '9–18 digit account number'),
            ),
            const SizedBox(height: 18),
            _label('IFSC'),
            const SizedBox(height: 8),
            TextField(
              controller: _bankIfsc,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(11),
                _UpperCaseFormatter(),
              ],
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, 'e.g. HDFC0001234'),
            ),
            const SizedBox(height: 18),
            _label('Account Holder Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _bankHolder,
              textCapitalization: TextCapitalization.words,
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, 'As per bank records'),
            ),
            const SizedBox(height: 18),
            _label('Bank Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _bankName,
              textCapitalization: TextCapitalization.words,
              cursorColor: theme.primaryPurple,
              decoration: _dec(theme, 'e.g. HDFC Bank'),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: _canSubmit
                  ? PrimaryGradientButton(text: 'Continue', onTap: _submit)
                  : _disabled(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _disabled() => Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.buttonDisabledBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text('Continue',
            style: TextStyle(
                color: AppColors.buttonDisabledText,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
      );

  Widget _section(String text) => Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _entityChip(String value, String label, ThemeManager theme) {
    final selected = _entityType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _entityType = value),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? theme.primaryPurple.withOpacity(0.08)
                : AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? theme.primaryPurple : AppColors.grey300,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? theme.primaryPurple : AppColors.textPrimaryDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(
    ThemeManager theme, {
    required String? value,
    required String hint,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 15,
                  color: value == null
                      ? AppColors.grey600
                      : AppColors.textPrimaryDark,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_right,
                color: enabled ? AppColors.textTertiary : AppColors.grey300),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(ThemeManager theme, String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey600),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: AppColors.backgroundWhite,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryPurple, width: 2),
        ),
      );
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) =>
      n.copyWith(text: n.text.toUpperCase());
}
