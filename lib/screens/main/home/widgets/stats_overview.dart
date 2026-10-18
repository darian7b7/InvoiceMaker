import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../providers/business_provider.dart';
import '../../../../providers/expense_provider.dart';
import '../../../../providers/invoice_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/format.dart';

/// This year's figures for the Einnahmenüberschussrechnung (EÜR):
/// income by payment date, expenses, profit and VAT owed.
class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final isKleinunternehmer =
        context.watch<BusinessProvider>().business?.isKleinunternehmer ?? false;
    final invoiceProvider = context.watch<InvoiceProvider>();
    final paid = invoiceProvider.paidInYear(year);
    final expenses = context.watch<ExpenseProvider>().expensesInYear(year);

    // Kleinunternehmer can't reclaim Vorsteuer, so gross expenses are costs.
    final income = paid.fold(0.0, (sum, i) => sum + i.subtotal);
    final vatCollected = paid.fold(0.0, (sum, i) => sum + i.taxAmount);
    final costs = expenses.fold(
        0.0, (sum, e) => sum + (isKleinunternehmer ? e.amount : e.netAmount));
    final vatPaid = expenses.fold(0.0, (sum, e) => sum + e.vatAmount);
    final profit = income - costs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'overview'.tr} $year',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            _StatCard(
              title: isKleinunternehmer ? 'income'.tr : 'income_net'.tr,
              value: formatEuro(income),
              icon: Icons.trending_up,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(width: AppTheme.spacingS),
            _StatCard(
              title: isKleinunternehmer ? 'expenses'.tr : 'expenses_net'.tr,
              value: formatEuro(costs),
              icon: Icons.shopping_cart,
              color: AppTheme.warningColor,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Row(
          children: [
            _StatCard(
              title: 'profit'.tr,
              value: formatEuro(profit),
              icon: Icons.account_balance_wallet,
              color: profit >= 0 ? AppTheme.primaryColor : AppTheme.errorColor,
            ),
            const SizedBox(width: AppTheme.spacingS),
            _StatCard(
              title: 'open_invoices'.tr,
              value: formatEuro(invoiceProvider.pendingAmount),
              icon: Icons.schedule,
              color: AppTheme.accentColor,
            ),
          ],
        ),
        if (!isKleinunternehmer) ...[
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              _StatCard(
                title: 'vat_payable'.tr,
                value: formatEuro(vatCollected - vatPaid),
                subtitle:
                    '${formatEuro(vatCollected)} ${'vat_collected'.tr} − ${formatEuro(vatPaid)} ${'input_vat'.tr}',
                icon: Icons.account_balance,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textSecondaryColor, fontSize: 12)),
            if (subtitle != null)
              Text(subtitle!,
                  style: const TextStyle(
                      color: AppTheme.textTertiaryColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
