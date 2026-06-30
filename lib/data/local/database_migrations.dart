// lib/data/local/database_migrations.dart
// منطق ترقية مخطط قاعدة البيانات — ملف مستقل لأنه سيُستخدم كثيراً بعد الإطلاق
// كل إصدار جديد يضيف دالة migrateToVX
import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  /// إنشاء الجداول في الإصدار الأول
  static Future<void> createV1(Database db) async {
    // جدول المستخدمين — UUID v4 كمفتاح أساسي (متوافق مع Firebase)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        phone TEXT NOT NULL,
        shop_name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        last_synced_at TEXT
      )
    ''');

    // جدول المنتجات
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sell_price REAL NOT NULL,
        cost_price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        expiry_date TEXT,
        supplier_id TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
      )
    ''');

    // جدول الزبائن
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        total_debt REAL NOT NULL DEFAULT 0
      )
    ''');

    // جدول الموردين
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT
      )
    ''');

    // جدول المبيعات
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        customer_id TEXT,
        total_amount REAL NOT NULL,
        sale_type TEXT NOT NULL,
        notes TEXT,
        sale_date TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
      )
    ''');

    // جدول بنود المبيعات
    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
      )
    ''');

    // جدول معاملات الديون
    await db.execute('''
      CREATE TABLE debt_transactions (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        amount REAL NOT NULL,
        transaction_type TEXT NOT NULL,
        sale_id TEXT,
        notes TEXT,
        transaction_date TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE SET NULL
      )
    ''');

    // جدول فواتير الموردين
    await db.execute('''
      CREATE TABLE supplier_invoices (
        id TEXT PRIMARY KEY,
        supplier_id TEXT NOT NULL,
        invoice_number TEXT,
        total_amount REAL NOT NULL,
        invoice_date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
      )
    ''');

    // جدول إعدادات التطبيق
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        sync_status TEXT DEFAULT 'pending',
        last_synced_at TEXT
      )
    ''');
  }

  /// إنشاء الفهارس لتحسين الأداء
  static Future<void> createIndexes(Database db) async {
    // فهارس customer_id
    await db.execute('CREATE INDEX idx_sales_customer ON sales(customer_id)');
    await db.execute('CREATE INDEX idx_debt_customer ON debt_transactions(customer_id)');

    // فهارس product_id
    await db.execute('CREATE INDEX idx_sale_items_product ON sale_items(product_id)');
    await db.execute('CREATE INDEX idx_sale_items_sale ON sale_items(sale_id)');

    // فهارس التواريخ
    await db.execute('CREATE INDEX idx_sales_date ON sales(sale_date)');
    await db.execute('CREATE INDEX idx_debt_date ON debt_transactions(transaction_date)');

    // فهارس بحث
    await db.execute('CREATE INDEX idx_customers_name ON customers(name)');
    await db.execute('CREATE INDEX idx_products_name ON products(name)');
  }

  /// الترقية بين الإصدارات
  static Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await migrateToV2(db);
    }
    // if (oldVersion < 3) { await migrateToV3(db); }
  }

  /// ترقية إلى الإصدار 2 — مثال للمستقبل
  static Future<void> migrateToV2(Database db) async {
    // مثال: إضافة عمود جديد
    // await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT');
    // await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
  }
}
