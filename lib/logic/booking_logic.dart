import 'package:intl/intl.dart';
import '../models/treatment_model.dart';

class BookingLogic {
  // Rumus hitung Biaya Express
  static int calculateExpressFee(int activeDuration, int baseDays) {
    int daysSaved = baseDays - activeDuration;
    return daysSaved > 0 ? daysSaved * 5000 : 0;
  }

  // Rumus hitung Ongkir
  static int calculateDeliveryFee(String option, double distance) {
    if (option == "Jemput" && distance > 2) {
      return ((distance - 2) * 5000).toInt();
    }
    return 0;
  }

  // Aturan Slot Tanggal (Senin-Jumat & Cek Penuh)
  static bool isDateSelectable(DateTime day, List<String> fullyBookedDates) {
    // 1. Cek Weekend (Sabtu=6, Minggu=7)
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return false;
    }
    // 2. Cek Tanggal Penuh
    String formattedDate = DateFormat('yyyy-MM-dd').format(day);
    return !fullyBookedDates.contains(formattedDate);
  }

  // Cari tanggal pertama yang tersedia (biar initial date nggak error)
  static DateTime getFirstAvailableDate(List<String> fullyBookedDates) {
    DateTime date = DateTime.now();
    while (!isDateSelectable(date, fullyBookedDates)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}