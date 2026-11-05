import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_reporting_app/main.dart';

void main() {
  testWidgets('App loads splash screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusIncidentApp());
    expect(find.byType(CampusIncidentApp), findsOneWidget);
  });
}
