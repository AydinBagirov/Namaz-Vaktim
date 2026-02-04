// root_response.dart
class PrayerTimeResponse {
  final int code;
  final String status;
  final PrayerData data;

  PrayerTimeResponse({
    required this.code,
    required this.status,
    required this.data,
  });

  factory PrayerTimeResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimeResponse(
      code: json['code'],
      status: json['status'],
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
  final PrayerDate date;
  final Meta meta;

  PrayerData({
    required this.timings,
    required this.date,
    required this.meta,
  });

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      timings: Timings.fromJson(json['timings']),
      date: PrayerDate.fromJson(json['date']),
      meta: Meta.fromJson(json['meta']),
    );
  }

  Map<String, dynamic> toJson() => {
    'timings': timings.toJson(),
    'date': date.toJson(),
    'meta': meta.toJson(),
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
    required this.midnight,
    required this.firstthird,
    required this.lastthird,
  });

  factory Timings.fromJson(Map<String, dynamic> json) {
    return Timings(
      fajr: json['Fajr'],
      sunrise: json['Sunrise'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      sunset: json['Sunset'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
      imsak: json['Imsak'],
      midnight: json['Midnight'],
      firstthird: json['Firstthird'],
      lastthird: json['Lastthird'],
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
      readable: json['readable'],
      timestamp: json['timestamp'],
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
      date: json['date'],
      day: json['day'],
      year: json['year'],
      method: json['method'],
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
      date: json['date'],
      day: json['day'],
      year: json['year'],
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
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timezone: json['timezone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timezone': timezone,
  };
}
