import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_ecommerce_admin/screens/product_listing_screen.dart';

void main() {
  testWidgets('ProductListingScreen UI Smoke Test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: ProductListingScreen(),
      ),
    );

    // Verify that the AppBar title "List Products" is rendered.
    expect(find.text('List Products'), findsOneWidget);

    // Verify basic UI accordions are present.
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.text('Product Variants'), findsOneWidget);
    expect(find.text('Packaging & Logistics'), findsOneWidget);
  });
}
