/// Application string constants
/// All hardcoded strings used throughout the app should be defined here
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App Info
  static const String appName = 'Buyer App';

  // Chat Screen
  static const String chatListTitle = 'Chat';
  static const String chatTypeMessagePlaceholder = 'Type your message here...';
  static const String chatOnline = 'Online';
  static const String chatToday = 'Today';
  static const String chatYesterday = 'Yesterday';

  // Attachment Options
  static const String attachmentPhotoVideo = 'Photo & Video';
  static const String attachmentDocument = 'Document';
  static const String attachmentLocation = 'Location';
  static const String attachmentContact = 'Contact';
  static const String attachmentChooseFromGallery = 'Choose from Gallery';
  static const String attachmentTakePhoto = 'Take a Photo';

  // Messages
  static const String messageDocumentSelectionComingSoon =
      'Document selection coming soon';
  static const String messageLocationSharingComingSoon =
      'Location sharing coming soon';
  static const String messageContactSharingComingSoon =
      'Contact sharing coming soon';
  static const String messageErrorSelectingImage = 'Error selecting image:';
  static const String messageErrorTakingPhoto = 'Error taking photo:';

  // Font Family
  static const String fontFamily = 'SF Pro Display';
  static const String fontFamilyMedium = 'SF Pro Medium';
  static const String fontFamilyText = 'SF Pro Text';

  // Login/Onboarding
  static const String loginOrSignUp = 'Login or sign up';
  static const String loginDescription =
      'Please select your preferred method \nto continue setting up your account';
  static const String continueWithPhone = 'Continue with Phone';
  static const String continueWithEmail = 'Continue with Email';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsApply =
      'If you are creating a new account,\nTerms & Conditions and Privacy Policy will apply';
  static const String emailLoginTitle = 'Login with Email';
  static const String emailLoginSubtitle =
      'Enter your email and password to continue';
  static const String passwordLabel = 'Password';
  static const String loginButton = 'Login';
  static const String signupTitle = 'Create your account';
  static const String signupSubtitle =
      'Fill in your details to get started';
  static const String fullNameLabel = 'Full Name';
  static const String mobileLabel = 'Mobile Number';
  static const String signupButton = 'Sign Up';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUpLink = 'Sign up';
  static const String loginLink = 'Login';
  static const String forgotPassword = 'Forgot password?';
  static const String resetPasswordTitle = 'Reset password';
  static const String resetPasswordRequestSubtitle =
      'Enter your email and we\'ll send you a 6-digit code';
  static const String resetPasswordConfirmSubtitle =
      'Enter the code sent to your email and choose a new password';
  static const String sendCodeButton = 'Send Code';
  static const String newPasswordLabel = 'New Password';
  static const String codeLabel = 'Verification Code';
  static const String resetPasswordButton = 'Reset Password';
  static const String resetPasswordSuccess =
      'Password reset successful. Please log in.';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String finish = 'Finish';

  // Phone Login
  static const String yourPhoneNumber = "Your phone number";
  static const String phoneNumberDescription =
      "It's helpful to provide a good reason for why the phone number is required.";
  static const String back = "Back";
  static const String continueButton = 'Continue';
  static const String mobileNumberError =
      "Mobile number should start with digits 6–9";
  static const String mobileNumberLengthError =
      "Mobile number must be 10 digits";
  static const String validPhoneNumberError =
      "Please enter a valid phone number";

  // OTP
  static const String enterCode = "Enter code";
  static const String otpDescription = "Your temporary login code was sent to:";
  static const String dontReceiveCode = "Don't receive a code? ";
  static const String sendAgain = "Send again";
  static const String otpResent = "OTP resent";
  static const String invalidOtp = "Invalid OTP. Please try again.";

  // Onboarding
  static const String onboardingTitle1 =
      'Find best place to stay in good price';
  static const String onboardingTitle2 =
      'Fast sell your property in just one click';
  static const String onboardingTitle3 = 'Find perfect choice for your future';
  static const String onboardingDescription =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed.';

  // Home Page
  static const String homeLocationLabel = 'Location';
  static const String homeDefaultLocation = 'Hyderabad, Telangana';
  static const String homeSearchHint = 'Search Property';
  static const String homeFeatured = 'Featured';
  static const String homeCategories = 'Categories';
  static const String homeRecommended = 'Recommended';
  static const String homeNearby = 'Nearby';
  static const String homePopularForYou = 'Popular for you';
  static const String homeTopLocations = 'Top Locations';
  static const String homeSeeAll = 'See All';

  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotificationYet = 'No notification yet';
  static const String noNotificationDescription =
      'All notification we send will appear here, so you can view them easly anytime.';
  static const String schedule = 'Schedule';
  static const String notificationsToday = 'Today';
  static const String notificationsYesterday = 'Yesterday';
  static const String showEmptyState = 'Show empty state';
  static const String showNotifications = 'Show notifications';
  static const String clickHereToSeeListing = 'click here to see your listing';

  // Sample notification messages (for development)
  static const String notificationListingActive =
      'Congratulations, your listing is now active. click here to see your listing';
  static const String notificationWelcomeCompleteInfo =
      'Welcome, Don\'t forget to complete your personal info ';
  static const String notificationMessageAnggelaJoni =
      'Anggela and joni send you message, check it now';
  static const String notificationMessageJhonAni =
      'Jhon, ani & 2 other send you message, check it now';

  // Favorites
  static const String favorites = 'Favourites';
  static const String removeFromFavorites = 'Remove from favorites';
  static const String removeFromFavoritesConfirm =
      'Are you sure you want to remove this property from your favorites?';
  static const String cancel = 'Cancel';
  static const String yesRemove = 'Yes, remove';
  static const String categoryAll = 'All';
  static const String categoryHouse = 'House';
  static const String categoryVilla = 'Villa';
  static const String categoryApartment = 'Apartment';
  static const String studioApartment = 'Studio Apartment';
  static const String duplexHomes = 'Duplex Homes';
  static const String penthouse = 'Penthouse';
  static const String noFavoritesTitle1 = 'You don\'t have';
  static const String noFavoritesTitle2 = 'favorites yet';
  static const String propertyTagTrilight = 'The Trilight';

  // Preference Setup
  static const String setYourPreference = 'Set your preference';
  static const String preferenceSubtitle = 'We will tailor the suggestions';
  static const String later = 'Later';
  static const String setUpNow = 'Set up now';
  static const String setYourPreferences = 'Set Your Preferences';
  static const String customizeExperience = 'Customize your experience';
  static const String preferenceSetup = 'Preference Setup';
  static const String preferenceSetupDescription =
      'This screen will contain preference selection options';
  static const String preferencesSavedSuccess =
      'Preferences saved successfully';
  static const String savePreferences = 'Save Preferences';

  // Main Tab Navigation
  static const String tabHome = 'Home';
  static const String tabExplore = 'List';
  static const String tabFavorites = 'Schedule';
  static const String tabChat = 'Chat';
  static const String tabProfile = 'Profile';
  static const String selectLocation = 'Select Location';

  // Property Details
  static const String propertyDetails = 'Property Details';
  static const String propertyNotFound = 'Property not found';
  static const String requestVisit = 'Request Visit';
  static const String overview = 'Overview';
  static const String floorPlans = 'Floor Plans';
  static const String documents = 'Documents';
  static const String areaDetails = 'Area Details';
  static const String propertyInfo = 'Property Info';
  static const String facilities = 'Facilities';
  static const String gallery = 'Gallery';
  static const String seeAll = 'See All';
  static const String openInMaps = 'Open in Maps';

  // Profile
  static const String profile = 'Profile';
  static const String verifiedAccount = 'Verified Account';
  static const String properties = 'Properties';
  static const String totalPaid = 'Total Paid';
  static const String pending = 'Pending';
  static const String propertyManagement = 'Property Management';
  static const String transactions = 'Transactions';
  static const String paymentHistory = 'Payment history';
  static const String utilities = 'Utilities';
  static const String utilitiesDue = 'Due';
  static const String accountSettings = 'Account Settings';
  static const String editProfile = 'Edit Profile';
  static const String securityPrivacy = 'Security & Privacy';
  static const String notificationSettings = 'Notification Settings';
  static const String help = 'Help';
  static const String support = 'Support';
  static const String legal = 'Legal';
  static const String termsConditions = 'Terms & Conditions';
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String about = 'About';
  static const String version = 'Version';
  static const String logout = 'Logout';
  static const String deleteAccount = 'Delete Account';
  static const String documentsSubtitle = 'Agreements, receipts & more';
  static const String transactionsSubtitle = 'Payment history';
  static const String utilitiesSubtitle = 'Pay bills & manage services';
  static const String due = 'Due';
  static const String securityPrivacyTitle = 'Security & Privacy';
  static const String contactSupport = 'Contact Support';
  static const String helpCenter = 'Help Center';
  static const String emailUs = 'Email Us';
  static const String supportEmail = 'support@paysft.com';
  static const String aboutPaySFT = 'About PaySFT';
  static const String versionNumber = 'Version 1.0.0';
  static const String editProfileTitle = 'Edit Profile';
  static const String name = 'Name';
  static const String phone = 'Phone';
  static const String imageUrlOptional = 'Image URL (optional)';
  static const String profileUpdated = 'Profile updated';
  static const String logoutTitle = 'Logout';
  static const String logoutMessage = 'Are you sure you want to logout?';
  static const String deleteAccountTitle = 'Delete Account';
  static const String deleteAccountMessage =
      'Are you sure you want to delete your account? This action cannot be undone.';
  static const String accountDeletedSuccessfully =
      'Account deleted successfully';
  static const String delete = 'Delete';

  // Feature Coming Soon Messages
  static const String documentsComingSoon = 'Documents feature coming soon';
  static const String transactionsComingSoon =
      'Transactions feature coming soon';
  static const String utilitiesComingSoon = 'Utilities feature coming soon';

  // Share Modal
  static const String linkCopiedToClipboard = 'Link copied to clipboard';
  static const String shareClipboard = 'Clipboard';
  static const String shareFacebook = 'Facebook';
  static const String shareInstagram = 'Instagram';
  static const String shareLinkedIn = 'LinkedIn';
  static const String sharePinterest = 'Pinterest';
  static const String shareTelegram = 'Telegram';
  static const String shareDiscord = 'Discord';

  // Featured Properties
  static const String featuredProperties = 'Featured Properties';

  // Search
  static const String search = 'Search';
  static const String searchCity = 'Search city';
  static const String searchHint = 'Home';

  // Contact Details
  static const String call = 'Call';
  static const String message = 'Message';

  // Filter Page
  static const String filters = 'Filters';
  static const String resetFilters = 'Reset Filters';
  static const String lookingFor = 'Looking For';
  static const String residential = 'Residential';
  static const String commercial = 'Commercial';
  static const String category = 'Category';
  static const String priceRange = 'Price Range';
  static const String avgPriceIs20L = 'Avg. Price is 20L';
  static const String price20L = '20L';
  static const String price100Cr = '100 Cr';
  static const String bedRooms = 'Bed Rooms';
  static const String areaSqft = 'Area (Sqft)';
  static const String plotAreaSqft = 'Plot Area (Sqft)';
  static const String apply = 'Apply';
  static const String any = 'Any';
  static const String min = 'Min';
  static const String max = 'Max';

  // Booking Slot Page
  static const String bookingSlot = 'Booking Slot';
  static const String selectDate = 'Select Date';
  static const String date = 'Date';
  static const String dateCheckMessage =
      'Make sure to check your date before making any sort of changes';
  static const String availableTime = 'Available Time';
  static const String morning = 'Morning';
  static const String afternoon = 'Afternoon';
  static const String evening = 'Evening';
  static const String timeCheckMessage =
      'Make sure to check the time before making any sort of changes';
  static const String noteToBroker = 'Note to Broker';
  static const String placeholder = 'Placeholder';
  static const String confirm = 'Confirm';
  static const String pleaseSelectDate = 'Please select a date';
  static const String pleaseSelectTime = 'Please select a time';
  static const String validationError = 'Validation Error';
  static const String ok = 'OK';
  static const String calendar = 'Calendar';
  static const String setDateOnYourCalendar = 'Set date on your calendar';
  static const String save = 'Save';
  static const String bookingSuccessTitle = 'Yey, your booking success';
  static const String bookingSuccessDescription =
      'You have successfully booked a property visit, enjoy your property.';
  static const String bookingDetails = 'Booking Details';
  static const String exploreMore = 'Explore more';

  // Property Details Page
  static const String locationAndPublicFacilities =
      'Location & Public Facilities';

  // Chat Page
  static const String contact = 'Contact';
  static const String location = 'Location';
  static const String document = 'Document';
  static const String locationPermissionRequired =
      'Location Permission Required';
  static const String locationPermissionDeniedMessage =
      'Location permission is permanently denied. Please enable it in app settings.';
  static const String openSettings = 'Open Settings';
  static const String locationSharedSuccessfully =
      'Location shared successfully';
  static const String unableToGetLocation =
      'Unable to get your location. Please try again.';
  static const String unknown = 'Unknown';
  static const String couldNotOpenLink = 'Could not open link';

  // Location Selection Page
  static const String settings = 'Settings';
  static const String detectingLocation = 'Detecting your location...';
  static const String useCurrentLocation = 'Use Current Location';
  static const String startTypingToSearch = 'Start typing to search for a city';
  static const String noResultsFound = 'No results found';

  // Login Page
  static const String exitApp = 'Exit App';
  static const String exitAppMessage = 'Do you want to exit the app?';
  static const String no = 'No';
  static const String yes = 'Yes';
  static const String welcomeToBuyer = 'Welcome to Buyer';
  static const String enterPhoneNumberToContinue =
      'Enter your phone number to continue';
  static const String phoneNumber = 'Phone Number';

  // Search & Explore Pages
  static const String searchNotFound = 'Search not found';
  static const String enableLocationServices =
      'Please enable your location services for more optimal result';

  // Recent Views & Properties in Process
  static const String recentViews = 'Recent Views';
  static const String noRecentViews = 'No recent views';
  static const String propertiesInProcess = 'Properties in Process';
  static const String noPropertiesInProcess = 'No properties in process';

  // Full Screen Media Viewer
  static const String current = 'Current';

  // Web View Page
  static const String openingInBrowser = 'Opening in browser...';
  static const String openInBrowser = 'Open in Browser';
  static const String couldNotOpenUrl = 'Could not open';

  // Security & Privacy Page
  static const String security = 'Security';
  static const String privacy = 'Privacy';
  static const String changePassword = 'Change Password';
  static const String biometricAuthentication = 'Biometric Authentication';
  static const String activeSessions = 'Active Sessions';
  static const String profileVisibility = 'Profile Visibility';
  static const String locationServices = 'Location Services';
  static const String dataUsage = 'Data Usage';
  static const String changePasswordComingSoon =
      'Change password feature coming soon';
  static const String biometricAuthComingSoon =
      'Biometric authentication feature coming soon';
  static const String activeSessionsComingSoon =
      'Active sessions feature coming soon';
  static const String profileVisibilityComingSoon =
      'Profile visibility feature coming soon';
  static const String locationServicesComingSoon =
      'Location services feature coming soon';
  static const String dataUsageComingSoon = 'Data usage feature coming soon';

  // Notification Settings Page
  static const String marketingNotifications = 'Marketing Notifications';
  static const String marketingNotificationsSubtitle =
      'Receive updates about new properties and offers';
  static const String salesNotifications = 'Sales Notifications';
  static const String salesNotificationsSubtitle =
      'Get notified about sales and discounts';
  static const String paymentUpdates = 'Payment Updates';
  static const String paymentUpdatesSubtitle =
      'Receive notifications about payment status';
  static const String propertyUpdates = 'Property Updates';
  static const String propertyUpdatesSubtitle =
      'Get updates about your saved properties';
  static const String newMessages = 'New Messages';
  static const String newMessagesSubtitle =
      'Notifications for new chat messages';
  static const String systemNotifications = 'System Notifications';
  static const String systemNotificationsSubtitle =
      'Important app updates and system messages';

  // Help Page
  static const String chat = 'Chat';
  static const String chatSubtitle = 'Get instant help via chat';
  static const String email = 'Email';
  static const String emailSubtitle = 'support@example.com';
  static const String callSubtitle = '+1 (555) 123-4567';
  static const String openingChat = 'Opening chat...';
  static const String helpRequest = 'Help Request';

  // Gallery Page
  static const String all = 'All';
  static const String videos = 'Videos';
  static const String livingRoom = 'Living Room';
  static const String kitchen = 'Kitchen';
  static const String bedroom = 'Bedroom';
  static const String parking = 'Parking';

  // Contact Details Screen
  static const String contactDetails = 'Contact Details';
  static const String phoneNumbers = 'Phone Numbers';
  static const String emailLabel = 'Email';
  static const String address = 'Address';

  // Chat List Page
  static const String messages = 'Messages';
  static const String noMessages = 'No Messages';
  static const String noActiveChats = 'You have no active chats';
  static const String sortOptions = 'Sort Options';
  static const String unreadFirst = 'Unread First';
  static const String readChatsFirst = 'Read Chats First';
  static const String orderByName = 'Order by Name';
  static const String justNow = 'Just now';
  static const String minutesAgo = 'm ago';
  static const String hoursAgo = 'h ago';
  static const String daysAgo = 'd ago';
  static const String noMessagesYet = 'No messages yet';

  // Widgets
  static const String addedToFavorites = 'Added to Favorites';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength =
      'Password must be at least 6 characters';
  static const String fieldRequired = 'is required';
  static const String phoneNumberRequired = 'Phone number is required';
  static const String phoneNumberMustHave10Digits =
      'Phone number must have 10 digits';
  static const String phoneNumberMustStartWith =
      'Phone number must start with 6, 7, 8, or 9';
  static const String otpRequired = 'OTP is required';
  static const String otpMustHave6Digits = 'OTP must have 6 digits';

  // eKYC Verification
  static const String ekycVerificationTitle = 'eKYC Verification';
  static const String ekycVerificationDescription =
      'Please upload legal documents to continue';
  static const String uploadDocuments = 'Upload documents';
  static const String documentsUploadedSuccess =
      'Documents uploaded successfully';
  static const String documentsUploadedFailed =
      'Failed to upload documents. Please try again.';
  static const String ekycVerificationDescription2 =
      'Your identity verification is important to us. Please ensure your documents are clear and valid.';

  // Locality Details
  static const String localityDetailsTitle = 'Locality details';
  static const String state = 'State';
  static const String city = 'City';
  static const String locality = 'Locality';
  static const String personalDetails = 'Personal Details';
  static const String selectState = 'Select State';
  static const String selectCity = 'Select City';
  static const String noCitiesAvailable = 'No cities available';

  // RERA Verification
  static const String reraVerification = 'RERA Verification';
  static const String reraCertificate = 'RERA Certificate';
  static const String reraCertificateLabel = '1 RERA Certificate*';
  static const String registrationNumber = 'Registration number';
  static const String registrationNumberHint = 'p000/0000/0000/0000';
  static const String uploadRera = 'Upload RERA';
  static const String fileFormats = 'JPEG, PNG, PDF';
  static const String allDocumentsMandatory = '* All documents are mandatory';

  // Success/Completion
  static const String congratulations = 'Congratulations';
  static const String accountReadyMessage =
      'Your account is ready to use. You will be redirected to the Homepage in a few seconds.';
  static const String languagePreferenceUpdated =
      'Language Preference is updated';

  // New Schedule
  static const String newSchedule = 'New Schedule';
  static const String selectAvailableTime = 'Select your Available Time';
  static const String availableEntireDay = 'Available entire day';
}
