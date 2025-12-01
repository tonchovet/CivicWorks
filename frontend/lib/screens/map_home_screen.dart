import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/project_model.dart';
import 'project_discussion_screen.dart';
import 'create_project_screen.dart';

class MapHomeScreen extends StatelessWidget {
  const MapHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    // Demo center Rosario
    final center = LatLng(-32.9468, -60.6393);

    return Scaffold(
      appBar: AppBar(title: const Text("Obras en tu Localidad")),
      body: FlutterMap(
        options: MapOptions(
          center: center,
          zoom: 13,
          onTap: (tapPos, point) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateProjectScreen(initialLocation: point))
            );
          },
        ),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
          MarkerLayer(
            markers: api.projects.map((p) => Marker(
              point: LatLng(p.latitude, p.longitude),
              width: 50,
              height: 50,
              builder: (ctx) => GestureDetector(
                onTap: () => _showProjectPreview(context, p),
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              )
            )).toList(),
          )
        ],
      ),
    );
  }

  void _showProjectPreview(BuildContext context, Project p) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Chip(label: Text(p.status)),
            const SizedBox(height: 10),
            Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text("ENTRAR AL DEBATE & VOTAR"),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDiscussionScreen(project: p)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              ),
            )
          ],
        ),
      )
    );
  }
}
