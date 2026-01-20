// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class InlineCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  // Perubahan tipe data: dari Map<String, int> menjadi Map<String, dynamic>
  final Map<String, dynamic> bookedData;
  final Function(DateTime) onDaySelected;

  const InlineCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.bookedData,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Pilih Tanggal",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TableCalendar(
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (selected, focused) {
                if (_isSelectable(selected)) {
                  onDaySelected(selected);
                }
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xff0096C9),
                  shape: BoxShape.circle,
                ),
              ),
              enabledDayPredicate: (day) => _isSelectable(day),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  String dateKey = DateFormat('yyyy-MM-dd').format(day);

                  // Logika pengambilan data dinamis
                  final slotInfo = bookedData[dateKey];

                  // Jika data berupa Map (dari database), ambil nilainya.
                  // Jika hanya int (fallback), gunakan itu sebagai total.
                  int totalOrder = 0;
                  int maxSlot = 10;

                  if (slotInfo is Map) {
                    totalOrder = slotInfo['total'] ?? 0;
                    maxSlot = slotInfo['max'] ?? 10;
                  } else if (slotInfo is int) {
                    totalOrder = slotInfo;
                  }

                  int remaining = maxSlot - totalOrder;
                  bool isFull = remaining <= 0;
                  bool isWeekend =
                      day.weekday == DateTime.saturday ||
                      day.weekday == DateTime.sunday;

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isWeekend
                          ? Colors.grey.shade200
                          : (isFull
                                ? Colors.red.withOpacity(0.8)
                                : Colors.green.withOpacity(0.1)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isFull && !isWeekend
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: isFull
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (!isWeekend)
                            Text(
                              '$remaining',
                              style: TextStyle(
                                fontSize: 8,
                                color: isFull ? Colors.white70 : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Card.outlined(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  Colors.green.withOpacity(0.2),
                  "Tersedia",
                  Colors.green,
                ),
                _buildLegendItem(
                  Colors.red.withOpacity(0.8),
                  "Penuh",
                  Colors.red,
                ),
                _buildLegendItem(Colors.grey.shade200, "Tutup", Colors.grey),
                _buildLegendItem(
                  const Color(0xff0096C9),
                  "Pilihan",
                  const Color(0xff0096C9),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  bool _isSelectable(DateTime day) {
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return false;
    }
    String dateKey = DateFormat('yyyy-MM-dd').format(day);

    final slotInfo = bookedData[dateKey];
    int totalOrder = 0;
    int maxSlot = 10;

    if (slotInfo is Map) {
      totalOrder = slotInfo['total'] ?? 0;
      maxSlot = slotInfo['max'] ?? 10;
    } else if (slotInfo is int) {
      totalOrder = slotInfo;
    }

    if (totalOrder >= maxSlot) return false;
    return true;
  }
}
