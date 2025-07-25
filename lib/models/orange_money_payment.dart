// Modèles pour l'API Orange Money Mali

class OrangeMoneyPayment {
  final String id;
  final String phoneNumber;
  final double amount;
  final String currency;
  final String description;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? errorMessage;

  OrangeMoneyPayment({
    required this.id,
    required this.phoneNumber,
    required this.amount,
    this.currency = 'XOF',
    required this.description,
    this.status = PaymentStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.transactionId,
    this.errorMessage,
  });

  factory OrangeMoneyPayment.fromJson(Map<String, dynamic> json) {
    return OrangeMoneyPayment(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'XOF',
      description: json['description'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      transactionId: json['transactionId'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'amount': amount,
      'currency': currency,
      'description': description,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'errorMessage': errorMessage,
    };
  }

  OrangeMoneyPayment copyWith({
    String? id,
    String? phoneNumber,
    double? amount,
    String? currency,
    String? description,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionId,
    String? errorMessage,
  }) {
    return OrangeMoneyPayment(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionId: transactionId ?? this.transactionId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class OrangeMoneyConfig {
  final String apiKey;
  final String merchantId;
  final String baseUrl;
  final String callbackUrl;
  final bool isProduction;

  OrangeMoneyConfig({
    required this.apiKey,
    required this.merchantId,
    required this.baseUrl,
    required this.callbackUrl,
    this.isProduction = false,
  });

  // Configuration pour le développement
  static OrangeMoneyConfig development() {
    return OrangeMoneyConfig(
      apiKey: 'dev_api_key_123456',
      merchantId: 'dev_merchant_123',
      baseUrl: 'https://api-sandbox.orange-money.ml',
      callbackUrl: 'https://your-app.com/callback',
      isProduction: false,
    );
  }

  // Configuration pour la production
  static OrangeMoneyConfig production() {
    return OrangeMoneyConfig(
      apiKey: 'prod_api_key_789012',
      merchantId: 'prod_merchant_456',
      baseUrl: 'https://api.orange-money.ml',
      callbackUrl: 'https://your-app.com/callback',
      isProduction: true,
    );
  }
}

class PaymentRequest {
  final String phoneNumber;
  final double amount;
  final String description;
  final String? reference;
  final Map<String, dynamic>? metadata;

  PaymentRequest({
    required this.phoneNumber,
    required this.amount,
    required this.description,
    this.reference,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'amount': amount,
      'description': description,
      'reference':
          reference ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'metadata': metadata ?? {},
    };
  }
}

class PaymentResponse {
  final bool success;
  final String? transactionId;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? data;

  PaymentResponse({
    required this.success,
    this.transactionId,
    this.message,
    this.errorCode,
    this.data,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      transactionId: json['transactionId'],
      message: json['message'],
      errorCode: json['errorCode'],
      data: json['data'],
    );
  }
}
