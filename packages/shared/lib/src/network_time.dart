import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';

/// Returns the current network time (utc).
///
/// On web it uses worldtimeapi.org and on mobile package:ntp.
Future<DateTime> getNetworkTime() async {
  if (kIsWeb) {
    final data = await http.get(Uri.parse('https://worldtimeapi.org/api/ip'));

    final dateTimeString =
        pick(json.decode(data.body), 'utc_datetime').asStringOrThrow();

    return DateTime.parse(dateTimeString);
  } else {
    return await NTP.now();
  }
}
