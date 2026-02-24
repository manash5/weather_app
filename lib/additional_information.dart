import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  final Icon icon;
  final String heading;
  final String subHeading; 
  const AdditionalInfo({super.key, required this.icon, required this.heading, required this.subHeading});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        SizedBox(height: 10),
        Text(heading),
        SizedBox(height: 10),
        Text(subHeading, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
