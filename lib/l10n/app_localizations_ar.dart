// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'جرين شير';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get donorProfile => 'ملف المتبرع';

  @override
  String get pleaseLogInToViewProfile => 'يرجى تسجيل الدخول لعرض ملفك الشخصي.';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get languageSetting => 'اللغة (EN/AR)';

  @override
  String get transactionHistory => 'سجل المعاملات';

  @override
  String get yourListings => 'قوائمك';

  @override
  String get reviews => 'التقييمات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noItemsPostedYet => 'لا توجد عناصر منشورة بعد';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد.';

  @override
  String get communityMember => 'عضو في المجتمع';

  @override
  String get given => 'معطى';

  @override
  String get received => 'مستلم';

  @override
  String get home => 'الرئيسية';

  @override
  String get post => 'نشر';

  @override
  String get chat => 'المحادثة';

  @override
  String get discover => 'اكتشف';

  @override
  String get list => 'قائمة';

  @override
  String get map => 'خريطة';

  @override
  String get searchItems => 'ابحث عن العناصر...';

  @override
  String get noItemsFound => 'لا توجد عناصر';

  @override
  String get beTheFirst => 'كن أول من ينشر تبرعاً أو طلباً!';

  @override
  String get locationDisabled => 'تم تعطيل خدمات الموقع.';

  @override
  String get locationDenied => 'تم رفض إذن الموقع.';

  @override
  String get locationPermDenied => 'تم رفض أذونات الموقع نهائياً.';

  @override
  String get locationFailed => 'فشل في الحصول على الموقع الحالي.';

  @override
  String get messages => 'الرسائل';

  @override
  String get pleaseLoginToViewMessages => 'يرجى تسجيل الدخول لعرض الرسائل.';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get connectWithOthers => 'تواصل مع الآخرين لبدء المحادثة.';

  @override
  String giveItemTo(String itemTitle, String otherUserName) {
    return 'منح \'$itemTitle\' إلى $otherUserName؟';
  }

  @override
  String get award => 'منح';

  @override
  String rateAndReviewTitle(String otherUserName, String itemTitle) {
    return 'تقييم ومراجعة $otherUserName لـ \'$itemTitle\'';
  }

  @override
  String get review => 'مراجعة';

  @override
  String get pleaseLoginToSendMessages => 'يرجى تسجيل الدخول لإرسال رسائل.';

  @override
  String get startTheConversation => 'ابدأ المحادثة!';

  @override
  String sayHiTo(String otherUserName) {
    return 'قل مرحباً لـ $otherUserName';
  }

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get donateItemQ => 'التبرع بالعنصر؟';

  @override
  String get markRequestCompletedQ => 'وضع علامة مكتمل على الطلب؟';

  @override
  String confirmDonate(String otherUserName) {
    return 'هل أنت متأكد أنك تريد التبرع بهذا العنصر إلى $otherUserName؟ سيؤدي هذا إلى إزالته من الصفحة الرئيسية.';
  }

  @override
  String confirmComplete(String otherUserName) {
    return 'هل أنت متأكد أنك تريد إكمال هذا الطلب مع $otherUserName؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get itemAwarded => 'تم منح العنصر تلقائياً!';

  @override
  String get yesConfirm => 'نعم، تأكيد';

  @override
  String get rateAndReview => 'التقييم والمراجعة';

  @override
  String get howWasExperience => 'كيف كانت تجربتك؟';

  @override
  String get commentOptional => 'تعليق (اختياري)';

  @override
  String get submit => 'إرسال';

  @override
  String get reviewSubmitted => 'تم إرسال التقييم بنجاح!';

  @override
  String get reviewFailed => 'فشل في إرسال التقييم.';

  @override
  String get automatedDonateMsg =>
      'مرحباً! لقد قمت بوضع علامة رسمية على هذا العنصر على أنه متبرع به لك. استمتع!';

  @override
  String get automatedCompleteMsg =>
      'مرحباً! لقد قمت بوضع علامة رسمية على هذا الطلب على أنه مكتمل معك. شكراً لك!';

  @override
  String get postItem => 'نشر عنصر';

  @override
  String get readyToShare => 'جاهز للمشاركة؟';

  @override
  String get pleaseLoginToPost =>
      'يرجى تسجيل الدخول أو إنشاء حساب لنشر العناصر.';

  @override
  String get donate => 'تبرع';

  @override
  String get request => 'طلب';

  @override
  String get tapToAddPhoto => 'انقر لإضافة صورة';

  @override
  String get aiInterpreting => 'الذكاء الاصطناعي يحلل الصورة...';

  @override
  String get title => 'العنوان';

  @override
  String get categoryAutoFilled => 'الفئة (تعبئة تلقائية بالذكاء الاصطناعي)';

  @override
  String get description => 'الوصف';

  @override
  String get condition => 'الحالة';

  @override
  String get locating => 'جاري تحديد الموقع...';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get locationSelected => 'تم تحديد الموقع';

  @override
  String get gettingCurrentLocation => 'الحصول على الموقع الحالي...';

  @override
  String get tapToChooseOnMap => 'انقر للاختيار على الخريطة';

  @override
  String get postButton => 'نشر';

  @override
  String get pleaseEnterTitle => 'يرجى إدخال عنوان';

  @override
  String get itemPostedSuccess => 'تم نشر العنصر بنجاح!';

  @override
  String errorPostingItem(String error) {
    return 'خطأ في نشر العنصر: $error';
  }

  @override
  String get pleaseEnterEmailPass =>
      'يرجى إدخال البريد الإلكتروني وكلمة المرور';

  @override
  String get errorDuringLogin => 'حدث خطأ أثناء تسجيل الدخول.';

  @override
  String unexpectedError(String error) {
    return 'حدث خطأ غير متوقع: $error';
  }

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInToAccount =>
      'قم بتسجيل الدخول إلى حساب Green Share الخاص بك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get pleaseFillAllFields => 'الرجاء تعبئة جميع الحقول';

  @override
  String get signupFailed => 'فشل التسجيل';

  @override
  String get createAnAccount => 'إنشاء حساب';

  @override
  String get joinCommunityToday => 'انضم إلى مجتمعنا اليوم';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get role => 'الدور';

  @override
  String get donor => 'متبرع';

  @override
  String get recipient => 'مستلم';

  @override
  String get charity => 'جمعية خيرية';

  @override
  String get city => 'المدينة';

  @override
  String get filterOptions => 'خيارات التصفية';

  @override
  String get applyFilters => 'تطبيق التصفية';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get save => 'حفظ';

  @override
  String get name => 'الاسم';

  @override
  String get updateProfileSuccess => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String updateProfileError(String error) {
    return 'خطأ في تحديث الملف الشخصي: $error';
  }

  @override
  String get reloginRequiredForEmail =>
      'يجب تسجيل الدخول مرة أخرى لتغيير عنوان بريدك الإلكتروني.';

  @override
  String get activeListings => 'الإعلانات النشطة';

  @override
  String get signInWithPhone => 'الدخول برقم الهاتف';

  @override
  String get enterPhoneNumber => 'أدخل رقم هاتفك (مثال: 1234567890+)';

  @override
  String get phoneVerification => 'التحقق من الهاتف';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get enterOtp => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get verifyCode => 'تحقق من الرمز';

  @override
  String get invalidOtp => 'رمز التحقق غير صحيح';

  @override
  String get didNotReceiveCode => 'لم تستلم الرمز؟';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get user => 'مستخدم';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get commercialRegistration => 'رقم السجل التجاري (CR)';

  @override
  String get adminDashboard => 'لوحة تحكم المشرف';

  @override
  String get dataCenter => 'مركز البيانات';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get feedbackHub => 'مركز الملاحظات';

  @override
  String get globalActivity => 'النشاط العام';

  @override
  String get blockUser => 'حظر المستخدم';

  @override
  String get unblockUser => 'إلغاء الحظر';

  @override
  String get greenImpact => 'الأثر البيئي';

  @override
  String get totalDonations => 'إجمالي التبرعات';

  @override
  String get totalRequests => 'إجمالي الطلبات';

  @override
  String get markResolved => 'وضع كـ محلول';

  @override
  String get resolved => 'محلول';

  @override
  String get newFeedback => 'جديد';

  @override
  String get submitFeedback => 'إرسال الملاحظات';

  @override
  String get tellUsWhatYouThink => 'أخبرنا برأيك!';

  @override
  String get feedbackSubmitted => 'تم إرسال الملاحظات بنجاح.';

  @override
  String get requests => 'الطلبات';

  @override
  String get approve => 'موافقة';

  @override
  String get deny => 'رفض';

  @override
  String get pendingApproval => 'في انتظار الموافقة';

  @override
  String get noPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String get accountPendingApproval => 'حسابك في انتظار موافقة المشرف.';

  @override
  String get reportUser => 'الإبلاغ عن المستخدم';

  @override
  String get reasonForReporting => 'سبب الإبلاغ';

  @override
  String get reportSubmitted => 'تم إرسال البلاغ بنجاح.';

  @override
  String get reports => 'بلاغات المستخدمين';

  @override
  String get reporter => 'المُبلِغ';

  @override
  String get reportedUser => 'المُبلَغ عنه';

  @override
  String get archive => 'الأرشيف';

  @override
  String get archivedRequests => 'الطلبات المحلولة';

  @override
  String get resolvedFeedback => 'الملاحظات المحلولة';

  @override
  String get resolvedReports => 'البلاغات المحلولة';

  @override
  String get approved => 'مقبول';

  @override
  String get rejected => 'مرفوض';

  @override
  String get blockedUsers => 'المستخدمين المحظورين';

  @override
  String get searchByNameOrId => 'البحث بالاسم أو المعرف';

  @override
  String get searchByItemName => 'البحث باسم العنصر';
}
