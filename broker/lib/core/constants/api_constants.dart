class ApiConstants {
  static const String baseUrl = 'https://api.demo.paysft.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Broker auth endpoints
  static const String brokerSignup = '/auth/broker/signup';
  static const String brokerLogin = '/auth/broker/login';
  // Passwordless mobile login: request an SMS code, then verify it.
  static const String brokerLoginOtpRequest = '/auth/broker/login/otp/request';
  static const String brokerLoginOtpVerify = '/auth/broker/login/otp/verify';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  // Broker signup sends BOTH an email OTP and an SMS OTP; verify-contact
  // confirms both together, resend-otp re-sends both.
  static const String brokerVerifyContact = '/auth/broker/verify-contact';
  static const String brokerResendOtp = '/auth/broker/resend-otp';
  static const String passwordResetRequest = '/auth/password-reset/request';
  static const String passwordResetConfirm = '/auth/password-reset/confirm';

  // Broker KYC endpoints (authenticated)
  static const String brokers = '/brokers';
  static const String brokersMe = '/brokers/me';
  static const String brokersMeDocuments = '/brokers/me/documents';
  static const String brokersMeSubmit = '/brokers/me/submit';

  // Broker dashboard data (authenticated)
  static const String brokersMeAssignments = '/brokers/me/assignments';

  static String brokerAssignment(String assignmentId) =>
      '/brokers/me/assignments/$assignmentId';
  static const String brokersMeLeads = '/brokers/me/leads';
  static const String brokersMeClients = '/brokers/me/clients';
  static const String brokersMeProjects = '/brokers/me/projects';

  static String brokerLeadAccept(String leadId) =>
      '/brokers/me/leads/$leadId/accept';
  static String brokerLeadReject(String leadId) =>
      '/brokers/me/leads/$leadId/reject';
  static String brokerLeadVisits(String leadId) =>
      '/brokers/me/leads/$leadId/visits';

  // Broker site visits (schedule)
  static const String brokersMeVisits = '/brokers/me/visits';
  static String brokerVisit(String visitId) => '/brokers/me/visits/$visitId';
  static String brokerVisitCancel(String visitId) =>
      '/brokers/me/visits/$visitId/cancel';

  static String brokerProject(String projectId) =>
      '/brokers/me/projects/$projectId';
  static String brokerProjectUnits(String projectId) =>
      '/brokers/me/projects/$projectId/units';
  static String brokerProjectMedia(String projectId) =>
      '/brokers/me/projects/$projectId/media';
}
