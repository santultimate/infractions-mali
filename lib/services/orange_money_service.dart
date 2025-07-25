import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/orange_money_payment.dart';

class OrangeMoneyService {
  static const String _storageKey = 'orange_money_payments';
  late OrangeMoneyConfig _config;
  final http.Client _httpClient = http.Client();

  OrangeMoneyService({OrangeMoneyConfig? config}) {
    _config = config ?? OrangeMoneyConfig.development();
  }

  // Initialiser le service
  Future<void> initialize() async {
    // Vérifier la connectivité
    await _checkConnectivity();
    print(
        'Orange Money Service initialisé: ${_config.isProduction ? "Production" : "Développement"}');
  }

  // Vérifier la connectivité
  Future<bool> _checkConnectivity() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('${_config.baseUrl}/health'),
            headers: _getHeaders(),
          )
          .timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur de connectivité Orange Money: $e');
      return false;
    }
  }

  // Effectuer un paiement
  Future<PaymentResponse> initiatePayment(PaymentRequest request) async {
    try {
      // Validation de la requête
      if (!_validatePaymentRequest(request)) {
        return PaymentResponse(
          success: false,
          message: 'Données de paiement invalides',
          errorCode: 'INVALID_REQUEST',
        );
      }

      // Préparer les données de paiement
      final paymentData = {
        ...request.toJson(),
        'merchantId': _config.merchantId,
        'callbackUrl': _config.callbackUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Appel API Orange Money
      final response = await _httpClient
          .post(
            Uri.parse('${_config.baseUrl}/payment/initiate'),
            headers: _getHeaders(),
            body: json.encode(paymentData),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final paymentResponse = PaymentResponse.fromJson(responseData);

        if (paymentResponse.success) {
          // Sauvegarder le paiement localement
          await _savePayment(OrangeMoneyPayment(
            id: paymentResponse.transactionId ?? _generateId(),
            phoneNumber: request.phoneNumber,
            amount: request.amount,
            description: request.description,
            status: PaymentStatus.pending,
            createdAt: DateTime.now(),
          ));
        }

        return paymentResponse;
      } else {
        return PaymentResponse(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
          errorCode: 'SERVER_ERROR',
        );
      }
    } catch (e) {
      print('Erreur lors de l\'initiation du paiement: $e');
      return PaymentResponse(
        success: false,
        message: 'Erreur de connexion',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  // Vérifier le statut d'un paiement
  Future<PaymentResponse> checkPaymentStatus(String transactionId) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('${_config.baseUrl}/payment/status/$transactionId'),
            headers: _getHeaders(),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final paymentResponse = PaymentResponse.fromJson(responseData);

        if (paymentResponse.success) {
          // Mettre à jour le statut local
          await _updatePaymentStatus(transactionId, responseData['status']);
        }

        return paymentResponse;
      } else {
        return PaymentResponse(
          success: false,
          message: 'Erreur lors de la vérification du statut',
          errorCode: 'STATUS_CHECK_ERROR',
        );
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut: $e');
      return PaymentResponse(
        success: false,
        message: 'Erreur de connexion',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  // Annuler un paiement
  Future<PaymentResponse> cancelPayment(String transactionId) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('${_config.baseUrl}/payment/cancel'),
            headers: _getHeaders(),
            body: json.encode({
              'transactionId': transactionId,
              'merchantId': _config.merchantId,
            }),
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final paymentResponse = PaymentResponse.fromJson(responseData);

        if (paymentResponse.success) {
          // Mettre à jour le statut local
          await _updatePaymentStatus(transactionId, 'cancelled');
        }

        return paymentResponse;
      } else {
        return PaymentResponse(
          success: false,
          message: 'Erreur lors de l\'annulation',
          errorCode: 'CANCEL_ERROR',
        );
      }
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      return PaymentResponse(
        success: false,
        message: 'Erreur de connexion',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  // Récupérer l'historique des paiements
  Future<List<OrangeMoneyPayment>> getPaymentHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = prefs.getStringList(_storageKey) ?? [];

      return paymentsJson
          .map((json) => OrangeMoneyPayment.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Effectuer un paiement de don (simplifié)
  Future<PaymentResponse> makeDonation({
    required String phoneNumber,
    required double amount,
    String description = 'Don pour Infractions Mali',
  }) async {
    final request = PaymentRequest(
      phoneNumber: phoneNumber,
      amount: amount,
      description: description,
      reference: 'DON_${DateTime.now().millisecondsSinceEpoch}',
      metadata: {
        'type': 'donation',
        'app': 'infractions_mali',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    return await initiatePayment(request);
  }

  // Validation de la requête de paiement
  bool _validatePaymentRequest(PaymentRequest request) {
    // Valider le numéro de téléphone (format Mali)
    if (!_isValidMaliPhoneNumber(request.phoneNumber)) {
      return false;
    }

    // Valider le montant
    if (request.amount <= 0 || request.amount > 1000000) {
      return false;
    }

    // Valider la description
    if (request.description.isEmpty || request.description.length > 100) {
      return false;
    }

    return true;
  }

  // Valider le format du numéro de téléphone Mali
  bool _isValidMaliPhoneNumber(String phoneNumber) {
    // Format Mali: +223XXXXXXXX ou 223XXXXXXXX ou 0XXXXXXXX
    final regex = RegExp(r'^(\+223|223|0)[0-9]{8}$');
    return regex.hasMatch(phoneNumber);
  }

  // Normaliser le numéro de téléphone
  String _normalizePhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return '+223${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('223')) {
      return '+$phoneNumber';
    }
    return phoneNumber;
  }

  // Générer un ID unique
  String _generateId() {
    return 'om_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Obtenir les en-têtes HTTP
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_config.apiKey}',
      'X-Merchant-ID': _config.merchantId,
      'User-Agent': 'InfractionsMali/1.0',
    };
  }

  // Sauvegarder un paiement localement
  Future<void> _savePayment(OrangeMoneyPayment payment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = prefs.getStringList(_storageKey) ?? [];

      paymentsJson.add(jsonEncode(payment.toJson()));

      // Garder seulement les 100 derniers paiements
      if (paymentsJson.length > 100) {
        paymentsJson.removeRange(0, paymentsJson.length - 100);
      }

      await prefs.setStringList(_storageKey, paymentsJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde du paiement: $e');
    }
  }

  // Mettre à jour le statut d'un paiement
  Future<void> _updatePaymentStatus(String transactionId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = prefs.getStringList(_storageKey) ?? [];

      for (int i = 0; i < paymentsJson.length; i++) {
        final paymentData = jsonDecode(paymentsJson[i]);
        if (paymentData['id'] == transactionId ||
            paymentData['transactionId'] == transactionId) {
          paymentData['status'] = status;
          if (status == 'completed') {
            paymentData['completedAt'] = DateTime.now().toIso8601String();
          }
          paymentsJson[i] = jsonEncode(paymentData);
          break;
        }
      }

      await prefs.setStringList(_storageKey, paymentsJson);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Simuler un paiement (pour le développement)
  Future<PaymentResponse> simulatePayment(PaymentRequest request) async {
    await Future.delayed(Duration(seconds: 2)); // Simulation du délai réseau

    final transactionId = _generateId();
    final success = Random().nextBool(); // 80% de succès

    if (success) {
      // Sauvegarder le paiement simulé
      await _savePayment(OrangeMoneyPayment(
        id: transactionId,
        phoneNumber: request.phoneNumber,
        amount: request.amount,
        description: request.description,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        transactionId: transactionId,
      ));

      return PaymentResponse(
        success: true,
        transactionId: transactionId,
        message: 'Paiement simulé avec succès',
      );
    } else {
      return PaymentResponse(
        success: false,
        message: 'Paiement simulé échoué',
        errorCode: 'SIMULATION_FAILED',
      );
    }
  }

  // Nettoyer les ressources
  void dispose() {
    _httpClient.close();
  }
}
