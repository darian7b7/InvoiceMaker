import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'providers/app_provider.dart';
import 'providers/business_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/client_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/app_data.dart';
import 'screens/onboarding/registration_flow.dart';
import 'screens/main/main_navigation.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.instance.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const InvoiceMakerApp());
}

const double _maxAppWidth = 600;

class InvoiceMakerApp extends StatelessWidget {
  const InvoiceMakerApp({super.key});

  Locale _getLocaleFromLanguage(String languageCode) {
    switch (languageCode) {
      case 'de':
        return const Locale('de', 'DE');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return GetMaterialApp(
            title: 'Invoice Maker',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: _getLocaleFromLanguage(appProvider.selectedLanguage),
            fallbackLocale: const Locale('en', 'US'),
            builder: (context, child) {
              // On wide screens (web/desktop) show the app as a centered,
              // phone-width column instead of stretching across the window.
              final mq = MediaQuery.of(context);
              final width = math.min(mq.size.width, _maxAppWidth);
              return Container(
                color: Theme.of(context).dividerColor,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  child: MediaQuery(
                    data: mq.copyWith(size: Size(width, mq.size.height)),
                    child: child!,
                  ),
                ),
              );
            },
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    // Loading notifies the providers, which must not happen while this
    // first frame is still being built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRegistrationStatus());
  }

  Future<void> _checkRegistrationStatus() async {
    await loadAppData(context);
    if (!mounted) return;

    setState(() {
      _isRegistered = context.read<BusinessProvider>().isBusinessRegistered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isRegistered) {
      return const RegistrationFlow();
    }

    return const MainNavigation();
  }
}
