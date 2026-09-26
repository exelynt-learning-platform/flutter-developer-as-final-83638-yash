import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Form Validation Unit Tests', () {
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final RegExp mobileRegExp = RegExp(r'^[0-9]{10}$');

    test('Valid email addresses pass regex validation', () {
      expect(emailRegExp.hasMatch('test@example.com'), isTrue);
      expect(emailRegExp.hasMatch('user.name@domain.co.in'), isTrue);
      expect(emailRegExp.hasMatch('Augusta.Roob44@yahoo.com'), isTrue);
    });

    test('Invalid email addresses fail regex validation', () {
      expect(emailRegExp.hasMatch('invalid-email'), isFalse);
      expect(emailRegExp.hasMatch('test@'), isFalse);
      expect(emailRegExp.hasMatch('@domain.com'), isFalse);
      expect(emailRegExp.hasMatch('test@domain'), isFalse);
    });

    test('Valid 10-digit mobile numbers pass regex validation', () {
      expect(mobileRegExp.hasMatch('7425369808'), isTrue);
      expect(mobileRegExp.hasMatch('9876543210'), isTrue);
    });

    test('Invalid mobile numbers fail regex validation', () {
      expect(mobileRegExp.hasMatch('12345'), isFalse); // Less than 10 digits
      expect(mobileRegExp.hasMatch('123456789012'), isFalse); // More than 10 digits
      expect(mobileRegExp.hasMatch('98765abcde'), isFalse); // Non-numeric
    });
  });
}
