import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Green Share'**
  String get appTitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @donorProfile.
  ///
  /// In en, this message translates to:
  /// **'Donor Profile'**
  String get donorProfile;

  /// No description provided for @pleaseLogInToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile.'**
  String get pleaseLogInToViewProfile;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language (EN/AR)'**
  String get languageSetting;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @yourListings.
  ///
  /// In en, this message translates to:
  /// **'Your Listings'**
  String get yourListings;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noItemsPostedYet.
  ///
  /// In en, this message translates to:
  /// **'No items posted yet'**
  String get noItemsPostedYet;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @communityMember.
  ///
  /// In en, this message translates to:
  /// **'Community Member'**
  String get communityMember;

  /// No description provided for @given.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get given;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @searchItems.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchItems;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @beTheFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to post a donation or request!'**
  String get beTheFirst;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationDisabled;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationDenied;

  /// No description provided for @locationPermDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get locationPermDenied;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get current location.'**
  String get locationFailed;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @pleaseLoginToViewMessages.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view messages.'**
  String get pleaseLoginToViewMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @connectWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Connect with others to start chatting.'**
  String get connectWithOthers;

  /// No description provided for @giveItemTo.
  ///
  /// In en, this message translates to:
  /// **'Give \'{itemTitle}\' to {otherUserName}?'**
  String giveItemTo(String itemTitle, String otherUserName);

  /// No description provided for @award.
  ///
  /// In en, this message translates to:
  /// **'Award'**
  String get award;

  /// No description provided for @rateAndReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review {otherUserName} for \'{itemTitle}\''**
  String rateAndReviewTitle(String otherUserName, String itemTitle);

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @pleaseLoginToSendMessages.
  ///
  /// In en, this message translates to:
  /// **'Please login to send messages.'**
  String get pleaseLoginToSendMessages;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startTheConversation;

  /// No description provided for @sayHiTo.
  ///
  /// In en, this message translates to:
  /// **'Say hi to {otherUserName}'**
  String sayHiTo(String otherUserName);

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @donateItemQ.
  ///
  /// In en, this message translates to:
  /// **'Donate Item?'**
  String get donateItemQ;

  /// No description provided for @markRequestCompletedQ.
  ///
  /// In en, this message translates to:
  /// **'Mark Request Completed?'**
  String get markRequestCompletedQ;

  /// No description provided for @confirmDonate.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to donate this item to {otherUserName}? This will remove it from the home page.'**
  String confirmDonate(String otherUserName);

  /// No description provided for @confirmComplete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to complete this request with {otherUserName}?'**
  String confirmComplete(String otherUserName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @itemAwarded.
  ///
  /// In en, this message translates to:
  /// **'Item automatically awarded!'**
  String get itemAwarded;

  /// No description provided for @yesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, confirm'**
  String get yesConfirm;

  /// No description provided for @rateAndReview.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review'**
  String get rateAndReview;

  /// No description provided for @howWasExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasExperience;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully!'**
  String get reviewSubmitted;

  /// No description provided for @reviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review.'**
  String get reviewFailed;

  /// No description provided for @automatedDonateMsg.
  ///
  /// In en, this message translates to:
  /// **'Hi! I have officially marked this item as donated to you. Enjoy!'**
  String get automatedDonateMsg;

  /// No description provided for @automatedCompleteMsg.
  ///
  /// In en, this message translates to:
  /// **'Hi! I have officially marked this request as completed with you. Thank you!'**
  String get automatedCompleteMsg;

  /// No description provided for @postItem.
  ///
  /// In en, this message translates to:
  /// **'Post Item'**
  String get postItem;

  /// No description provided for @readyToShare.
  ///
  /// In en, this message translates to:
  /// **'Ready to share?'**
  String get readyToShare;

  /// No description provided for @pleaseLoginToPost.
  ///
  /// In en, this message translates to:
  /// **'Please log in or create an account to post items.'**
  String get pleaseLoginToPost;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @aiInterpreting.
  ///
  /// In en, this message translates to:
  /// **'AI interpreting image...'**
  String get aiInterpreting;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @categoryAutoFilled.
  ///
  /// In en, this message translates to:
  /// **'Category (Auto-filled by AI)'**
  String get categoryAutoFilled;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get locating;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location Selected'**
  String get locationSelected;

  /// No description provided for @gettingCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting current location...'**
  String get gettingCurrentLocation;

  /// No description provided for @tapToChooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose on map'**
  String get tapToChooseOnMap;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postButton;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @itemPostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item posted successfully!'**
  String get itemPostedSuccess;

  /// No description provided for @errorPostingItem.
  ///
  /// In en, this message translates to:
  /// **'Error posting item: {error}'**
  String errorPostingItem(String error);

  /// No description provided for @pleaseEnterEmailPass.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password'**
  String get pleaseEnterEmailPass;

  /// No description provided for @errorDuringLogin.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login.'**
  String get errorDuringLogin;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Green Share account'**
  String get signInToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Signup failed'**
  String get signupFailed;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// No description provided for @joinCommunityToday.
  ///
  /// In en, this message translates to:
  /// **'Join our community today'**
  String get joinCommunityToday;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @donor.
  ///
  /// In en, this message translates to:
  /// **'Donor'**
  String get donor;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @charity.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get charity;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get updateProfileSuccess;

  /// No description provided for @updateProfileError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String updateProfileError(String error);

  /// No description provided for @reloginRequiredForEmail.
  ///
  /// In en, this message translates to:
  /// **'You must re-login to change your email address.'**
  String get reloginRequiredForEmail;

  /// No description provided for @activeListings.
  ///
  /// In en, this message translates to:
  /// **'Active Listings'**
  String get activeListings;

  /// No description provided for @signInWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Phone'**
  String get signInWithPhone;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number (e.g. +1234567890)'**
  String get enterPhoneNumber;

  /// No description provided for @phoneVerification.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get phoneVerification;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterOtp;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get invalidOtp;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code?'**
  String get didNotReceiveCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @commercialRegistration.
  ///
  /// In en, this message translates to:
  /// **'CR (Commercial Number)'**
  String get commercialRegistration;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
