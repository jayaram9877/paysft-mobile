import 'package:flutter/material.dart';
import '../../core/utils/input_validator.dart';

class PayTokenProvider extends ChangeNotifier {
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Form keys for validation
  GlobalKey<FormState>? _personalDetailsFormKey;
  GlobalKey<FormState>? _nomineeDetailsFormKey;
  GlobalKey<FormState>? _bankDetailsFormKey;
  GlobalKey<FormState>? _reviewFormKey;

  // Personal Details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Nominee Details
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController nomineeRelationController = TextEditingController();
  final TextEditingController nomineePhoneController = TextEditingController();
  final TextEditingController nomineeEmailController = TextEditingController();

  // Bank Details
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController branchController = TextEditingController();

  // Review Terms
  bool _agreedToTerms = false;
  bool _authorizedAccount = false;
  bool _acknowledgedRera = false;

  bool get agreedToTerms => _agreedToTerms;
  bool get authorizedAccount => _authorizedAccount;
  bool get acknowledgedRera => _acknowledgedRera;

  PayTokenProvider() {
    // Personal details listeners
    nameController.addListener(_onFormChanged);
    emailController.addListener(_onFormChanged);
    panController.addListener(_onFormChanged);
    aadhaarController.addListener(_onFormChanged);
    addressController.addListener(_onFormChanged);

    // Nominee details listeners
    nomineeNameController.addListener(_onFormChanged);
    nomineeRelationController.addListener(_onFormChanged);
    nomineePhoneController.addListener(_onFormChanged);

    // Bank details listeners
    bankNameController.addListener(_onFormChanged);
    accountNumberController.addListener(_onFormChanged);
    confirmAccountNumberController.addListener(_onFormChanged);
    ifscController.addListener(_onFormChanged);
    branchController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setPersonalDetailsFormKey(GlobalKey<FormState> formKey) {
    _personalDetailsFormKey = formKey;
  }

  void setNomineeDetailsFormKey(GlobalKey<FormState> formKey) {
    _nomineeDetailsFormKey = formKey;
  }

  void setBankDetailsFormKey(GlobalKey<FormState> formKey) {
    _bankDetailsFormKey = formKey;
  }

  void setReviewFormKey(GlobalKey<FormState> formKey) {
    _reviewFormKey = formKey;
  }

  bool validatePersonalDetailsStep() {
    if (_currentStep == 0 && _personalDetailsFormKey?.currentState != null) {
      return _personalDetailsFormKey!.currentState!.validate();
    }
    return true;
  }

  bool validateNomineeDetailsStep() {
    if (_currentStep == 1 && _nomineeDetailsFormKey?.currentState != null) {
      return _nomineeDetailsFormKey!.currentState!.validate();
    }
    return true;
  }

  bool validateBankDetailsStep() {
    if (_currentStep == 2 && _bankDetailsFormKey?.currentState != null) {
      return _bankDetailsFormKey!.currentState!.validate();
    }
    return true;
  }

  bool validateReviewStep() {
    if (_currentStep == 3 && _reviewFormKey?.currentState != null) {
      return _reviewFormKey!.currentState!.validate();
    }
    return true;
  }

  /// Check if all mandatory fields in Personal Details step are valid (without showing errors)
  bool isPersonalDetailsStepValid() {
    // Check Name
    if (InputValidator.validateRequired(nameController.text, 'Full Name') != null) {
      return false;
    }
    
    // Check Email
    if (InputValidator.validateEmail(emailController.text) != null) {
      return false;
    }
    
    // Check PAN
    if (InputValidator.validatePAN(panController.text) != null) {
      return false;
    }
    
    // Check Aadhaar
    if (InputValidator.validateAadhaar(aadhaarController.text) != null) {
      return false;
    }
    
    // Check Address
    if (InputValidator.validateAddress(addressController.text) != null) {
      return false;
    }
    
    return true;
  }

  bool isNomineeDetailsStepValid() {
    if (InputValidator.validateRequired(nomineeNameController.text, 'Nominee Full Name') != null) {
      return false;
    }
    if (InputValidator.validateRequired(nomineeRelationController.text, 'Relationship with Nominee') != null) {
      return false;
    }
    if (InputValidator.validatePhoneNumber(nomineePhoneController.text) != null) {
      return false;
    }
    return true;
  }

  bool isBankDetailsStepValid() {
    if (InputValidator.validateRequired(bankNameController.text, 'Bank Name') != null) {
      return false;
    }
    if (InputValidator.validateRequired(accountNumberController.text, 'Account Number') != null) {
      return false;
    }
    if (InputValidator.validateRequired(confirmAccountNumberController.text, 'Confirm Account Number') != null) {
      return false;
    }
    if (InputValidator.validateRequired(ifscController.text, 'IFSC Code') != null) {
      return false;
    }
    if (InputValidator.validateRequired(branchController.text, 'Branch Name') != null) {
      return false;
    }
    if (accountNumberController.text != confirmAccountNumberController.text) {
      return false;
    }
    return true;
  }

  bool isReviewStepValid() {
    return agreedToTerms && authorizedAccount && acknowledgedRera;
  }

  void nextStep() {
    // Validate current step before proceeding
    if (_currentStep == 0) {
      if (!validatePersonalDetailsStep()) {
        return; // Don't proceed if validation fails
      }
    } else if (_currentStep == 1) {
      if (!validateNomineeDetailsStep()) {
        return;
      }
    } else if (_currentStep == 2) {
      if (!validateBankDetailsStep()) {
        return;
      }
    } else if (_currentStep == 3) {
      if (!validateReviewStep() || !isReviewStepValid()) {
        return;
      }
    }

    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep(BuildContext context) {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    } else {
      Navigator.pop(context);
    }
  }

  // Setters for checkboxes
  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  void setAuthorizedAccount(bool value) {
    _authorizedAccount = value;
    notifyListeners();
  }

  void setAcknowledgedRera(bool value) {
    _acknowledgedRera = value;
    notifyListeners();
  }

  // Validation Logic (placeholder for now)
  bool validatePersonalDetails() {
    // Add specific validation logic here
    return true;
  }

  bool validateNomineeDetails() {
    // Add specific validation logic here
    return true;
  }

  bool validateBankDetails() {
    // Add specific validation logic here
    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    panController.dispose();
    aadhaarController.dispose();
    addressController.dispose();

    nomineeNameController.dispose();
    nomineeRelationController.dispose();
    nomineePhoneController.dispose();
    nomineeEmailController.dispose();

    bankNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();
    branchController.dispose();
    super.dispose();
  }
}
