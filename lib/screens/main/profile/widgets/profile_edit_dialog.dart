import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../models/business.dart';
import '../../../../providers/business_provider.dart';
import '../../../../theme/app_theme.dart';

class ProfileEditDialog extends StatefulWidget {
  final Business business;

  const ProfileEditDialog({super.key, required this.business});

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.business.name);
  late final _email = TextEditingController(text: widget.business.email);
  late final _phone = TextEditingController(text: widget.business.phone);
  late final _address = TextEditingController(text: widget.business.address);
  late final _city = TextEditingController(text: widget.business.city);
  late final _country = TextEditingController(text: widget.business.country);
  late final _website =
      TextEditingController(text: widget.business.website ?? '');
  late final _taxId = TextEditingController(text: widget.business.taxId ?? '');
  late final _bankName =
      TextEditingController(text: widget.business.bankName ?? '');
  late final _iban = TextEditingController(text: widget.business.iban ?? '');
  late final _bic = TextEditingController(text: widget.business.bic ?? '');
  late String? _logo = widget.business.logoPath;
  late bool _isKleinunternehmer = widget.business.isKleinunternehmer;

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _phone,
      _address,
      _city,
      _country,
      _website,
      _taxId,
      _bankName,
      _iban,
      _bic
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null) return;
    final logo = base64Encode(await image.readAsBytes());
    setState(() => _logo = logo);
  }

  String? _optional(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context
        .read<BusinessProvider>()
        .updateBusiness(widget.business.copyWithDetails(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
          country: _country.text.trim(),
          logoPath: _logo,
          website: _optional(_website),
          taxId: _optional(_taxId),
          isKleinunternehmer: _isKleinunternehmer,
          bankName: _optional(_bankName),
          iban: _optional(_iban),
          bic: _optional(_bic),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  Widget _field(TextEditingController controller, String label,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: required ? '$label *' : label),
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? 'required'.tr : null
            : null,
      ),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(
            top: AppTheme.spacingM, bottom: AppTheme.spacingS),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('business_details'.tr),
      // Fixed width: AlertDialog otherwise shrinks to its content and clips labels.
      content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: _logo != null
                            ? MemoryImage(base64Decode(_logo!))
                            : null,
                        child:
                            _logo == null ? const Icon(Icons.business) : null,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      TextButton(
                          onPressed: _pickLogo, child: Text('choose_logo'.tr)),
                      if (_logo != null)
                        TextButton(
                          onPressed: () => setState(() => _logo = null),
                          child: Text('remove'.tr),
                        ),
                    ],
                  ),
                  _heading('business'.tr),
                  _field(_name, 'business_name'.tr, required: true),
                  _field(_address, 'street_address'.tr, required: true),
                  _field(_city, 'postcode_city'.tr, required: true),
                  _field(_country, 'country'.tr),
                  _field(_email, 'email'.tr, required: true),
                  _field(_phone, 'phone'.tr),
                  _field(_website, 'website'.tr),
                  _heading('tax'.tr),
                  _field(_taxId, 'tax_id'.tr),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('kleinunternehmer'.tr),
                    subtitle: Text('kleinunternehmer_hint'.tr),
                    value: _isKleinunternehmer,
                    onChanged: (value) =>
                        setState(() => _isKleinunternehmer = value),
                  ),
                  _heading('bank_details'.tr),
                  _field(_bankName, 'bank_name'.tr),
                  _field(_iban, 'iban'.tr),
                  _field(_bic, 'bic'.tr),
                ],
              ),
            ),
          )),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr)),
        ElevatedButton(onPressed: _save, child: Text('save'.tr)),
      ],
    );
  }
}
