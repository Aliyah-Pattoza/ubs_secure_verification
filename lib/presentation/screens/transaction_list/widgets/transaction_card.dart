import 'package:intl/intl.dart';

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
  final String? notes;
  final String? approvedBy;
  final DateTime? approvedAt;

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
    this.notes,
    this.approvedBy,
    this.approvedAt,
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
      notes: json['notes'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
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
      'notes': notes,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
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
    String? notes,
    String? approvedBy,
    DateTime? approvedAt,
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
      notes: notes ?? this.notes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  // ================================
  // FORMATTED GETTERS
  // ================================

  /// Format amount ke Rupiah (Rp 100.000.000)
  String get formattedAmount {
    return 'Rp ${_formatNumber(amount)}';
  }

  /// Format amount compact (Rp 100M)
  String get formattedAmountCompact {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(0)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
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

  /// Format tanggal (dd MMM yyyy)
  String get formattedDate {
    try {
      return DateFormat('dd MMM yyyy').format(createdAt);
    } catch (e) {
      return '-';
    }
  }

  /// Format tanggal lengkap (dd MMM yyyy, HH:mm)
  String get formattedDateTime {
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
    } catch (e) {
      return '-';
    }
  }

  /// Format relative time (2 days ago)
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return formattedDate;
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // ================================
  // STATUS HELPERS
  // ================================

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isHighValue => amount >= 100000000; // >= 100 juta

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  // ================================
  // PRIORITY HELPERS
  // ================================

  /// Get priority level (1-3, higher = more urgent)
  int get priorityLevel {
    // High value = high priority
    if (amount >= 500000000) return 3; // >= 500 juta
    if (amount >= 100000000) return 2; // >= 100 juta
    return 1; // normal
  }

  String get priorityLabel {
    switch (priorityLevel) {
      case 3:
        return 'Critical';
      case 2:
        return 'High';
      default:
        return 'Normal';
    }
  }
}
