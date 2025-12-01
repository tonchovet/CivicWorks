import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/location_data.dart';

class CreateProjectScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const CreateProjectScreen({super.key, this.initialLocation});
  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  String title='', desc='', scope='LOCAL';
  double budget=0;
  
  String selectedCountry = "Argentina";
  String? selectedProv;
  String? selectedLoc;
  
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? LatLng(-32.9468, -60.6393);
    if(widget.initialLocation != null) {
      desc = "Ubicación seleccionada en mapa: ${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}.\n";
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && selectedLoc != null) {
      _formKey.currentState!.save();
      final data = {
        'title': title, 'description': desc, 'budgetRequired': budget,
        'latitude': _selectedLocation.latitude, 'longitude': _selectedLocation.longitude,
        'scope': scope,
        'country': selectedCountry,
        'zone': selectedLoc
      };
      Provider.of<ApiService>(context, listen: false).proposeProject(data);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Propuesta")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
             TextFormField(decoration: const InputDecoration(labelText: "Título"), onSaved: (v) => title=v!),
             const SizedBox(height: 10),
             DropdownButtonFormField<String>(
               value: scope,
               decoration: const InputDecoration(labelText: "Alcance"),
               items: const [
                 DropdownMenuItem(value: 'LOCAL', child: Text("Municipal / Local")),
                 DropdownMenuItem(value: 'PROVINCIAL', child: Text("Provincial")),
                 DropdownMenuItem(value: 'NATIONAL', child: Text("Nacional")),
               ],
               onChanged: (v) => setState(() => scope = v!),
             ),
             const SizedBox(height: 10),
             // Location Pickers
             DropdownButtonFormField<String>(
              value: selectedCountry,
              decoration: const InputDecoration(labelText: "País"),
              items: LocationData.countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() { selectedCountry = v!; selectedProv = null; selectedLoc = null; }),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedProv,
              decoration: const InputDecoration(labelText: "Provincia"),
              items: (LocationData.provinces[selectedCountry] ?? []).map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() { selectedProv = v; selectedLoc = null; }),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedLoc,
              decoration: const InputDecoration(labelText: "Zona / Localidad Afectada"),
              items: (selectedProv != null ? (LocationData.localities[selectedProv] ?? []) : []).map((l) => DropdownMenuItem<String>(value: l, child: Text(l))).toList().cast<DropdownMenuItem<String>>(),
              onChanged: (v) => setState(() => selectedLoc = v),
            ),
             
             const SizedBox(height: 10),
             TextFormField(
               initialValue: desc,
               decoration: const InputDecoration(labelText: "Descripción"), 
               maxLines: 3, 
               onSaved: (v) => desc=v!
             ),
             const SizedBox(height: 10),
             TextFormField(decoration: const InputDecoration(labelText: "Presupuesto (\$)"), keyboardType: TextInputType.number, onSaved: (v) => budget=double.tryParse(v!)??0),
             const SizedBox(height: 20),
             const Text("Ubicación en Mapa:", style: TextStyle(fontWeight: FontWeight.bold)),
             Container(
               height: 200, margin: const EdgeInsets.only(top:5, bottom: 20),
               decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
               child: FlutterMap(
                 options: MapOptions(center: _selectedLocation, zoom: 13, onTap: (_, p) => setState(() => _selectedLocation = p)),
                 children: [
                   TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                   MarkerLayer(markers: [Marker(point: _selectedLocation, width:40, height:40, builder:(_) => const Icon(Icons.location_on, color: Colors.red))])
                 ],
               ),
             ),
             ElevatedButton(onPressed: _submit, child: const Text("PUBLICAR"))
          ],
        ),
      ),
    );
  }
}
