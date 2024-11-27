// lib/screens/home/widgets/brand_filter.dart
import 'package:ecommerce_sneaker_app/screens/home/widgets/brand_button.dart';
import 'package:flutter/material.dart';

class BrandFilter extends StatelessWidget {
  final Function(String?) onBrandSelected;
  final String? selectedBrand;

  const BrandFilter({
    super.key,
    required this.onBrandSelected,
    this.selectedBrand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brands',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              BrandButton(
                name: 'All',
                logo: 'https://www.svgrepo.com/show/486345/shoe.svg',
                isSelected: selectedBrand == 'All',
                onPressed: () => onBrandSelected('All'),
              ),
              BrandButton(
                name: 'Nike',
                logo: 'https://www.svgrepo.com/show/518225/nike.svg',
                isSelected: selectedBrand == 'Nike',
                onPressed: () => onBrandSelected('Nike'),
              ),
              BrandButton(
                name: 'Adidas',
                logo: 'https://www.svgrepo.com/show/514463/adidas-training.svg',
                isSelected: selectedBrand == 'Adidas',
                onPressed: () => onBrandSelected('Adidas'),
              ),
              BrandButton(
                name: 'Jordan',
                logo: 'https://www.svgrepo.com/show/330747/jordan.svg',
                isSelected: selectedBrand == 'Jordan',
                onPressed: () => onBrandSelected('Jordan'),
              ),
              BrandButton(
                name: 'Puma',
                logo: 'https://www.svgrepo.com/show/303470/puma-logo-logo.svg',
                isSelected: selectedBrand == 'Puma',
                onPressed: () => onBrandSelected('Puma'),
              ),
              BrandButton(
                name: 'Converse',
                logo:
                    'https://www.svgrepo.com/show/303352/converse-logo3-logo.svg',
                isSelected: selectedBrand == 'Converse',
                onPressed: () => onBrandSelected('Converse'),
              ),
              BrandButton(
                name: 'Vans',
                logo: 'https://www.svgrepo.com/show/303469/vans-3-logo.svg',
                isSelected: selectedBrand == 'Vans',
                onPressed: () => onBrandSelected('Vans'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
