// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Green Share';

  @override
  String get profile => 'Profile';

  @override
  String get donorProfile => 'Donor Profile';

  @override
  String get pleaseLogInToViewProfile => 'Please log in to view your profile.';

  @override
  String get logIn => 'Log In';

  @override
  String get logout => 'Logout';

  @override
  String get languageSetting => 'Language (EN/AR)';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get yourListings => 'Your Listings';

  @override
  String get reviews => 'Reviews';

  @override
  String get viewAll => 'View All';

  @override
  String get noItemsPostedYet => 'No items posted yet';

  @override
  String get noReviewsYet => 'No reviews yet.';

  @override
  String get communityMember => 'Community Member';

  @override
  String get given => 'Given';

  @override
  String get received => 'Received';

  @override
  String get home => 'Home';

  @override
  String get post => 'Post';

  @override
  String get chat => 'Chat';

  @override
  String get discover => 'Discover';

  @override
  String get list => 'List';

  @override
  String get map => 'Map';

  @override
  String get searchItems => 'Search items...';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get beTheFirst => 'Be the first to post a donation or request!';

  @override
  String get locationDisabled => 'Location services are disabled.';

  @override
  String get locationDenied => 'Location permission denied.';

  @override
  String get locationPermDenied =>
      'Location permissions are permanently denied.';

  @override
  String get locationFailed => 'Failed to get current location.';

  @override
  String get messages => 'Messages';

  @override
  String get pleaseLoginToViewMessages => 'Please log in to view messages.';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get connectWithOthers => 'Connect with others to start chatting.';

  @override
  String giveItemTo(String itemTitle, String otherUserName) {
    return 'Give \'$itemTitle\' to $otherUserName?';
  }

  @override
  String get award => 'Award';

  @override
  String rateAndReviewTitle(String otherUserName, String itemTitle) {
    return 'Rate & Review $otherUserName for \'$itemTitle\'';
  }

  @override
  String get review => 'Review';

  @override
  String get pleaseLoginToSendMessages => 'Please login to send messages.';

  @override
  String get startTheConversation => 'Start the conversation!';

  @override
  String sayHiTo(String otherUserName) {
    return 'Say hi to $otherUserName';
  }

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get donateItemQ => 'Donate Item?';

  @override
  String get markRequestCompletedQ => 'Mark Request Completed?';

  @override
  String confirmDonate(String otherUserName) {
    return 'Are you sure you want to donate this item to $otherUserName? This will remove it from the home page.';
  }

  @override
  String confirmComplete(String otherUserName) {
    return 'Are you sure you want to complete this request with $otherUserName?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get itemAwarded => 'Item automatically awarded!';

  @override
  String get yesConfirm => 'Yes, confirm';

  @override
  String get rateAndReview => 'Rate & Review';

  @override
  String get howWasExperience => 'How was your experience?';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get submit => 'Submit';

  @override
  String get reviewSubmitted => 'Review submitted successfully!';

  @override
  String get reviewFailed => 'Failed to submit review.';

  @override
  String get automatedDonateMsg =>
      'Hi! I have officially marked this item as donated to you. Enjoy!';

  @override
  String get automatedCompleteMsg =>
      'Hi! I have officially marked this request as completed with you. Thank you!';

  @override
  String get postItem => 'Post Item';

  @override
  String get readyToShare => 'Ready to share?';

  @override
  String get pleaseLoginToPost =>
      'Please log in or create an account to post items.';

  @override
  String get donate => 'Donate';

  @override
  String get request => 'Request';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get aiInterpreting => 'AI interpreting image...';

  @override
  String get title => 'Title';

  @override
  String get categoryAutoFilled => 'Category (Auto-filled by AI)';

  @override
  String get description => 'Description';

  @override
  String get condition => 'Condition';

  @override
  String get locating => 'Locating...';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get locationSelected => 'Location Selected';

  @override
  String get gettingCurrentLocation => 'Getting current location...';

  @override
  String get tapToChooseOnMap => 'Tap to choose on map';

  @override
  String get postButton => 'Post';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get itemPostedSuccess => 'Item posted successfully!';

  @override
  String errorPostingItem(String error) {
    return 'Error posting item: $error';
  }

  @override
  String get pleaseEnterEmailPass => 'Please enter both email and password';

  @override
  String get errorDuringLogin => 'An error occurred during login.';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error: $error';
  }

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToAccount => 'Sign in to your Green Share account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get signupFailed => 'Signup failed';

  @override
  String get createAnAccount => 'Create an Account';

  @override
  String get joinCommunityToday => 'Join our community today';

  @override
  String get fullName => 'Full Name';

  @override
  String get role => 'Role';

  @override
  String get donor => 'Donor';

  @override
  String get recipient => 'Recipient';

  @override
  String get charity => 'Charity';

  @override
  String get city => 'City';

  @override
  String get filterOptions => 'Filter Options';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get name => 'Name';

  @override
  String get updateProfileSuccess => 'Profile updated successfully!';

  @override
  String updateProfileError(String error) {
    return 'Error updating profile: $error';
  }

  @override
  String get reloginRequiredForEmail =>
      'You must re-login to change your email address.';

  @override
  String get activeListings => 'Active Listings';

  @override
  String get signInWithPhone => 'Sign in with Phone';

  @override
  String get enterPhoneNumber => 'Enter your phone number (e.g. +1234567890)';

  @override
  String get phoneVerification => 'Phone Verification';

  @override
  String get sendCode => 'Send Code';

  @override
  String get enterOtp => 'Enter the 6-digit code';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get invalidOtp => 'Invalid OTP code';

  @override
  String get didNotReceiveCode => 'Didn\'t receive code?';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get user => 'User';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get commercialRegistration => 'CR (Commercial Number)';
}
