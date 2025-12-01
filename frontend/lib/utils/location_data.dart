class LocationData {
  static const List<String> countries = ["Argentina", "Uruguay", "Chile"];
  
  static const Map<String, List<String>> provinces = {
    "Argentina": ["Santa Fe", "Buenos Aires", "Córdoba", "Mendoza"],
    "Uruguay": ["Montevideo", "Canelones"],
    "Chile": ["Santiago", "Valparaíso"]
  };

  static const Map<String, List<String>> localities = {
    "Santa Fe": ["Rosario", "Santa Fe Capital", "Rafaela"],
    "Buenos Aires": ["La Plata", "Mar del Plata", "Bahía Blanca", "CABA"],
    "Córdoba": ["Córdoba Capital", "Villa Carlos Paz"],
    "Mendoza": ["Mendoza Capital", "San Rafael"]
  };
}
