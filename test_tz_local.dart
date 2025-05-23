import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  tzdata.initializeTimeZones();
  print('tz.local.name: ' + tz.local.name);
  print('tz.local: ' + tz.local.toString());
  final now = tz.TZDateTime.now(tz.local);
  print('Now in tz.local: ' + now.toString());
}
