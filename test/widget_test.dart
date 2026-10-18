import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:invoice_maker/main.dart';
import 'package:invoice_maker/screens/onboarding/registration_flow.dart';
import 'package:invoice_maker/services/storage_service.dart';

void main() {
  testWidgets('first launch shows the business setup', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();

    await tester.pumpWidget(const InvoiceMakerApp());
    await tester.pumpAndSettle();

    expect(find.byType(RegistrationFlow), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
