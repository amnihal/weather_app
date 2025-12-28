import 'package:flutter/material.dart';

class HourlyForecastCard extends StatelessWidget {
  final String time, value;
  final IconData icon;
  const HourlyForecastCard({
    super.key,
    required this.icon,
    required this.time,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),

            Icon(icon, size: 35),

            SizedBox(height: 8),

            Text(value),
          ],
        ),
      ),
    );
  }
}
