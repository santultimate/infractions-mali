import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/orange_money_payment.dart';
import '../services/orange_money_service.dart';
import 'package:easy_localization/easy_localization.dart';

class OrangeMoneyDonationDialog extends StatefulWidget {
  final OrangeMoneyService orangeMoneyService;

  const OrangeMoneyDonationDialog({
    required this.orangeMoneyService,
  });

  @override
  _OrangeMoneyDonationDialogState createState() =>
      _OrangeMoneyDonationDialogState();
}

class _OrangeMoneyDonationDialogState extends State<OrangeMoneyDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isProcessing = false;
  bool _isSimulationMode = true; // Mode simulation par défaut
  String? _selectedAmount;

  final List<String> _presetAmounts = ['500', '1000', '2000', '5000', '10000'];

  @override
  void initState() {
    super.initState();
    _phoneController.text =
        '+223 76 03 91 92'; // Numéro par défaut avec espaces
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.volunteer_activism, color: Colors.orange),
          SizedBox(width: 8),
          Text(tr('donation')),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode simulation
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr('simulation_mode_enabled'),
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isSimulationMode,
                      onChanged: (value) {
                        setState(() {
                          _isSimulationMode = value;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Numéro de téléphone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: tr('orange_money_number'),
                  hintText: tr('orange_money_number_hint'),
                  prefixIcon: Icon(Icons.phone, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return tr('please_enter_a_number');
                  }
                  // Nettoyer les espaces avant validation
                  final cleanNumber = value.replaceAll(' ', '');
                  if (!_isValidMaliPhoneNumber(cleanNumber)) {
                    return tr('invalid_number_format');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Montants prédéfinis
              Text(
                tr('donation_amount'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetAmounts.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAmount = amount;
                        _amountController.text = amount;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.orange : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? Colors.orange : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '$amount FCFA',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Montant personnalisé
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: tr('custom_amount'),
                  hintText: tr('enter_an_amount'),
                  prefixIcon: Icon(Icons.money, color: Colors.orange),
                  suffixText: tr('fcfa'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return tr('please_enter_an_amount');
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return tr('invalid_amount');
                  }
                  if (amount > 1000000) {
                    return tr('amount_too_high');
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('description'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      tr('donation_description'),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: Text(tr('cancel')),
        ),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _processDonation,
          icon: _isProcessing
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(Icons.payment),
          label: Text(tr(_isProcessing ? 'processing' : 'donate')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Nettoyer le numéro de téléphone en supprimant les espaces
      final phoneNumber = _phoneController.text.replaceAll(' ', '');
      final amount = double.parse(_amountController.text.trim());

      PaymentResponse response;

      if (_isSimulationMode) {
        // Mode simulation
        final request = PaymentRequest(
          phoneNumber: phoneNumber,
          amount: amount,
          description: tr('donation_description'),
        );
        response = await widget.orangeMoneyService.simulatePayment(request);
      } else {
        // Mode réel
        response = await widget.orangeMoneyService.makeDonation(
          phoneNumber: phoneNumber,
          amount: amount,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();

        // Afficher le résultat
        _showResultDialog(response);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('error', namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showResultDialog(PaymentResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              response.success ? Icons.check_circle : Icons.error,
              color: response.success ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            Text(response.success ? tr('success') : tr('error')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(response.message ?? ''),
            if (response.transactionId != null) ...[
              SizedBox(height: 8),
              Text(
                tr('transaction_id'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText(
                response.transactionId!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('close')),
          ),
        ],
      ),
    );
  }

  bool _isValidMaliPhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^(\+223|223|0)[0-9]{8}$');
    return regex.hasMatch(phoneNumber);
  }
}
