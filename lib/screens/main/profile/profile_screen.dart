import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_data.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../services/storage_service.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/format.dart';
import 'widgets/profile_edit_dialog.dart';

/// Settings: business details, language and backup.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _exportBackup(BuildContext context) async {
    final bytes = utf8.encode(StorageService.instance.exportAll());
    await FilePicker.saveFile(
      fileName: 'rechnungen-backup-${formatDate(DateTime.now())}.json',
      bytes: bytes,
      mimeType: 'application/json',
    );
  }

  Future<void> _importBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('restore_backup'.tr),
        content: Text('restore_backup_warning'.tr),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('restore'.tr,
                style: const TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await StorageService.instance
          .importAll(utf8.decode(await file.readAsBytes()));
      if (context.mounted) await loadAppData(context);
      messenger.showSnackBar(SnackBar(content: Text('backup_restored'.tr)));
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text('invalid_backup'.tr)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = context.watch<BusinessProvider>().business;
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          if (business != null)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppTheme.spacingM),
                leading: business.logoPath != null
                    ? CircleAvatar(
                        backgroundImage:
                            MemoryImage(base64Decode(business.logoPath!)),
                        onBackgroundImageError: (_, __) {},
                      )
                    : const CircleAvatar(child: Icon(Icons.business)),
                title: Text(business.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  [
                    business.city,
                    business.isKleinunternehmer
                        ? 'kleinunternehmer_short'.tr
                        : null,
                    if (business.taxId?.isNotEmpty != true) 'tax_id_missing'.tr,
                  ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ProfileEditDialog(business: business),
                ),
              ),
            ),
          const SizedBox(height: AppTheme.spacingM),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('language'.tr),
                  trailing: DropdownButton<String>(
                    value: appProvider.selectedLanguage,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) => appProvider.setLanguage(value!),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: Text('export_backup'.tr),
                  subtitle: Text('export_backup_hint'.tr),
                  onTap: () => _exportBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: Text('restore_backup'.tr),
                  onTap: () => _importBackup(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
