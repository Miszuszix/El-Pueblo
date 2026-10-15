import 'package:material_ui/material_ui.dart';

// Un color pastel per rol (molt clars i poc saturats)
const Map<String, Color> roleColors = {
  'witch': Color(0xFFE6DCF2),    // lavanda
  'werewolf': Color(0xFFF2DCDC), // rosa apagat
  'cupid': Color(0xFFF8E1EA),    // rosa clar
  'hunter': Color(0xFFDFEBD9),   // verd menta
  'seer': Color(0xFFDAE8F4),     // blau cel
  'villager': Color(0xFFF5ECD6), // crema
};

/// Color de fons d'un rol (gris clar si no el coneixem)
Color roleColor(String role) =>
    roleColors[role.toLowerCase()] ?? const Color(0xFFEEEEEE);