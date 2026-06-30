// lib/core/constants/app_strings.dart
// كل النصوص العربية بالعامية المصرية/اليمنية — لا نصوص Hardcoded أبداً في الواجهات
abstract class AppStrings {
  // عام
  static const String appName = 'دكاكين';
  static const String appNameEn = 'Dkakin';
  static const String appTagline = 'دفتر دكانك في جيبك';
  static const String ok = 'تمام';
  static const String cancel = 'إلغاء';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String search = 'بحث';
  static const String loading = 'جاري التحميل...';
  static const String error = 'حصل مشكلة!';
  static const String confirm = 'متأكد؟';
  static const String back = 'رجوع';
  static const String close = 'إقفال';
  static const String retry = 'حاول تاني';

  // Splash
  static const String splashWelcome = 'أهلاً بيك في دكاكين';

  // Auth
  static const String loginTitle = 'سجل دخولك';
  static const String registerTitle = 'حساب جديد';
  static const String phoneHint = 'رقم التليفون (مثال: 77xxxxxxx)';
  static const String shopNameHint = 'اسم الدكان';
  static const String otpTitle = 'كود التأكيد';
  static const String otpHint = 'أدخل الكود المكون من 6 أرقام';
  static const String otpVerify = 'تحقق';
  static const String otpResend = 'ابعت الكود تاني';
  static const String invalidPhone = 'رقم التليفون مش مظبوط، لازم يكون 9 أرقام على الأقل';
  static const String invalidShopName = 'اكتب اسم الدكان الأول';
  static const String invalidOtp = 'الكود لازم يكون 6 أرقام';
  static const String otpMockNote = '// TODO-PHASE2: استبدل هذا بـ Firebase Phone Auth';
  static const String userIdPrefix = '+967';

  // Home
  static const String homeTitle = 'دكان';
  static const String todaySales = 'مبيعات النهارده';
  static const String totalDebts = 'الديون على الزباين';
  static const String currencySymbol = 'ر.ي';
  static const String welcomeFirstDay = 'أهلاً بيك! اليوم أول يوم — ابدأ بإضافة منتجاتك وبعدين سجل أول بيع';
  static const String btnNewSale = 'بيع جديد';
  static const String btnDebtBook = 'دفتر الديون';
  static const String btnReports = 'الحسابات';
  static const String btnSettings = 'الإعدادات';
  static const String btnRushMode = 'وضع الزحمة';
  static const String rushModeTooltip = 'افتح البيع السريع للزباين';

  // POS
  static const String posTitle = 'نقطة البيع';
  static const String searchProduct = 'دور على منتج...';
  static const String barcodeScan = 'مسح الباركود';
  static const String topProducts = 'المنتجات الأكثر مبيعاً';
  static const String cartEmpty = 'السلة فاضية — ضف منتجات';
  static const String quantity = 'الكمية';
  static const String unitPrice = 'السعر';
  static const String total = 'المجموع';
  static const String grandTotal = 'الإجمالي الكلي';
  static const String payCash = 'كاش 💵';
  static const String payDebt = 'دين 📒';
  static const String printReceipt = 'طباعة 🖨️';
  static const String stockWarning = 'المخزون مايكفي! متاح:';
  static const String stockEmpty = 'نفدت الكمية من المخزون';
  static const String selectCustomer = 'اختار الزبون';
  static const String recentCustomers = 'آخر زباين تعاملت معاهم';
  static const String newCustomer = 'زبون جديد';
  static const String debtNoteHint = 'ملاحظة على الدين (اختياري)';
  static const String recordDebt = 'سجل الدين';
  static const String saleSuccess = 'تم البيع بنجاح!';
  static const String debtRecorded = 'تم تسجيل الدين';
  static const String sendStatement = 'أرسل كشف للزبون؟';
  static const String viaWhatsapp = 'واتساب';
  static const String viaSms = 'SMS';
  static const String noThanks = 'لا شكراً';
  static const String trialLimitSale = 'وصلت للحد الأقصى لعمليات البيع (30). فعّل التطبيق للمتابعة.';

  // Debts
  static const String debtsTitle = 'دفتر الديون';
  static const String noCustomers = 'لسه مفيش زباين، دوس على + لإضافة أول زبون';
  static const String addCustomer = 'إضافة زبون';
  static const String customerNameHint = 'اسم الزبون';
  static const String customerPhoneHint = 'رقم الزبون (اختياري)';
  static const String sortByDebt = 'الأكثر ديناً';
  static const String sortByRecent = 'الأحدث تعامل';
  static const String sortByName = 'أبجدي';
  static const String trialLimitCustomer = 'وصلت للحد الأقصى للزباين (5). فعّل التطبيق للمتابعة.';

  // Customer Detail
  static const String customerDetailTitle = 'تفاصيل الزبون';
  static const String totalDebt = 'إجمالي الدين';
  static const String debtHistory = 'سجل العمليات';
  static const String recordPayment = 'تسجيل سداد ✅';
  static const String paymentAmountHint = 'مبلغ السداد';
  static const String paymentExceedsDebt = 'مبلغ السداد أكبر من الدين! أدخل مبلغ أقل أو يساوي';
  static const String undoLast = 'تراجع عن آخر عملية';
  static const String undoAvailable = 'متاح للتراجع لـ';
  static const String undoSeconds = 'ثانية';
  static const String sendStatementBtn = 'إرسال الكشف 📤';
  static const String statementHeader = 'عزيزي';
  static const String statementShop = 'مشترياتك النهارده من دكان';
  static const String statementPrevDebt = 'الدين السابق';
  static const String statementNewDebt = 'الدين الجديد';
  static const String statementTotal = 'إجمالي المطلوب';
  static const String statementThanks = 'شكراً لثقتك.';
  static const String transactionDebt = 'دين';
  static const String transactionPayment = 'سداد';

  // Suppliers
  static const String suppliersTitle = 'الموردين';
  static const String noSuppliers = 'لسه مفيش موردين، دوس على + لإضافة أول مورد';
  static const String addSupplier = 'إضافة مورد';
  static const String supplierNameHint = 'اسم المورد';
  static const String supplierPhoneHint = 'رقم المورد';
  static const String supplierNotesHint = 'ملاحظات';
  static const String supplierDetailTitle = 'تفاصيل المورد';
  static const String totalPurchases = 'إجمالي المشتريات';
  static const String invoicesHistory = 'سجل الفواتير';
  static const String addInvoice = 'سجل فاتورة جديدة';
  static const String invoiceAmountHint = 'قيمة الفاتورة';
  static const String invoiceNumberHint = 'رقم الفاتورة (اختياري)';
  static const String trialLimitSupplier = 'وصلت للحد الأقصى للموردين (5). فعّل التطبيق للمتابعة.';

  // Reports
  static const String reportsTitle = 'الحسابات والتقارير';
  static const String netProfit = 'صافي الربح';
  static const String cashSales = 'مبيعات كاش';
  static const String newDebts = 'ديون جديدة';
  static const String collectedPayments = 'سداد محصل';
  static const String last7Days = 'آخر 7 أيام';
  static const String noDataYet = 'لسه مفيش بيانات كفاية — رجع بعد ما تسجل مبيعات';
  static const String profitFormulaNote = '// صافي الربح = (مبيعات كاش + مسددات) - تكلفة البضاعة المباعة';

  // Products
  static const String productsTitle = 'المنتجات';
  static const String noProducts = 'لسه مفيش منتجات، دوس على + لإضافة أول منتج';
  static const String addProduct = 'إضافة منتج';
  static const String productNameHint = 'اسم المنتج';
  static const String sellPriceHint = 'سعر البيع';
  static const String costPriceHint = 'سعر التكلفة';
  static const String quantityHint = 'الكمية في المخزن';
  static const String expiryDateHint = 'تاريخ الانتهاء (اختياري)';
  static const String selectSupplier = 'اختار المورد (اختياري)';
  static const String priceWarning = 'سعر البيع أقل من سعر التكلفة! متأكد؟';
  static const String expiryWarning = '⚠️ على وشك الانتهاء!';
  static const String expiredWarning = '⚠️ منتهي الصلاحية!';
  static const String trialLimitProduct = 'وصلت للحد الأقصى للمنتجات (10). فعّل التطبيق للمتابعة.';

  // Settings
  static const String settingsTitle = 'الإعدادات';
  static const String shopInfo = 'بيانات الدكان';
  static const String printerSection = 'الطابعة';
  static const String connectPrinter = 'اقتران بالطابعة البلوتوث';
  static const String printerConnected = 'متصل';
  static const String printerDisconnected = 'غير متصل';
  static const String backupSection = 'النسخ الاحتياطي';
  static const String autoLocalBackup = 'نسخ محلي تلقائي يومي';
  static const String linkGoogleDrive = 'ربط قوقل درايف';
  static const String lastCloudBackup = 'آخر نسخة سحابية';
  static const String backupNow = 'نسخ الآن';
  static const String restoreBackup = 'استعادة النسخة';
  static const String restoreConfirm = 'هذه العملية هتحذف البيانات الحالية وتستبدلها بالنسخة. متأكد؟';
  static const String activationSection = 'حالة التفعيل';
  static const String trialActive = 'فترة تجريبية';
  static const String trialRemaining = 'المتبقي';
  static const String fullyActivated = 'مفعّل بالكامل';
  static const String supportWhatsapp = 'دعم واتساب';
  static const String logout = 'تسجيل الخروج';

  // Activation
  static const String activationTitle = 'تفعيل التطبيق';
  static const String activationMessage = 'وصلت للحد الأقصى لـ';
  static const String activationRequired = 'أدخل كود التفعيل للمتابعة';
  static const String codeHint = 'XXXX-XXXX-XXXX';
  static const String activate = 'فعّل';
  static const String verifying = 'جاري التحقق...';
  static const String invalidCode = 'الكود غير صحيح، حاول تاني';
  static const String activationSuccess = 'تم التفعيل بنجاح! 🎉';
  static const String requestCode = 'اطلب الكود عبر واتساب';
  static const String requestCodeMessage = 'السلام عليكم، أرغب في طلب كود تفعيل لتطبيق دكاكين. رقم جهازي:';

  // Accessibility
  static const String a11ySalesIcon = 'أيقونة عربة التسوق';
  static const String a11yDebtIcon = 'أيقونة دفتر';
  static const String a11yReportIcon = 'أيقونة رسم بياني';
  static const String a11ySettingsIcon = 'أيقونة ترس';
  static const String a11yRushIcon = 'أيقونة برق';

  // Error messages
  static const String dbError = 'مشكلة في قاعدة البيانات. جرب تاني.';
  static const String genericError = 'حاجة حصلت ومش عارفين ايه. جرب تاني.';
  static const String cameraNotAvailable = 'الكاميرا مش متاحة — ادخل الكود يدوي';
  static const String bluetoothNotAvailable = 'البلوتوث مش متاح — اتأكد من تشغيله';
  static const String noWhatsapp = 'واتساب مش مثبت — هنفتح SMS بداله';

  // Trial limits display
  static const String limitCustomers = 'الزباين';
  static const String limitProducts = 'المنتجات';
  static const String limitSuppliers = 'الموردين';
  static const String limitSales = 'عمليات البيع';
  static const String limitMessages = 'الرسائل';
}
