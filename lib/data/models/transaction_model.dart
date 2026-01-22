class TransactionModel {
  final String id;
  final String documentNumber;
  final String title;
  final double amount;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final String? description;
  final String? requesterName;
  final String? department;

  TransactionModel({
    required this.id,
    required this.documentNumber,
    required this.title,
    required this.amount,
    this.status = 'pending',
    required this.createdAt,
    this.description,
    this.requesterName,
    this.department,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      documentNumber: json['document_number'] ?? json['no_document'] ?? '',
      title: json['title'] ?? json['keterangan'] ?? '',
      amount: _parseAmount(json['amount'] ?? json['rp']),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      description: json['description'],
      requesterName: json['requester_name'] ?? json['nama'],
      department: json['department'],
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_number': documentNumber,
      'title': title,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'requester_name': requesterName,
      'department': department,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? documentNumber,
    String? title,
    double? amount,
    String? status,
    DateTime? createdAt,
    String? description,
    String? requesterName,
    String? department,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      requesterName: requesterName ?? this.requesterName,
      department: department ?? this.department,
    );
  }

  /// Format amount ke Rupiah (Rp 100.000.000)
  String get formattedAmount {
    return 'Rp ${_formatNumber(amount)}';
  }

  String _formatNumber(double number) {
    String numStr = number.toStringAsFixed(0);
    String result = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      count++;
      result = numStr[i] + result;
      if (count % 3 == 0 && i > 0) {
        result = '.$result';
      }
    }
    return result;
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}
