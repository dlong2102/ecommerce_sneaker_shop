import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandButton extends StatelessWidget {
  final String name;
  final String logo;
  final bool isSelected;
  final VoidCallback onPressed;

  const BrandButton({
    super.key,
    required this.name,
    required this.logo,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.orange : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 15,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.network(logo, height: 40),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
