// lib/data/models/supplier_invoice.dart
// نموذج فاتورة المورد — أسماء الحقول تطابق قاعدة البيانات
class SupplierInvoice {
  final String id; // UUID v4
  final String supplierId;
  final String? invoiceNumber;
  final double totalAmount;
  final DateTime invoiceDate;
  final String? notes;

  // حقول مؤقتة من الربط
  final String? supplierName;

  SupplierInvoice({
    required this.id,
    required this.supplierId,
    this.invoiceNumber,
    required this.totalAmount,
    DateTime? invoiceDate,
    this.notes,
    this.supplierName,
  }) : invoiceDate = invoiceDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'invoice_date': invoiceDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory SupplierInvoice.fromMap(Map<String, dynamic> map) {
    return SupplierInvoice(
      id: map['id'] as String,
      supplierId: map['supplier_id'] as String,
      invoiceNumber: map['invoice_number'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      invoiceDate: DateTime.parse(map['invoice_date'] as String),
      notes: map['notes'] as String?,
      supplierName: map['supplier_name'] as String?,
    );
  }

  SupplierInvoice copyWith({
    String? id,
    String? supplierId,
    String? invoiceNumber,
    double? totalAmount,
    DateTime? invoiceDate,
    String? notes,
    String? supplierName,
  }) {
    return SupplierInvoice(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      notes: notes ?? this.notes,
      supplierName: supplierName ?? this.supplierName,
    );
  }

  @override
  String toString() => 'SupplierInvoice($supplierName: $totalAmount)';
}
