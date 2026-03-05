import json

en_dict = {
  "@@locale": "en",
  "appTitle": "Green Share",
  "profile": "Profile",
  "donorProfile": "Donor Profile",
  "pleaseLogInToViewProfile": "Please log in to view your profile.",
  "logIn": "Log In",
  "logout": "Logout",
  "languageSetting": "Language (EN/AR)",
  "transactionHistory": "Transaction History",
  "yourListings": "Your Listings",
  "reviews": "Reviews",
  "viewAll": "View All",
  "noItemsPostedYet": "No items posted yet",
  "noReviewsYet": "No reviews yet.",
  "communityMember": "Community Member",
  "given": "Given",
  "received": "Received",

  "home": "Home",
  "post": "Post",
  "chat": "Chat",
  
  "discover": "Discover",
  "list": "List",
  "map": "Map",
  "searchItems": "Search items...",
  "noItemsFound": "No items found",
  "beTheFirst": "Be the first to post a donation or request!",
  "locationDisabled": "Location services are disabled.",
  "locationDenied": "Location permission denied.",
  "locationPermDenied": "Location permissions are permanently denied.",
  "locationFailed": "Failed to get current location.",
  
  "messages": "Messages",
  "pleaseLoginToViewMessages": "Please log in to view messages.",
  "noMessagesYet": "No messages yet",
  "connectWithOthers": "Connect with others to start chatting.",
  
  "giveItemTo": "Give '{itemTitle}' to {otherUserName}?",
  "@giveItemTo": {
    "placeholders": {
        "itemTitle": { "type": "String" },
        "otherUserName": { "type": "String" }
    }
  },
  "award": "Award",
  "rateAndReviewTitle": "Rate & Review {otherUserName} for '{itemTitle}'",
  "@rateAndReviewTitle": {
    "placeholders": {
        "otherUserName": { "type": "String" },
        "itemTitle": { "type": "String" }
    }
  },
  "review": "Review",
  "pleaseLoginToSendMessages": "Please login to send messages.",
  "startTheConversation": "Start the conversation!",
  "sayHiTo": "Say hi to {otherUserName}",
  "@sayHiTo": {
    "placeholders": {
        "otherUserName": { "type": "String" }
    }
  },
  "typeMessage": "Type a message...",
  "donateItemQ": "Donate Item?",
  "markRequestCompletedQ": "Mark Request Completed?",
  "confirmDonate": "Are you sure you want to donate this item to {otherUserName}? This will remove it from the home page.",
  "@confirmDonate": {
    "placeholders": {
        "otherUserName": { "type": "String" }
    }
  },
  "confirmComplete": "Are you sure you want to complete this request with {otherUserName}?",
  "@confirmComplete": {
    "placeholders": {
        "otherUserName": { "type": "String" }
    }
  },
  "cancel": "Cancel",
  "itemAwarded": "Item automatically awarded!",
  "yesConfirm": "Yes, confirm",
  "rateAndReview": "Rate & Review",
  "howWasExperience": "How was your experience?",
  "commentOptional": "Comment (optional)",
  "submit": "Submit",
  "reviewSubmitted": "Review submitted successfully!",
  "reviewFailed": "Failed to submit review.",
  "automatedDonateMsg": "Hi! I have officially marked this item as donated to you. Enjoy!",
  "automatedCompleteMsg": "Hi! I have officially marked this request as completed with you. Thank you!",
  
  "postItem": "Post Item",
  "readyToShare": "Ready to share?",
  "pleaseLoginToPost": "Please log in or create an account to post items.",
  "donate": "Donate",
  "request": "Request",
  "tapToAddPhoto": "Tap to add photo",
  "aiInterpreting": "AI interpreting image...",
  "title": "Title",
  "categoryAutoFilled": "Category (Auto-filled by AI)",
  "description": "Description",
  "condition": "Condition",
  "locating": "Locating...",
  "selectLocation": "Select Location",
  "locationSelected": "Location Selected",
  "gettingCurrentLocation": "Getting current location...",
  "tapToChooseOnMap": "Tap to choose on map",
  "postButton": "Post",
  "pleaseEnterTitle": "Please enter a title",
  "itemPostedSuccess": "Item posted successfully!",
  "errorPostingItem": "Error posting item: {error}",
  "@errorPostingItem": {
  	"placeholders": {
  		"error": { "type": "String" }
  	}
  },
  
  "pleaseEnterEmailPass": "Please enter both email and password",
  "errorDuringLogin": "An error occurred during login.",
  "unexpectedError": "An unexpected error: {error}",
  "@unexpectedError": {
  	"placeholders": {
  		"error": { "type": "String" }
  	}
  },
  "welcomeBack": "Welcome Back",
  "signInToAccount": "Sign in to your Green Share account",
  "email": "Email",
  "password": "Password",
  "signIn": "Sign In",
  "dontHaveAccount": "Don't have an account?",
  "signUp": "Sign up",
  "pleaseFillAllFields": "Please fill all fields",
  "signupFailed": "Signup failed",
  "createAnAccount": "Create an Account",
  "joinCommunityToday": "Join our community today",
  "fullName": "Full Name",
  "role": "Role",
  "donor": "Donor",
  "recipient": "Recipient",
  "charity": "Charity"
}

ar_dict = {
  "@@locale": "ar",
  "appTitle": "جرين شير",
  "profile": "الملف الشخصي",
  "donorProfile": "ملف المتبرع",
  "pleaseLogInToViewProfile": "يرجى تسجيل الدخول لعرض ملفك الشخصي.",
  "logIn": "تسجيل الدخول",
  "logout": "تسجيل الخروج",
  "languageSetting": "اللغة (EN/AR)",
  "transactionHistory": "سجل المعاملات",
  "yourListings": "قوائمك",
  "reviews": "التقييمات",
  "viewAll": "عرض الكل",
  "noItemsPostedYet": "لا توجد عناصر منشورة بعد",
  "noReviewsYet": "لا توجد تقييمات بعد.",
  "communityMember": "عضو في المجتمع",
  "given": "معطى",
  "received": "مستلم",

  "home": "الرئيسية",
  "post": "نشر",
  "chat": "المحادثة",
  
  "discover": "اكتشف",
  "list": "قائمة",
  "map": "خريطة",
  "searchItems": "ابحث عن العناصر...",
  "noItemsFound": "لا توجد عناصر",
  "beTheFirst": "كن أول من ينشر تبرعاً أو طلباً!",
  "locationDisabled": "تم تعطيل خدمات الموقع.",
  "locationDenied": "تم رفض إذن الموقع.",
  "locationPermDenied": "تم رفض أذونات الموقع نهائياً.",
  "locationFailed": "فشل في الحصول على الموقع الحالي.",
  
  "messages": "الرسائل",
  "pleaseLoginToViewMessages": "يرجى تسجيل الدخول لعرض الرسائل.",
  "noMessagesYet": "لا توجد رسائل بعد",
  "connectWithOthers": "تواصل مع الآخرين لبدء المحادثة.",
  
  "giveItemTo": "منح '{itemTitle}' إلى {otherUserName}؟",
  "@giveItemTo": {
    "placeholders": {
        "itemTitle": { "type": "String" },
        "otherUserName": { "type": "String" }
    }
  },
  "award": "منح",
  "rateAndReviewTitle": "تقييم ومراجعة {otherUserName} لـ '{itemTitle}'",
  "@rateAndReviewTitle": {
    "placeholders": {
        "otherUserName": { "type": "String" },
        "itemTitle": { "type": "String" }
    }
  },
  "review": "مراجعة",
  "pleaseLoginToSendMessages": "يرجى تسجيل الدخول لإرسال رسائل.",
  "startTheConversation": "ابدأ المحادثة!",
  "sayHiTo": "قل مرحباً لـ {otherUserName}",
  "@sayHiTo": {
    "placeholders": {
        "otherUserName": { "type": "String" }
    }
  },
  "typeMessage": "اكتب رسالة...",
  "donateItemQ": "التبرع بالعنصر؟",
  "markRequestCompletedQ": "وضع علامة مكتمل على الطلب؟",
  "confirmDonate": "هل أنت متأكد أنك تريد التبرع بهذا العنصر إلى {otherUserName}؟ سيؤدي هذا إلى إزالته من الصفحة الرئيسية.",
  "@confirmDonate": {
    "placeholders": {
        "otherUserName": { "type": "String" }
    }
  },
  "confirmComplete": "هل أنت متأكد أنك تريد إكمال هذا الطلب مع {otherUserName}؟",
  "@confirmComplete": {
    "placeholders": {
        "otherUserName": { "type": "String" }
    }
  },
  "cancel": "إلغاء",
  "itemAwarded": "تم منح العنصر تلقائياً!",
  "yesConfirm": "نعم، تأكيد",
  "rateAndReview": "التقييم والمراجعة",
  "howWasExperience": "كيف كانت تجربتك؟",
  "commentOptional": "تعليق (اختياري)",
  "submit": "إرسال",
  "reviewSubmitted": "تم إرسال التقييم بنجاح!",
  "reviewFailed": "فشل في إرسال التقييم.",
  "automatedDonateMsg": "مرحباً! لقد قمت بوضع علامة رسمية على هذا العنصر على أنه متبرع به لك. استمتع!",
  "automatedCompleteMsg": "مرحباً! لقد قمت بوضع علامة رسمية على هذا الطلب على أنه مكتمل معك. شكراً لك!",
  
  "postItem": "نشر عنصر",
  "readyToShare": "جاهز للمشاركة؟",
  "pleaseLoginToPost": "يرجى تسجيل الدخول أو إنشاء حساب لنشر العناصر.",
  "donate": "تبرع",
  "request": "طلب",
  "tapToAddPhoto": "انقر لإضافة صورة",
  "aiInterpreting": "الذكاء الاصطناعي يحلل الصورة...",
  "title": "العنوان",
  "categoryAutoFilled": "الفئة (تعبئة تلقائية بالذكاء الاصطناعي)",
  "description": "الوصف",
  "condition": "الحالة",
  "locating": "جاري تحديد الموقع...",
  "selectLocation": "اختر الموقع",
  "locationSelected": "تم تحديد الموقع",
  "gettingCurrentLocation": "الحصول على الموقع الحالي...",
  "tapToChooseOnMap": "انقر للاختيار على الخريطة",
  "postButton": "نشر",
  "pleaseEnterTitle": "يرجى إدخال عنوان",
  "itemPostedSuccess": "تم نشر العنصر بنجاح!",
  "errorPostingItem": "خطأ في نشر العنصر: {error}",
  "@errorPostingItem": {
  	"placeholders": {
  		"error": { "type": "String" }
  	}
  },
  
  "pleaseEnterEmailPass": "يرجى إدخال البريد الإلكتروني وكلمة المرور",
  "errorDuringLogin": "حدث خطأ أثناء تسجيل الدخول.",
  "unexpectedError": "حدث خطأ غير متوقع: {error}",
  "@unexpectedError": {
  	"placeholders": {
  		"error": { "type": "String" }
  	}
  },
  "welcomeBack": "مرحباً بعودتك",
  "signInToAccount": "قم بتسجيل الدخول إلى حساب Green Share الخاص بك",
  "email": "البريد الإلكتروني",
  "password": "كلمة المرور",
  "signIn": "تسجيل الدخول",
  "dontHaveAccount": "ليس لديك حساب؟",
  "signUp": "إنشاء حساب",
  "pleaseFillAllFields": "الرجاء تعبئة جميع الحقول",
  "signupFailed": "فشل التسجيل",
  "createAnAccount": "إنشاء حساب",
  "joinCommunityToday": "انضم إلى مجتمعنا اليوم",
  "fullName": "الاسم الكامل",
  "role": "الدور",
  "donor": "متبرع",
  "recipient": "مستلم",
  "charity": "جمعية خيرية"
}

with open('c:/uni-projects/greenshare1/lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(en_dict, f, ensure_ascii=False, indent=2)

with open('c:/uni-projects/greenshare1/lib/l10n/app_ar.arb', 'w', encoding='utf-8') as f:
    json.dump(ar_dict, f, ensure_ascii=False, indent=2)
