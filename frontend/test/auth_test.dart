import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoof/features/auth/auth_models.dart';
import 'package:shoof/features/auth/login_screen.dart';

void main() {
  test('AuthSession.fromJson reads the login reply from Laravel', () {
    final session = AuthSession.fromJson({
      'user': {
        'id': 1,
        'name': 'Mohammad',
        'email': 'mohammad@test.com',
        'role': 'owner',
      },
      'token': '1|abc',
    });

    expect(session.token, '1|abc');
    expect(session.user.name, 'Mohammad');
    expect(session.user.isOwner, isTrue);
  });

  testWidgets('Login form checks the fields before calling the API', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });
}
