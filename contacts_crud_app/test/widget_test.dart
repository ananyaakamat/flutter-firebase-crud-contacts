import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:contacts_crud_app/providers/contact_provider.dart';

void main() {
  testWidgets('App should start without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ContactProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Contacts Manager')),
            body: const Center(child: Text('No Contacts Yet')),
          ),
        ),
      ),
    );

    // Verify that the app starts correctly
    expect(find.text('Contacts Manager'), findsOneWidget);
    expect(find.text('No Contacts Yet'), findsOneWidget);
  });
}
