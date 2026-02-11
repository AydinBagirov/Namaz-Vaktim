// root_response.dart
class PrayerTimeResponse {
  final int code;
  final String status;
  final PrayerData data;

  PrayerTimeResponse({
    this.code = 200,
    this.status = "OK",
    required this.data,
  });

  factory PrayerTimeResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimeResponse(
      code: json['code'] ?? 200,
      status: json['status'] ?? "OK",
      data: PrayerData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'status': status,
    'data': data.toJson(),
  };
}

// prayer_data.dart
class PrayerData {
  final Timings timings;
  final PrayerDate? date;
  final Meta? meta;

  PrayerData({
    required this.timings,
    this.date,
    this.meta,
  });

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      timings: Timings.fromJson(json['timings']),
      date: json['date'] != null ? PrayerDate.fromJson(json['date']) : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'timings': timings.toJson(),
    if (date != null) 'date': date!.toJson(),
    if (meta != null) 'meta': meta!.toJson(),
  };
}

// timings.dart
class Timings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final String firstthird;
  final String lastthird;

  Timings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    this.midnight = "00:00",
    this.firstthird = "00:00",
    this.lastthird = "00:00",
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      fajr: json['Fajr'] ?? "00:00",
      sunrise: json['Sunrise'] ?? "00:00",
      dhuhr: json['Dhuhr'] ?? "00:00",
      asr: json['Asr'] ?? "00:00",
      sunset: json['Sunset'] ?? "00:00",
      maghrib: json['Maghrib'] ?? "00:00",
      isha: json['Isha'] ?? "00:00",
      imsak: json['Imsak'] ?? "00:00",
      midnight: json['Midnight'] ?? "00:00",
      firstthird: json['Firstthird'] ?? "00:00",
      lastthird: json['Lastthird'] ?? "00:00",
    );
  }

  Map<String, dynamic> toJson() => {
    'Fajr': fajr,
    'Sunrise': sunrise,
    'Dhuhr': dhuhr,
    'Asr': asr,
    'Sunset': sunset,
    'Maghrib': maghrib,
    'Isha': isha,
    'Imsak': imsak,
    'Midnight': midnight,
    'Firstthird': firstthird,
    'Lastthird': lastthird,
  };
}


// date.dart
class PrayerDate {
  final String readable;
  final String timestamp;
  final Hijri hijri;
  final Gregorian gregorian;

  PrayerDate({
    required this.readable,
    required this.timestamp,
    required this.hijri,
    required this.gregorian,
  });

  factory PrayerDate.fromJson(Map<String, dynamic> json) {
    return PrayerDate(
      readable: json['readable'] ?? "",
      timestamp: json['timestamp'] ?? "",
      hijri: Hijri.fromJson(json['hijri']),
      gregorian: Gregorian.fromJson(json['gregorian']),
    );
  }

  Map<String, dynamic> toJson() => {
    'readable': readable,
    'timestamp': timestamp,
    'hijri': hijri.toJson(),
    'gregorian': gregorian.toJson(),
  };
}

// hijri.dart
class Hijri {
  final String date;
  final String day;
  final String year;
  final String method;

  Hijri({
    required this.date,
    required this.day,
    required this.year,
    required this.method,
  });

  factory Hijri.fromJson(Map<String, dynamic> json) {
    return Hijri(
      date: json['date'] ?? "",
      day: json['day'] ?? "",
      year: json['year'] ?? "",
      method: json['method'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'day': day,
    'year': year,
    'method': method,
  };
}

// gregorian.dart
class Gregorian {
  final String date;
  final String day;
  final String year;

  Gregorian({
    required this.date,
    required this.day,
    required this.year,
  });

  factory Gregorian.fromJson(Map<String, dynamic> json) {
    return Gregorian(
      date: json['date'] ?? "",
      day: json['day'] ?? "",
      year: json['year'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'day': day,
    'year': year,
  };
}

// meta.dart
class Meta {
  final double latitude;
  final double longitude;
  final String timezone;

  Meta({
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timezone: json['timezone'] ?? "Asia/Baku",
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
  };
}