import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'widgets/stats_overview.dart';
import 'widgets/recent_invoices.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          AppTheme.spacingM, AppTheme.spacingM, AppTheme.spacingM, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsOverview(),
          SizedBox(height: AppTheme.spacingL),
          RecentInvoices(),
        ],
      ),
    );
  }
}
