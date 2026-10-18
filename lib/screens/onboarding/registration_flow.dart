import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../theme/app_theme.dart';
import '../main/main_navigation.dart';

/// One-page business setup shown on first launch.
/// Everything here can be changed later in Settings.
class RegistrationFlow extends StatefulWidget {
  const RegistrationFlow({super.key});

  @override
  State<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _taxId = TextEditingController();
  final _iban = TextEditingController();
  final _bic = TextEditingController();
  final _bankName = TextEditingController();
  bool _isKleinunternehmer = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _city,
      _email,
      _phone,
      _taxId,
      _iban,
      _bic,
      _bankName
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _optional(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<BusinessProvider>().registerBusiness(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
          country: 'Deutschland',
          taxId: _optional(_taxId),
          isKleinunternehmer: _isKleinunternehmer,
          bankName: _optional(_bankName),
          iban: _optional(_iban),
          bic: _optional(_bic),
        );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {bool required = false, TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          helperText: hint,
        ),
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? 'required'.tr : null
            : null,
      ),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(
            top: AppTheme.spacingS, bottom: AppTheme.spacingM),
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: Text('setup_title'.tr)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            Text('setup_intro'.tr,
                style: const TextStyle(color: AppTheme.textSecondaryColor)),
            const SizedBox(height: AppTheme.spacingL),
            _heading('business'.tr),
            _field(_name, 'business_name'.tr, required: true),
            _field(_address, 'street_address'.tr, required: true),
            _field(_city, 'postcode_city'.tr, required: true),
            _field(_email, 'email'.tr,
                required: true, keyboardType: TextInputType.emailAddress),
            _field(_phone, 'phone'.tr, keyboardType: TextInputType.phone),
            _heading('tax'.tr),
            _field(_taxId, 'tax_id'.tr, hint: 'tax_id_hint'.tr),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('kleinunternehmer'.tr),
              subtitle: Text('kleinunternehmer_hint'.tr),
              value: _isKleinunternehmer,
              onChanged: (value) => setState(() => _isKleinunternehmer = value),
            ),
            const SizedBox(height: AppTheme.spacingM),
            _heading('bank_details'.tr),
            _field(_iban, 'iban'.tr),
            _field(_bic, 'bic'.tr),
            _field(_bankName, 'bank_name'.tr),
            const SizedBox(height: AppTheme.spacingM),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              ),
              child: Text('setup_done'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
