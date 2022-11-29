import 'package:acesteels/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaterialDropDown extends StatelessWidget {
  final List<String> materials;
  final String materialName;
  final Function(String) onChanged;

  const MaterialDropDown({
    @required this.materials,
    @required this.materialName,
    @required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: const EdgeInsets.all(14.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          elevation: 6,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: kPrimaryDarkColor,
          ),
          isExpanded: false,
          isDense: true,
          value: materialName,
          items: materials.map(
                (e) => DropdownMenuItem(
              child: Row(
                children: [
                  Text(
                    e,
                    style:  GoogleFonts.montserrat(
                      color: kPrimaryDarkColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              value: e,
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
