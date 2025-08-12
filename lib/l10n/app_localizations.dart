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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the app'**
  String get welcome;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get greeting;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

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

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @onboarding_1_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BULDM – the smart way to find lost items!'**
  String get onboarding_1_title;

  /// No description provided for @onboarding_1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Search, report, and help reunite people with their lost belongings'**
  String get onboarding_1_subtitle;

  /// No description provided for @onboarding_2_title.
  ///
  /// In en, this message translates to:
  /// **'Lost something? Report it in seconds'**
  String get onboarding_2_title;

  /// No description provided for @onboarding_2_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Easily report lost items and help return them to their rightful owners'**
  String get onboarding_2_subtitle;

  /// No description provided for @onboarding_3_title.
  ///
  /// In en, this message translates to:
  /// **'Found something lost? Be the reason it gets back!'**
  String get onboarding_3_title;

  /// No description provided for @onboarding_3_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Report what you find and help someone nearby reclaim their item'**
  String get onboarding_3_subtitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services to use this feature.'**
  String get locationServicesDisabled;

  /// No description provided for @postUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Upload'**
  String get postUploadTitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @selectImages.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get selectImages;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use this feature.'**
  String get locationPermissionRequired;

  /// No description provided for @locationServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Location services must be enabled to use this feature.'**
  String get locationServicesRequired;

  /// No description provided for @addPostDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Post Details'**
  String get addPostDetailsTitle;

  /// No description provided for @addPostDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide details about the item you found or lost'**
  String get addPostDetailsSubtitle;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @itemDescription.
  ///
  /// In en, this message translates to:
  /// **'Item Description'**
  String get itemDescription;

  /// No description provided for @itemCategory.
  ///
  /// In en, this message translates to:
  /// **'Item Category'**
  String get itemCategory;

  /// No description provided for @itemCategoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get itemCategoryPlaceholder;

  /// No description provided for @itemCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get itemCategoryError;

  /// No description provided for @itemNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the item name'**
  String get itemNameError;

  /// No description provided for @itemDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description of the item'**
  String get itemDescriptionError;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Please select a location'**
  String get locationError;

  /// No description provided for @postDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Post details saved successfully'**
  String get postDetailsSaved;

  /// No description provided for @postDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Error saving post details'**
  String get postDetailsError;

  /// No description provided for @itemCategoryOptions.
  ///
  /// In en, this message translates to:
  /// **'Item Category Options'**
  String get itemCategoryOptions;

  /// No description provided for @postSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post submitted successfully'**
  String get postSubmittedSuccessfully;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @postCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully'**
  String get postCreatedSuccessfully;

  /// No description provided for @postCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating post'**
  String get postCreationError;

  /// No description provided for @itemFound.
  ///
  /// In en, this message translates to:
  /// **'Item Found'**
  String get itemFound;

  /// No description provided for @itemLost.
  ///
  /// In en, this message translates to:
  /// **'Item Lost'**
  String get itemLost;

  /// No description provided for @reportLostItem.
  ///
  /// In en, this message translates to:
  /// **'Report Lost Item'**
  String get reportLostItem;

  /// No description provided for @reportFoundItem.
  ///
  /// In en, this message translates to:
  /// **'Report Found Item'**
  String get reportFoundItem;

  /// No description provided for @itemReportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item reported successfully'**
  String get itemReportedSuccessfully;

  /// No description provided for @itemReportError.
  ///
  /// In en, this message translates to:
  /// **'Error reporting item'**
  String get itemReportError;

  /// No description provided for @searchItems.
  ///
  /// In en, this message translates to:
  /// **'Search Items'**
  String get searchItems;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found matching your search criteria'**
  String get noItemsFound;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by item name or category'**
  String get searchPlaceholder;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @viewAllPosts.
  ///
  /// In en, this message translates to:
  /// **'View All Posts'**
  String get viewAllPosts;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @itemNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter item name'**
  String get itemNamePlaceholder;

  /// No description provided for @itemDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter item description'**
  String get itemDescriptionPlaceholder;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @selectLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocationPlaceholder;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @imageUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading images'**
  String get imageUploadError;

  /// No description provided for @imageUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Images uploaded successfully'**
  String get imageUploadSuccess;

  /// No description provided for @submitPost.
  ///
  /// In en, this message translates to:
  /// **'Submit Post'**
  String get submitPost;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get confirmDeletePost;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @postDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully'**
  String get postDeletedSuccessfully;

  /// No description provided for @postDeletionError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting post'**
  String get postDeletionError;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Provide a detailed description of the item'**
  String get descriptionHint;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @reporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get reporting;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// No description provided for @unreported.
  ///
  /// In en, this message translates to:
  /// **'Unreported'**
  String get unreported;

  /// No description provided for @itemReported.
  ///
  /// In en, this message translates to:
  /// **'Item reported successfully'**
  String get itemReported;

  /// No description provided for @itemNotReported.
  ///
  /// In en, this message translates to:
  /// **'Item not reported yet'**
  String get itemNotReported;

  /// No description provided for @reportingError.
  ///
  /// In en, this message translates to:
  /// **'Error reporting item'**
  String get reportingError;

  /// No description provided for @reportingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item reported successfully'**
  String get reportingSuccess;

  /// No description provided for @reportingFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to report item'**
  String get reportingFailure;

  /// No description provided for @reportingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Reporting in progress'**
  String get reportingInProgress;

  /// No description provided for @reportingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Reporting completed successfully'**
  String get reportingCompleted;

  /// No description provided for @locationAndDate.
  ///
  /// In en, this message translates to:
  /// **'Location and Date'**
  String get locationAndDate;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @contactInfoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your contact information (email or phone number)'**
  String get contactInfoHint;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @dateSelected.
  ///
  /// In en, this message translates to:
  /// **'Date Selected'**
  String get dateSelected;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @imagesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected Images'**
  String get imagesSectionTitle;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location Selected'**
  String get locationSelected;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email, please check your inbox.'**
  String get resetLinkSent;

  /// No description provided for @forgetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgetPasswordTitle;

  /// No description provided for @forgetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address below and we will send you a link to reset your password.'**
  String get forgetPasswordSubtitle;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get emailRequired;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAccount;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToYourAccount;

  /// No description provided for @signingInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signing in with Google...'**
  String get signingInWithGoogle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orUseYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Or use your email'**
  String get orUseYourEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordTooShort;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @signUpToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign up to your account'**
  String get signUpToYourAccount;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Signing up...'**
  String get signingUp;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Please check your email for verification'**
  String get verificationEmailSent;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAnAccount;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 6 characters long and contain at least one uppercase letter, one lowercase letter, and one number.'**
  String get passwordHint;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item name is required'**
  String get itemNameRequired;

  /// No description provided for @itemDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Item description is required'**
  String get itemDescriptionRequired;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters long'**
  String get nameTooShort;

  /// No description provided for @sendingVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code...'**
  String get sendingVerificationCode;

  /// No description provided for @verifyYourCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Code'**
  String get verifyYourCode;

  /// No description provided for @enterTheCodeSentToYourEmail.
  ///
  /// In en, this message translates to:
  /// **'We have sent a 6-digit verification code to your email address. Please enter it below.'**
  String get enterTheCodeSentToYourEmail;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email for the verification code.'**
  String get checkYourEmail;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get didNotReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verificationCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get verificationCodeRequired;

  /// No description provided for @verificationCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get verificationCodeInvalid;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to your email'**
  String get verificationCodeSent;

  /// No description provided for @verificationCodeResent.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent successfully'**
  String get verificationCodeResent;

  /// No description provided for @verificationCodeResendError.
  ///
  /// In en, this message translates to:
  /// **'Error resending verification code. Please try again.'**
  String get verificationCodeResendError;

  /// No description provided for @socketConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get socketConnecting;

  /// No description provided for @socketConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected to server'**
  String get socketConnected;

  /// No description provided for @socketDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from server'**
  String get socketDisconnected;

  /// No description provided for @socketError.
  ///
  /// In en, this message translates to:
  /// **'Connection error: {message}'**
  String socketError(Object message);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start the conversation!'**
  String get noMessages;

  /// No description provided for @loadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully'**
  String get messageSent;

  /// No description provided for @messageSendingError.
  ///
  /// In en, this message translates to:
  /// **'Error sending message. Please try again.'**
  String get messageSendingError;

  /// No description provided for @messagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your message here'**
  String get messagePlaceholder;

  /// No description provided for @messageRequired.
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageRequired;

  /// No description provided for @messageTooShort.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 1 character long'**
  String get messageTooShort;

  /// No description provided for @messageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Message cannot exceed 500 characters'**
  String get messageTooLong;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted successfully'**
  String get messageDeleted;

  /// No description provided for @messageDeletionError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting message. Please try again.'**
  String get messageDeletionError;

  /// No description provided for @messageEdited.
  ///
  /// In en, this message translates to:
  /// **'Message edited successfully'**
  String get messageEdited;

  /// No description provided for @messageEditingError.
  ///
  /// In en, this message translates to:
  /// **'Error editing message. Please try again.'**
  String get messageEditingError;

  /// No description provided for @messageEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get messageEdit;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Start the conversation!'**
  String get noMessagesYet;

  /// No description provided for @messageSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Message sent successfully'**
  String get messageSentSuccessfully;

  /// No description provided for @messageSendingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get messageSendingFailed;

  /// No description provided for @messageSendingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sending message...'**
  String get messageSendingInProgress;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name {name}'**
  String userName(Object name);

  /// No description provided for @userNameRequired.
  ///
  /// In en, this message translates to:
  /// **'User name is required'**
  String get userNameRequired;

  /// No description provided for @noChatsFound.
  ///
  /// In en, this message translates to:
  /// **'No chats found. Start a new conversation!'**
  String get noChatsFound;

  /// No description provided for @startChattingWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with your friends'**
  String get startChattingWithFriends;

  /// No description provided for @chatDetails.
  ///
  /// In en, this message translates to:
  /// **'Chat Details'**
  String get chatDetails;

  /// No description provided for @chatName.
  ///
  /// In en, this message translates to:
  /// **'Chat Name'**
  String get chatName;

  /// No description provided for @chatNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Chat name is required'**
  String get chatNameRequired;

  /// No description provided for @createNewChat.
  ///
  /// In en, this message translates to:
  /// **'Create New Chat'**
  String get createNewChat;

  /// No description provided for @joinChat.
  ///
  /// In en, this message translates to:
  /// **'Join Chat'**
  String get joinChat;

  /// No description provided for @leaveChat.
  ///
  /// In en, this message translates to:
  /// **'Leave Chat'**
  String get leaveChat;

  /// No description provided for @chatLeftSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'You have left the chat successfully'**
  String get chatLeftSuccessfully;

  /// No description provided for @chatLeftError.
  ///
  /// In en, this message translates to:
  /// **'Error leaving chat. Please try again.'**
  String get chatLeftError;

  /// No description provided for @chatCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Chat created successfully'**
  String get chatCreatedSuccessfully;

  /// No description provided for @chatCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating chat. Please try again.'**
  String get chatCreationError;

  /// No description provided for @joinChatError.
  ///
  /// In en, this message translates to:
  /// **'Error joining chat. Please try again.'**
  String get joinChatError;

  /// No description provided for @joinChatSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have joined the chat successfully'**
  String get joinChatSuccess;

  /// No description provided for @chatError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String chatError(Object message);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again later.'**
  String get unknownError;

  /// No description provided for @noPostsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No posts available at the moment'**
  String get noPostsAvailable;

  /// No description provided for @postYourFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Post your first post now!'**
  String get postYourFirstPost;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replyToPost.
  ///
  /// In en, this message translates to:
  /// **'Reply to Post'**
  String get replyToPost;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get reportPost;

  /// No description provided for @itemsFound.
  ///
  /// In en, this message translates to:
  /// **'Items Found'**
  String get itemsFound;

  /// No description provided for @itemsLost.
  ///
  /// In en, this message translates to:
  /// **'Items Lost'**
  String get itemsLost;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @userProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'User profile updated successfully'**
  String get userProfileUpdated;

  /// No description provided for @userProfileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating user profile'**
  String get userProfileUpdateError;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found matching your search criteria'**
  String get noUsersFound;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @forgotPasswordButtonText.
  ///
  /// In en, this message translates to:
  /// **'send reset link'**
  String get forgotPasswordButtonText;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get enterNewPassword;

  /// No description provided for @status_found.
  ///
  /// In en, this message translates to:
  /// **'found'**
  String get status_found;

  /// No description provided for @status_lost.
  ///
  /// In en, this message translates to:
  /// **'lost'**
  String get status_lost;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
