import 'package:flutter_test/flutter_test.dart';

import 'package:word_scanner/main.dart';

void main() {
  testWidgets('Word Scanner app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const WordScannerApp());

    expect(find.text('Word Scanner'), findsOneWidget);
    expect(find.text('Upload or take a photo of any document or image to scan words inside it.'), findsOneWidget);
  });
}
