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
  static const String fontFamilyInter = 'Inter';

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
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String finish = 'Finish';

  // Signup
  static const String createAccount = 'Create account';
  static const String createAccountSubtitle =
      'Sign up with your details to get started.';
  static const String fullNameFieldLabel = 'Full name';
  static const String emailFieldLabel = 'Email';
  static const String passwordFieldLabel = 'Password';
  static const String phoneFieldLabel = 'Mobile number';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signUp = 'Sign up';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String logIn = 'Log in';
  static const String verifyDetailsTitle = 'Verify your details';
  static const String verifyDetailsSubtitle =
      'Enter the codes we sent to your email and mobile number.';
  static const String emailCodeLabel = 'Email code';
  static const String mobileCodeLabel = 'Mobile code';
  static const String verifyButton = 'Verify';
  static const String codesResent = 'Verification codes resent';

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
  static const String relatedProperties = 'Related Properties';
  static const String homeTopLocations = 'Top Locations';
  static const String homeSeeAll = 'See All';
  static const String homeYourOffers = 'Your offers';

  // Buyer offers (unit sales)
  static const String offerDetails = 'Offer details';
  static const String offerOverview = 'Overview';
  static const String offerUnit = 'Unit';
  static const String offerBuilder = 'Builder';
  static const String offerLocation = 'Location';
  static const String offerRera = 'RERA';
  static const String offerCostBreakdown = 'Cost breakdown';
  static const String offerMilestones = 'Payment milestones';
  static const String offerRelationshipManager = 'Relationship manager';
  static const String offerActions = 'Actions';
  static const String offerPreview = 'Preview offer';
  static const String offerAccept = 'Accept offer';
  static const String offerDecline = 'Decline offer';
  static const String offerClaim = 'Claim offer';
  static const String offerClaimToken = 'Claim token';
  static const String offerAcceptTitle = 'Accept this offer?';
  static const String offerAcceptMessage =
      'You are about to accept this property offer. This action cannot be undone.';
  static const String offerDeclineTitle = 'Decline this offer?';
  static const String offerDeclineMessage =
      'Are you sure you want to decline this offer?';
  static const String offerAccepted = 'Offer accepted';
  static const String offerDeclined = 'Offer declined';
  static const String offerClaimed = 'Offer claimed';
  static const String retry = 'Retry';

  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotificationYet = 'No notification yet';
  static const String noNotificationDescription =
      'All notification we send will appear here, so you can view them easly anytime.';
  static const String notificationsToday = 'Today';
  static const String notificationsYesterday = 'Yesterday';
  static const String showEmptyState = 'Show empty state';
  static const String showNotifications = 'Show notifications';
  static const String markAllRead = 'Mark all as read';
  static const String notificationLoadError =
      'Could not load your notifications';
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
  static const String dropInterest = 'Drop interest';
  static const String dropInterestUnitsHint =
      'Choose a unit below to drop your interest.';
  static const String yesRemove = 'Yes, remove';
  static const String categoryAll = 'All';
  static const String categoryHouse = 'House';
  static const String categoryVilla = 'Villa';
  static const String categoryApartment = 'Apartment';
  static const String studioApartment = 'Studio Apartment';
  static const String duplexHomes = 'Duplex Homes';
  static const String penthouse = 'Penthouse';
  static const String noFavoritesTitle1 = 'You don\'t have any';
  static const String noFavoritesTitle2 = 'favorites yet';
  static const String propertyTagTrilight = 'The Trilight';

  // Main Tab Navigation
  static const String tabHome = 'Home';
  static const String tabExplore = 'Explore';
  static const String tabFavorites = 'Favorites';
  static const String tabChat = 'Chat';
  static const String tabProfile = 'Profile';
  static const String selectLocation = 'Select Location';

  // Property Details
  static const String propertyDetails = 'Property Details';
  static const String residentialPropertyDetails =
      'Residential Property Details';
  static const String commercialPropertyDetails = 'Commercial Property Details';
  static const String landPropertyDetails = 'Land Property Details';
  static const String landDetails = 'Land Details';
  static const String propertyNotFound = 'Property not found';
  static const String requestVisit = 'Request for Visit';
  static const String overview = 'Overview';
  static const String floorPlans = 'Floor Plans';
  static const String documents = 'Documents';
  static const String areaDetails = 'Area Details';
  static const String propertyInfo = 'Property Info';
  static const String propertyInfoSqFt = 'Sq.ft';
  static const String propertyInfoBedrooms = 'Bedrooms';
  static const String propertyInfoBathrooms = 'Bathrooms';
  static const String propertyInfoSafetyRank = 'Safety Rank';
  static const String facilities = 'Facilities';
  static const String amenities = 'Amenities';
  static const String gallery = 'Gallery';
  static const String seeAll = 'See All';
  static const String openInMaps = 'Open in Maps';
  static const String unitDetails = 'Unit Details';
  static const String projectName = 'Project Name';
  static const String reraApproved = 'RERA Approved';
  static const String plotArea = 'Plot Area';
  static const String builtUpArea = 'Built-up Area';
  static const String facing = 'Facing';
  static const String bhk = 'BHK';
  static const String floorHeight = 'Floor Height';
  static const String unitType = 'Unit Type';
  static const String ventilation = 'Ventilation';
  static const String commonArea = 'Common Area';
  static const String downloadFloorPlan = 'Download Floor Plan';
  static const String downloadBrochure = 'Download Brochure';
  static const String downloadReraCertificate = 'Download RERA Certificate';
  static const String tokenTitle = 'ESCROW Protected Payment';
  static const String payToken = 'Pay Token Amount';
  static const String tokenTitleDescription =
      'Your funds will be securely held in an ESCROW account and released based on construction milestones';
  static const String payTokenDescription =
      'Pay token amount to unlock full pricing details, payment schedules, EMI calculator, and exclusive broker support.';
  static const String reraId = 'RERA ID: ';
  static const String payNow = 'Pay Now';
  static const String pricing = 'Pricing';
  static const String pricingInformationNotAvailable =
      'Pricing information not available';
  static const String availableDocuments = 'Available Documents';
  static const String noDocumentsAvailable = 'No documents available';
  static const String plotReservationLetter = 'Plot Reservation Letter';
  static const String allotmentLetter = 'Allotment Letter';
  static const String agreementDraft = 'Agreement Draft';
  static const String layoutApproval = 'Layout Approval';
  static const String sanctionedLayoutPlan = 'Sanctioned Layout Plan';
  static const String reraCertificate = 'RERA Certificate';
  static const String masterPlan = 'Master Plan';
  static const String plotMap = 'Plot Map';
  static const String paymentReceipts = 'Payment Receipts';
  static const String nocCertificates = 'NOC Certificates';
  static const String plotBooked = 'Plot Booked';
  static const String hdmaApproved = 'HDMA Approved';
  static const String layoutInformation = 'Layout Information';
  static const String approvalType = 'Approval Type';
  static const String totalArea = 'Total Area';
  static const String totalPlots = 'Total Plots';
  static const String numberOfBlocks = 'Number of Blocks';
  static const String roadWidths = 'Road widths';
  static const String reraCertifiedLayout = 'RERA Certified Layout';
  static const String yourPlotDetails = 'Your Plot Details';
  static const String plotNumber = 'Plot Number';
  static const String block = 'Block';
  static const String plotSize = 'Plot Size';
  static const String roadWidth = 'Road Width';
  static const String eastFacing = 'East Facing';
  static const String parkFacing = 'Park Facing';
  static const String layoutAmenities = 'Layout Amenities';
  static const String avenuePlantation = 'Avenue Plantation';
  static const String walkingTrack = 'Walking Track';
  static const String childrensPark = 'Children\'s Park';
  static const String communityHall = 'Community Hall';
  static const String undergroundDrainage = 'Underground Drainage';
  static const String electrification = 'Electrification';
  static const String waterSupply = 'Water Supply';
  static const String available = 'Available';
  static const String locationConnectivity = 'Location & Connectivity';
  static const String airport = 'Airport';
  static const String orr = 'ORR';
  static const String schools = 'Schools';
  static const String hospitals = 'Hospitals';
  static const String shopping = 'Shopping';
  static const String techParks = 'Tech Parks';
  static const String metroStation = 'Metro Station';
  static const String majorRoad = 'Major Road';
  static const String downloads = 'Downloads';
  static const String downloadMasterLayoutPlan = 'Download Master Layout Plan';
  static const String totalAmount = 'Total Amount';
  static const String amountPaid = 'Amount Paid';
  static const String balance = 'Balance';
  static const String priceBreakdown = 'Price Breakdown';
  static const String basePrice = 'Base Price';
  static const String eastFacingPremium = 'East Facing Premium';
  static const String parkFacingPremium = 'Park Facing Premium';
  static const String developmentCharges = 'Development Charges';
  static const String electricityConnection = 'Electricity Connection';
  static const String waterConnection = 'Water Connection';
  static const String subTotal = 'Sub Total';
  static const String stampDuty = 'Stamp Duty';
  static const String registrationFee = 'Registration Fee';
  static const String documentationCharges = 'Documentation Charges';
  static const String grandTotal = 'Grand Total';
  static const String paymentMilestones = 'Payment Milestones';
  static const String tokenPayment = 'Token Payment';
  static const String agreementSigning = 'Agreement Signing';
  static const String developmentStage = 'Development Stage';
  static const String registration = 'Registration';
  static const String paid = 'Paid';
  // static const String due = 'Due';
  static const String landLoanEmiCalculator = 'Land Loan EMI Calculator';
  static const String loanAmount = 'Loan Amount (₹)';
  static const String tenureYears = 'Tenure (Years)';
  static const String interestRate = 'Interest Rate (%)';
  static const String monthlyEmi = 'Monthly EMI';
  static const String totalInterest = 'Total Interest';
  static const String yourRelationshipManager = 'Your Relationship Manager';
  static const String verifiedChannelPartner = 'Verified Channel Partner';

  // Profile
  static const String profile = 'Profile';
  static const String agentProfile = 'Agent Profile';
  static const String verifiedAccount = 'Verified Account';
  static const String properties = 'Properties';
  static const String makeACall = 'Make a call';
  static const String listings = 'Listings';
  static const String sold = 'Sold';
  static const String conversions = 'Conversions';
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
  static const String searchHint = 'Search Place, Property, etc';
  static const String recent = 'Recent';
  static const String result = 'Result';
  static const String searchLoading = 'Search - Loading';
  static const String searchRecent = 'Search - Recent';
  static const String sort = 'Sort';
  static const String recentlyAdded = 'Recently Added';
  static const String orderByAZ = 'Order by A - Z';
  static const String orderByZA = 'Order by Z - A';
  static const String priceLowToHigh = 'Price: Low to High';
  static const String priceHighToLow = 'Price: High to Low';
  static const String clearSort = 'Clear Sort';

  // Contact Details
  static const String call = 'Call';
  static const String message = 'Message';

  // Filter Page
  static const String filters = 'Filters';
  static const String unitFilters = 'Find your unit';
  static const String unitSearchHint = 'Search unit no., tower, facing…';
  static const String unitsShowing = 'Showing';
  static const String unitsOf = 'of';
  static const String unitsAvailableOnly = 'Available';
  static const String unitNoMatches = 'No units match your filters';
  static const String unitNoMatchesHint =
      'Try adjusting BHK, price, or clear filters to see more options.';
  static const String clearFilters = 'Clear filters';
  static const String unitPriceRange = 'Price range';
  static const String unitAreaRange = 'Area (sq.ft)';
  static const String unitFacing = 'Facing';
  static const String unitTower = 'Tower';
  static const String unitBhk = 'Configuration';
  static const String applyFilters = 'Apply';
  static const String resetFilters = 'Reset Filters';
  static const String lookingFor = 'Looking For';
  static const String residential = 'Residential';
  static const String tokenPaid = 'Token Paid';
  static const String readyToMove = 'Ready to Move';
  static const String propertiesFound = 'Properties found';
  static const String noPropertiesFound = 'No properties found';
  static const String nextPaymentDue = 'Next Payment Due';
  static const String sftArea = 'SFT Area';
  static const String commercial = 'Commercial';
  static const String lands = 'Lands';
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
  static const String arvr = 'AR/VR';

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
  static const String phoneNumberCannotBeAllZeros =
      'Phone number cannot be all zeros';
  static const String phoneNumberCannotBeAllSameDigits =
      'Phone number cannot be all same digits';
  static const String phoneNumberInvalid =
      'Please enter a valid Indian phone number';
  static const String otpRequired = 'OTP is required';
  static const String otpMustHave6Digits = 'OTP must have 6 digits';
  static const String panNumberRequired = 'PAN number is required';
  static const String panNumberInvalid =
      'Please enter a valid PAN number (e.g., ABCDE1234F)';
  static const String aadhaarNumberRequired = 'Aadhaar number is required';
  static const String aadhaarNumberInvalid =
      'Aadhaar number must have 12 digits';
  static const String addressRequired = 'Residential address is required';
  static const String addressMinLength =
      'Address must be at least 10 characters';

  // Escrow Account Created Page
  static const String escrowAccount = 'ESCROW Account';
  static const String createdOn = 'Created on';
  static const String status = 'Status';
  static const String active = 'Active';
  static const String pendingDeposit = 'Pending Deposit';
  static const String tokenPaymentDesc =
      'Deposit your token payment to activate\nthe ESCROW account';
  static const String amountToDeposit = 'Amount To Deposit';
  static const String howEscrowWorks = 'How ESCROWS Works';
  static const String step1Title = 'You Deposit Funds';
  static const String step1Desc =
      'Your payment is securely held in the\nESCROW account';
  static const String step2Title = 'Builder Completes Milestone';
  static const String step2Desc =
      'Construction progress verified by RERA\nauthorities';
  static const String step3Title = 'Automatic Release';
  static const String step3Desc =
      'Funds are released to the builder only after\nyour approval';
  static const String completeProtection = 'Complete Protection';
  static const String completeProtectionDesc =
      'Automatic refund if milestones are not met';
  static const String accountFeatures = 'Account Features';
  static const String reraProtected = 'RERA Protected';
  static const String reraProtectedSub = '100% Secure';
  static const String fullTransparency = 'Full Transparency';
  static const String fullTransparencySub = 'Track Everything';
  static const String interestEarning = 'Interest Earning';
  static const String interestEarningSub = '3.5% p.a.';
  static const String access247 = '24/7 Access';
  static const String access247Sub = 'Real-time Updates';
  static const String importantInformation = 'Important Information';
  static const String importantInfo1 =
      'All payments for this property will be processed through this ESCROW account';
  static const String importantInfo2 =
      'You will receive SMS and email alerts for every transaction';
  static const String importantInfo3 =
      'Account statements will be available in your Documents section';
  static const String importantInfo4 =
      'Funds earn interest untill released to builder';
  static const String importantInfo5 =
      'You can view transaction history anytime from your profile';
  static const String download = 'Download';
  static const String downloading = 'Downloading...';
  static const String downloadUrlNotAvailable = 'Download URL not available';
  static const String storagePermissionDenied = 'Storage permission denied';
  static const String downloadedAndStored =
      'Downloaded and stored in Files app';
  static const String view = 'View';
  static const String downloadFailed = 'Download failed';
  static const String share = 'Share';
  static const String haveQuestionsEscrow =
      'Have questions about your ESCROW\naccount?';
  static const String contactEscrowSupport = 'Contact ESCROW Support';
  static const String proceedToDeposit = 'Proceed to Deposit';

  // Payment Method Page
  static const String paymentSummary = 'Payment Summary';
  static const String amountToPay = 'Amount to pay';
  static const String choosePaymentMethod = 'Choose Payment Method';
  static const String netBanking = 'Net Banking';
  static const String allMajorBanks = 'All major banks';
  static const String creditDebitCard = 'Credit / Debit Card';
  static const String cardsDesc = 'Visa, Mastercard, Rupay';
  static const String wallets = 'Wallets';
  static const String walletsDesc = 'Paytm, Mobikwik, Amazon Pay';
  static const String securePayment = 'Secure Payment';
  static const String paymentSecureDesc =
      'Your payment information is encrypted and secure. We use industry-standard security measures.';
  static const String paymentBreakdown = 'Payment Breakdown';
  static const String baseAmount = 'Base Amount';
  static const String paymentGatewayCharges = 'Payment Gateway Charges';
  static const String totalPayable = 'Total Payable';
  static const String proceedToPay = 'Proceed to Pay';

  // Processing Page
  static const String processingPayment = 'Processing Payment';
  static const String processingDesc =
      'Please wait while we process your payment securely ...';
  static const String verifyingDetails = 'Verifying payment details';
  static const String connectingToBank = 'Connecting to bank';
  static const String processingTransaction = 'Processing transaction';

  // Success Page
  static const String paymentSuccessful = 'Payment Successful!';
  static const String paymentSuccessDesc =
      'Your payment has been processed successfully';
  static const String transactionId = 'Transaction ID';
  static const String paymentFor = 'Payment For';
  static const String paymentMethod = 'Payment Method';
  static const String dateAndTime = 'Date & Time';
  static const String whatsNext = 'What\'s Next?';
  static const String nextStep1Title = 'Broker Assignment';
  static const String nextStep1Desc =
      'Your dedicated relationship manager will be assigned within 24 hours.';
  static const String nextStep2Title = 'Document Verification';
  static const String nextStep2Desc =
      'Submit your KYC documents for verification';
  static const String nextStep3Title = 'Agreement Signing';
  static const String nextStep3Desc =
      'Digital agreement will be shared for e-signature';
  static const String backToHome = 'Back to Home';
  static const String receipt = 'Receipt';

  // Pay Module - Token Payment
  static const String personalDetails = 'Personal Details';
  static const String nomineeDetails = 'Nominee Details';
  static const String bankDetails = 'Bank Account Details';
  static const String reviewAndTerms = 'Review & Accepts Terms';
  static const String stepPersonal = 'Personal';
  static const String stepNominee = 'Nominee';
  static const String stepBank = 'Bank';
  static const String stepReview = 'Review';
  static const String kycVerification = 'KYC Verification';
  static const String kycVerificationDesc =
      'Your documents will be verified as per RERA guidelines. Please ensure all details match your official documents.';
  static const String whyNominee = 'Why Nominee?';
  static const String whyNomineeDesc =
      'The nominee will have rights to the property and ESCROW funds in case of unforeseen circumstances';
  static const String secureBanking = 'Secure Banking';
  static const String secureBankingDesc =
      'Your bank details are encrypted and will be used only for ESCROW transactions and refunds.';
  static const String escrowProtectedTransaction =
      'ESCROW Protected Transaction';
  static const String escrowProtectedDesc =
      'Your funds will be securely held in an ESCROW account until property milestones are met';
  static const String property = 'Property';
  static const String paymentType = 'Payment Type';
  static const String amount = 'Amount';
  static const String fullNameLabel = 'Full Name (as per PAN)';
  static const String emailAddress = 'Email Address';
  static const String phoneNumberLabel = 'Phone Number';
  static const String panNumber = 'PAN Number *';
  static const String aadhaarNumber = 'Aadhaar Number *';
  static const String residentialAddress = 'Residential Address *';
  static const String nomineeFullName = 'Nominee Full Name *';
  static const String relationshipWithNominee = 'Relationship with Nominee *';
  static const String nomineePhoneNumber = 'Nominee Phone Number *';
  static const String nomineeEmail = 'Nominee Email (Optional)';
  static const String bankName = 'Bank Name *';
  static const String accountNumber = 'Account Number *';
  static const String confirmAccountNumber = 'Confirm Account Number *';
  static const String ifscCode = 'IFSC Code *';
  static const String branchName = 'Branch Name *';
  static const String accountNumberMismatch = 'Account numbers must match';
  static const String accountHolder = 'Account Holder';
  static const String terms = 'Terms';
  static const String somethingWentWrong = 'Something went wrong';
  static const String countryCodeIndia = '+91 ';
  static const String agreeTerms = 'I agree to the ';
  static const String escrowTermsConditions = 'ESCROW Terms & Conditions';
  static const String agreeTermsSuffix =
      ' and understand that funds will be released based on conditions or milestones';
  static const String byContinuingAcceptTerms =
      'By Continuing you are accepting our ';
  static const String authorizePaySft =
      'I authorize PaySFT to create and manage my ESCROW account for this property transaction';
  static const String acknowledgeRera =
      'I acknowledge that this transaction is RERA compliant and my funds are protected under RERA guidelines';
  static const String escrowBenefits = 'ESCROW Account Benefits';
  static const String benefit1 =
      'Funds released only upon milestone completion';
  static const String benefit2 = 'Complete transparency in payment tracking';
  static const String benefit3 = 'RERA compliant and legally protected';
  static const String benefit4 = 'Automatic refund in case of project delays';
  static const String benefit5 = '24/7 account monitoring and support';
  static const String createEscrowAccount = 'Create Escrow Account';
  static const String enterNomineeName = 'Enter nominee name';
  static const String enterRelationship = 'e.g., Spouse, Child, Parent';
  static const String enterAccountNumber = 'Enter account number';
  static const String reEnterAccountNumber = 'Re-enter account number';
  static const String enterBranchName = 'Enter branch name';
  static const String enterCompleteAddress = 'Enter your complete address';

  // Additional Property/Land Details Strings
  static const String approved = 'Approved';

  // Commercial Property Details
  static const String commercialUnitDetails = 'Commercial Unit Details';
  static const String technicalAndInfrastructure = 'Technical & Infrastructure';
  static const String amenitiesFeatures = 'Amenities & Features';
  // Technical & Infrastructure labels
  static const String floorLoadCapacity = 'Floor Load Capacity';
  static const String powerSanctionLoad = 'Power Sanction Load';
  static const String powerRedundancy = 'Power Redundancy';
  static const String hvacType = 'HVAC Type';
  static const String coolingCapacity = 'Cooling Capacity';
  static const String serverRoomReadiness = 'Server Room Readiness';

  // Interior & Workspace
  static const String interiorAndWorkspace = 'Interior & Workspace';
  static const String workstationsCapacity = 'Workstations Capacity';
  static const String cabins = 'Cabins';
  static const String receptionArea = 'Reception Area';
  static const String pantry = 'Pantry';
  static const String washrooms = 'Washrooms';
  static const String falseCeiling = 'False Ceiling';
  static const String flooring = 'Flooring';
  static const String lighting = 'Lighting';

  // Parking & Access
  static const String parkingAndAccess = 'Parking & Access';
  static const String parkingArea = 'Parking Area';
  static const String dedicatedParking = 'Dedicated Parking';
  static const String visitorParking = 'Visitor Parking';
  static const String twoWheelerParking = 'Two-wheeler Parking';
  static const String evCharging = 'EV Charging';
  static const String serviceBayAccess = 'Service bay access';

  // Operating Permissions & Restrictions
  static const String operatingPermissionsRestrictions =
      'Operating Permissions & Restrictions';
  static const String operationsTiming = 'Operations timing';
  static const String activityRestrictions = 'Activity Restrictions';
  static const String soundRestrictions = 'Sound Restrictions';
  static const String noiseImpact = 'Noise Impact';
  static const String signageAllowed = 'Signage Allowed';
  static const String brandingRights = 'Branding Rights';

  // Warehouse / Logistics Suitability
  static const String warehouseLogisticsSuitability =
      'Warehouse / Logistics Suitability';
  static const String clearCeilingHeight = 'Clear Ceiling Height';
  static const String dockDoors = 'Dock Doors';
  static const String truckTurningRadius = 'Truck Turning Radius';
  static const String entryGateWH = 'Entry Gate W&H';
  static const String columnSpacing = 'Column Spacing';
  static const String powerLoad = 'Power Load';
  static const String fireComplianceReadiness = 'Fire Compliance Readiness';
  static const String yardArea = 'Yard Area';
  static const String stagingArea = 'Staging Area';

  // GCC Ready
  static const String gccReady = 'GCC Ready';
  static const String largeFloorPlates = 'Large floor plates';
  static const String dualPowerFeed = 'Dual Power Feed';
  static const String highParkingRatio = 'High Parking Ratio';
  static const String expansionPossibility = 'Expansion Possibility';
  static const String carParking = 'Car Parking';
  static const String foodCourt = 'Food Court';
  static const String cafeteriaSpace = 'Cafeteria Space';
  static const String breakoutAreas = 'Breakout Areas';
  static const String washroomRatio = 'Washroom Ratio';
  static const String accessibility = 'Accessibility';

  // Data Center Suitability
  static const String dataCenterSuitability = 'Data Center Suitability';
  static const String dualPower = 'Dual Power';
  static const String dgBackupCapacity = 'DG Backup Capacity';
  static const String coolingReadiness = 'Cooling Readiness';
  static const String fiberConnectivity = 'Fiber Connectivity';
  static const String serverRoom = 'Server Room';
  static const String water = 'Water';
  static const String fireSuppression = 'Fire Suppression';
  static const String noiseTolerance = 'Noise Tolerance';

  // Retail / High Street
  static const String retailHighStreet = 'Retail / High Street';
  static const String frontageWidth = 'Frontage Width';
  static const String visibilityFromMainRoad = 'Visibility from Main Road';
  static const String floorToCeilingHeight = 'Floor to Ceiling Height';
  static const String signageRights = 'Signage Rights';
  static const String footfallPotential = 'Footfall Potential';
  static const String parkingVisibility = 'Parking Visibility';
  static const String accessFromRoad = 'Access from Road';

  // Residential Property Details - Land Share, Kitchen, Project Area, etc.
  static const String landShareUds = 'Land Share (UDS)';
  static const String availability = 'Availability';
  static const String totalLandArea = 'Total Land Area';
  static const String totalNumberOfUnits = 'Total number of Units';
  static const String uds = 'UDS';
  static const String landToApartRatioIn1AcreLand =
      'Land to Apart Ratio in 1 acre land';

  static const String kitchenAndInterior = 'Kitchen & Interior';
  static const String kitchenType = 'Kitchen Type';
  static const String utility = 'Utility';
  static const String modularKitchen = 'Modular Kitchen';
  static const String wardrobes = 'Wardrobes';

  static const String projectArea = 'Project Area';
  static const String superCarpetArea = 'Super Carpet Area';
  static const String balcony = 'Balcony';

  static const String floorAndUnit = 'Floor & Unit';
  static const String floorNumber = 'Floor Number';
  static const String totalFloors = 'Total Floors';
  static const String unitPosition = 'Unit Position';

  static const String bathroomsAndBalconies = 'Bathrooms & Balconies';
  static const String bathrooms = 'Bathrooms';
  static const String balconies = 'Balconies';

  static const String numberOfCarParkings = 'Number of Car Parkings';
  static const String parkingType = 'Parking Type';

  static const String constructionQuality = 'Construction Quality';
  static const String structureType = 'Structure type';
  static const String wallType = 'Wall Type';
  static const String flooringType = 'Flooring Type';

  static const String commercialHighlights = 'Commercial Highlights';
  static const String safetyClearances = 'Safety & Clearances';
  static const String superBuiltUpArea = 'Super Built-up Area';
  static const String carpetArea = 'Carpet Area';
  static const String floor = 'Floor';
  static const String premium = 'Premium';
  static const String footageWidth = 'Footage Width';
  static const String ceilingHeight = 'Ceiling Height';
  static const String accessPoint = 'Access Point';
  static const String fireNoc = 'Fire NOC';
  static const String electricityNoc = 'Electricity NOC';
  static const String environmentalClearance = 'Environmental Clearance';
  static const String occupancyCertificate = 'Occupancy Certificate';
  static const String highSpeedElevators = 'High Speed Elevators';
  static const String centralAirConditioning = 'Central Air Conditioning';
  static const String powerBackup100 = 'Power Backup (100%)';
  static const String security247Common = 'Security 24/7 Common';
  static const String fireSafetySystem = 'Fire Safety System';
  static const String ampleParkingSpace = 'Ample Parking Space';
  static const String conferenceRooms = 'Conference Rooms';
  static const String readMore = 'Read more';
  static const String readLess = 'Read less';
  static const String description = 'Description';
  static const String landInformation = 'Land Information';
  static const String hdmaStatus = 'HDMA Status';
  static const String shareTwitter = 'X';
  static const String shareWithFamilyAndFriends = 'Share with Family & Friends';
  static const String notInstalled = 'is not installed';
  static const String locationGreeting = 'Hi, Nice to meet you !';
  static const String locationSubGreeting =
      'Choose your location to find property around you';
  static const String selectManually = 'Select it manually';
}
