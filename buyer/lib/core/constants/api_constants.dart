class ApiConstants {
  static const String baseUrl = 'https://api.demo.paysft.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // PaySFT demo backend (REST) — buyer auth endpoints.
  // See https://api.demo.paysft.com/docs
  // ---------------------------------------------------------------------------

  /// Register a new buyer. Body: {email, password, full_name, mobile}.
  static const String buyerSignup = '/buyer/auth/signup';

  /// Verify signup contact. Body: {email, email_otp, mobile_otp} -> tokens.
  static const String buyerVerifyContact = '/buyer/auth/verify-contact';

  /// Resend signup OTPs. Body: {email}.
  static const String buyerResendOtp = '/buyer/auth/resend-otp';

  /// Send an OTP for phone login. Body: {"mobile": "+91XXXXXXXXXX"}.
  static const String buyerLoginOtpRequest = '/buyer/auth/login/otp/request';

  /// Verify the OTP and receive tokens. Body: {"mobile": "...", "otp": "..."}.
  static const String buyerLoginOtpVerify = '/buyer/auth/login/otp/verify';

  /// Exchange a refresh token for a new token pair. Body: {"refresh_token": ...}.
  static const String buyerRefresh = '/buyer/auth/refresh';

  /// Invalidate the current session.
  static const String buyerLogout = '/buyer/auth/logout';

  /// Current buyer profile (requires bearer token).
  static const String buyerMe = '/buyer/me';

  // Home / catalog (all require bearer token)
  static const String buyerProjects = '/buyer/projects';
  static const String buyerCities = '/buyer/cities';
  static const String buyerLocations = '/buyer/locations';
  static const String buyerSavedUnits = '/buyer/saved-units';

  /// Buyer interests ("I'm Interested"). GET lists the buyer's leads;
  /// POST {unit_id, notes?} registers interest in a unit (idempotent per unit);
  /// POST /buyer/leads/{id}/cancel withdraws it.
  static const String buyerLeads = '/buyer/leads';

  /// Buyer site visits / meetings (scheduled by the builder/broker). GET lists
  /// them enriched with the project + unit they're for.
  static const String buyerVisits = '/buyer/visits';

  /// Buyer notification feed. GET returns {items: [...]} of server-rendered
  /// notifications (title/body already formatted) with optional deep-link ids
  /// (lead_id / sale_id / project_id) and an embedded offer summary.
  static const String buyerNotifications = '/buyer/notifications';

  /// Buyer unit-sale offers. GET lists offers; GET/POST on /buyer/sales/{id}
  /// support detail, preview, accept, decline, and claim.
  static const String buyerSales = '/buyer/sales';

  static String buyerSale(String saleId) => '$buyerSales/$saleId';

  static String buyerSalePreview(String saleId) => '${buyerSale(saleId)}/preview';

  static String buyerSaleAccept(String saleId) => '${buyerSale(saleId)}/accept';

  static String buyerSaleDecline(String saleId) =>
      '${buyerSale(saleId)}/decline';

  static String buyerSaleClaim(String saleId) => '${buyerSale(saleId)}/claim';

  /// Mobile numbers must match the backend pattern `^\+91[6-9]\d{9}$`.
  static const String mobileCountryCode = '+91';

  // Legacy activity-style routing (kept for the app-version / onboarding calls
  // that target the old backend shape; they 404 gracefully on this backend).
  static const String apiPath = '/api';
  static const String activityQueryKey = 'activity';
  static const String activityLogin = 'Login';
  static const String activityValidateOtp = 'ValidateOtp';
  static const String activityVerifyAppVersion = 'VerifyAppVersion';
  static const String activityGetOnboardingContent = 'GetOnboardingContent';
  static const String activityUpdateFirebaseToken = 'UpdateFirebaseToken';

  // Headers
  static const String moduleUserAuth = 'UserAuthentication';
  static const String moduleBuyer = 'Buyer';
  static const String contentTypeJson = 'application/json';
  static const String moduleHeaderKey = 'Module';
  static const String contentTypeHeaderKey = 'Content-Type';

  /// Bearer auth header (JWT access token returned after OTP verification).
  static const String authorizationHeaderKey = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // Dio `Options.extra` keys (used by interceptors)
  static const String extraKeyModule = 'module';

  static const Map<String, dynamic> jsonHeaders = <String, dynamic>{
    contentTypeHeaderKey: contentTypeJson,
  };

  static const Map<String, dynamic> userAuthenticationHeaders =
      <String, dynamic>{
        contentTypeHeaderKey: contentTypeJson,
        moduleHeaderKey: moduleUserAuth,
      };

  // App IDs
  static const String appIdBuyer = 'BUYER';
}
