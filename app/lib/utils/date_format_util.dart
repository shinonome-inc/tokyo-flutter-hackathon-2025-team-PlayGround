import 'package:intl/intl.dart';

/// 日付フォーマットに関するユーティリティクラス
class DateFormatUtil {
  DateFormatUtil._();

  /// 日付を yyyy/MM/dd 形式でフォーマットする
  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  /// 現在の日付を yyyy/MM/dd 形式でフォーマットする
  static String formatNow() {
    return formatDate(DateTime.now());
  }
}
