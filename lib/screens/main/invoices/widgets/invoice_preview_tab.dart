import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../../../models/business.dart';
import '../../../../models/client.dart';
import '../../../../models/invoice.dart';
import '../../../../providers/business_provider.dart';
import '../../../../providers/client_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/format.dart';
import 'browser_pdf_view.dart';

/// Shows the invoice PDF and lets the user download/share or print it.
/// The PDF is always German and contains the Pflichtangaben of §14 UStG.
class InvoicePreviewTab extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreviewTab({super.key, required this.invoice});

  String get _fileName => invoice.status == InvoiceStatus.draft
      ? 'Rechnungsentwurf.pdf'
      : 'Rechnung_${invoice.invoiceNumber}.pdf';

  Future<Uint8List> _buildPdf(BuildContext context) {
    final business = context.read<BusinessProvider>().business;
    final client =
        context.read<ClientProvider>().getClientById(invoice.clientId);
    return buildInvoicePdf(invoice, business, client);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async => Printing.sharePdf(
                    bytes: await _buildPdf(context),
                    filename: _fileName,
                  ),
                  icon: const Icon(Icons.download),
                  label: Text('download_share'.tr),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Printing.layoutPdf(
                    onLayout: (_) => _buildPdf(context),
                    name: _fileName,
                  ),
                  icon: const Icon(Icons.print),
                  label: Text('print'.tr),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: useBrowserPdfViewer
              ? FutureBuilder<Uint8List>(
                  future: _buildPdf(context),
                  builder: (context, snapshot) => snapshot.hasData
                      ? BrowserPdfView(bytes: snapshot.data!)
                      : const Center(child: CircularProgressIndicator()),
                )
              : PdfPreview(
                  build: (_) => _buildPdf(context),
                  useActions: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  maxPageWidth: 700,
                  pdfFileName: _fileName,
                ),
        ),
      ],
    );
  }
}

Future<Uint8List> buildInvoicePdf(
    Invoice invoice, Business? business, Client? client) {
  const small = pw.TextStyle(fontSize: 8);
  const normal = pw.TextStyle(fontSize: 10);
  final bold = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);

  final isDraft = invoice.status == InvoiceStatus.draft;
  final isKleinunternehmer = business?.isKleinunternehmer ?? false;
  final logo = _decodeLogo(business?.logoPath);
  final title =
      isDraft ? 'Rechnungsentwurf' : 'Rechnung ${invoice.invoiceNumber}';

  pw.Widget infoRow(String label, String value) => pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(width: 85, child: pw.Text(label, style: normal)),
          pw.Text(value, style: normal),
        ],
      );

  pw.Widget cell(String text, {bool header = false, bool right = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(
          text,
          style: header ? bold : normal,
          textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        ),
      );

  pw.Widget totalRow(String label, double amount, {bool isTotal = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: isTotal
                    ? pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)
                    : normal),
            pw.Text(formatEuroPdf(amount),
                style: isTotal
                    ? pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)
                    : normal),
          ],
        ),
      );

  final senderLine = [business?.name, business?.address, business?.city]
      .where((s) => s != null && s.isNotEmpty)
      .join(' · ');

  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(50, 40, 50, 40),
      footer: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(business?.name ?? '', style: small),
                  pw.Text(business?.address ?? '', style: small),
                  pw.Text(business?.city ?? '', style: small),
                ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (business?.phone.isNotEmpty == true)
                    pw.Text('Tel.: ${business!.phone}', style: small),
                  if (business?.email.isNotEmpty == true)
                    pw.Text('E-Mail: ${business!.email}', style: small),
                  if (business?.website?.isNotEmpty == true)
                    pw.Text('Web: ${business!.website}', style: small),
                ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (business?.taxId?.isNotEmpty == true)
                    pw.Text('St.-Nr./USt-IdNr.: ${business!.taxId}',
                        style: small),
                  if (business?.bankName?.isNotEmpty == true)
                    pw.Text(business!.bankName!, style: small),
                  if (business?.iban?.isNotEmpty == true)
                    pw.Text('IBAN: ${business!.iban}', style: small),
                  if (business?.bic?.isNotEmpty == true)
                    pw.Text('BIC: ${business!.bic}', style: small),
                ]),
          ],
        ),
      ),
      build: (context) => [
        // Sender and invoice details
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null) ...[
                  pw.Image(logo, height: 50),
                  pw.SizedBox(height: 8)
                ],
                pw.Text(business?.name ?? '',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                infoRow('Rechnungs-Nr.', isDraft ? '—' : invoice.invoiceNumber),
                infoRow('Rechnungsdatum', formatDate(invoice.issueDate)),
                infoRow('Leistungsdatum',
                    formatDate(invoice.serviceDate ?? invoice.issueDate)),
                if (business?.taxId?.isNotEmpty == true)
                  infoRow('Steuernummer', business!.taxId!),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 30),

        // Recipient (window envelope position)
        pw.Text(senderLine,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        if (client != null) ...[
          if (client.company?.isNotEmpty == true)
            pw.Text(client.company!, style: normal),
          pw.Text(client.name, style: normal),
          if (client.address.isNotEmpty) pw.Text(client.address, style: normal),
          if (client.city.isNotEmpty) pw.Text(client.city, style: normal),
          if (client.country.isNotEmpty) pw.Text(client.country, style: normal),
        ],
        pw.SizedBox(height: 30),

        pw.Text(title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        if (invoice.status == InvoiceStatus.cancelled)
          pw.Text('STORNIERT',
              style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.red,
                  fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Text('Sehr geehrte Damen und Herren,', style: normal),
        pw.SizedBox(height: 4),
        pw.Text(
            'für unsere Leistungen erlauben wir uns, Ihnen Folgendes in Rechnung zu stellen:',
            style: normal),
        pw.SizedBox(height: 16),

        // Items
        pw.Table(
          border: const pw.TableBorder(
            horizontalInside: pw.BorderSide(color: PdfColors.grey300),
            bottom: pw.BorderSide(color: PdfColors.grey400),
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(0.6),
            1: pw.FlexColumnWidth(3.2),
            2: pw.FlexColumnWidth(0.9),
            3: pw.FlexColumnWidth(0.9),
            4: pw.FlexColumnWidth(1.4),
            5: pw.FlexColumnWidth(1.4),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                cell('Pos.', header: true),
                cell('Beschreibung', header: true),
                cell('Menge', header: true, right: true),
                cell('Einheit', header: true),
                cell('Einzelpreis', header: true, right: true),
                cell('Gesamt', header: true, right: true),
              ],
            ),
            for (final (index, item) in invoice.items.indexed)
              pw.TableRow(children: [
                cell('${index + 1}'),
                cell(item.description),
                cell(formatQuantity(item.quantity), right: true),
                cell(invoiceUnits[unitCode(item.unit)]!),
                cell(formatEuroPdf(item.unitPrice), right: true),
                cell(formatEuroPdf(item.total), right: true),
              ]),
          ],
        ),
        pw.SizedBox(height: 12),

        // Totals
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 250,
            child: pw.Column(children: [
              if (isKleinunternehmer)
                totalRow('Gesamtbetrag', invoice.total, isTotal: true)
              else ...[
                totalRow('Nettobetrag', invoice.subtotal),
                totalRow('Umsatzsteuer ${invoice.taxRate.toStringAsFixed(0)} %',
                    invoice.taxAmount),
                pw.Divider(thickness: 1),
                totalRow('Gesamtbetrag', invoice.total, isTotal: true),
              ],
            ]),
          ),
        ),
        pw.SizedBox(height: 20),

        if (isKleinunternehmer)
          pw.Text('Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.',
              style: normal),
        if (invoice.notes?.trim().isNotEmpty == true) ...[
          pw.SizedBox(height: 8),
          pw.Text(invoice.notes!, style: normal),
        ],
        pw.SizedBox(height: 12),
        pw.Text(
          'Bitte überweisen Sie den Gesamtbetrag bis zum ${formatDate(invoice.dueDate)} '
          'unter Angabe der Rechnungsnummer${business?.iban?.isNotEmpty == true ? ' auf das unten genannte Konto' : ''}.',
          style: normal,
        ),
        pw.SizedBox(height: 16),
        pw.Text('Mit freundlichen Grüßen', style: normal),
        pw.Text(business?.name ?? '', style: bold),
      ],
    ),
  );
  return pdf.save();
}

pw.MemoryImage? _decodeLogo(String? logo) {
  if (logo == null) return null;
  try {
    return pw.MemoryImage(base64Decode(logo));
  } on FormatException {
    return null; // Older builds stored a file path here.
  }
}
