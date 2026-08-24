import 'package:flutter_test/flutter_test.dart';
import 'package:smart_energy/services/auth_service.dart';

void main() {
  test('AuthService phone validation smoke test', () {
    expect(AuthService.validateLibyanPhone('0912345678'), '+218912345678');
    expect(AuthService.validateLibyanPhone('912345678'), '+218912345678');
    expect(AuthService.validateLibyanPhone('+218912345678'), '+218912345678');
    expect(AuthService.validateLibyanPhone('12345'), isNull);
  });
}
