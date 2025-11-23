import 'package:app/enums/app_env.dart';
import 'package:app/utils/app_env_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvUtils', () {
    group('fromString', () {
      test('devを渡すとAppEnv.devを返す', () {
        expect(AppEnvUtils.fromString('dev'), AppEnv.dev);
      });

      test('prodを渡すとAppEnv.prodを返す', () {
        expect(AppEnvUtils.fromString('prod'), AppEnv.prod);
      });

      test('不正な値を渡すとArgumentErrorをスローする', () {
        expect(() => AppEnvUtils.fromString(''), throwsArgumentError);
        expect(() => AppEnvUtils.fromString('invalid'), throwsArgumentError);
        expect(() => AppEnvUtils.fromString('DEV'), throwsArgumentError);
        expect(() => AppEnvUtils.fromString('PROD'), throwsArgumentError);
      });
    });

    group('isDev', () {
      test('AppEnv.devの場合trueを返す', () {
        expect(AppEnvUtils.isDev(AppEnv.dev), isTrue);
      });

      test('AppEnv.prodの場合falseを返す', () {
        expect(AppEnvUtils.isDev(AppEnv.prod), isFalse);
      });
    });

    group('isProd', () {
      test('AppEnv.prodの場合trueを返す', () {
        expect(AppEnvUtils.isProd(AppEnv.prod), isTrue);
      });

      test('AppEnv.devの場合falseを返す', () {
        expect(AppEnvUtils.isProd(AppEnv.dev), isFalse);
      });
    });
  });
}
