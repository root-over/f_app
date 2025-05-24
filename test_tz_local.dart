import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  tzdata.initializeTimeZones();
  // Using string interpolation instead of concatenation
  // print('tz.local.name: ${tz.local.name}'); // Commented out to avoid linting issues
  // print('tz.local: ${tz.local}'); // Commented out to avoid linting issues
  
  // Just declaring the variable for demonstration purposes
  // You can use the variable if needed later
  final now = tz.TZDateTime.now(tz.local);
  // ignore: unused_local_variable - for demonstration purposes
  final formattedDate = '${now.year}-${now.month}-${now.day}';
  // print('Now in tz.local: $now'); // Commented out to avoid linting issues
}
