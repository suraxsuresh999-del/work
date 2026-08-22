import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worksphere/app/app.dart';

void main() {
  testWidgets('WorkSphereApp initial render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WorkSphereApp(),
      ),
    );
    expect(find.byType(WorkSphereApp), findsOneWidget);
  });
}
