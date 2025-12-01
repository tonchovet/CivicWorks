import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/project_model.dart';
import 'create_project_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final user = api.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Civic Works", style: TextStyle(fontSize: 18)),
            if (user != null)
              Text("Hola ${user.name} (${user.residency})", style: const TextStyle(fontSize: 12)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Municipal"),
            Tab(text: "Provincial"),
            Tab(text: "Nacional"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeed(api, "LOCAL"),
          _buildFeed(api, "PROVINCIAL"),
          _buildFeed(api, "NATIONAL"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProjectScreen())),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }

  Widget _buildFeed(ApiService api, String scopeFilter) {
    if (api.isLoading) return const Center(child: CircularProgressIndicator());
    
    final filtered = api.projects.where((p) => p.scope == scopeFilter).toList();
    
    if (filtered.isEmpty) return const Center(child: Text("No hay obras en esta categoría"));

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        return ProjectCard(project: filtered[i]);
      },
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context, listen: false);
    final user = api.currentUser;
    
    bool isVotingPhase = project.status == 'PROPOSED';
    bool canVote = user != null && user.residency.toLowerCase() == project.zone.toLowerCase();
    
    // Calcular progreso
    double progress = 0.0;
    if (!isVotingPhase && project.budgetRequired > 0) {
      progress = project.budgetCollected / project.budgetRequired;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(project.zone, style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.zero,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVotingPhase ? Colors.orange.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    isVotingPhase ? "EN VOTACIÓN" : "EN FINANCIAMIENTO",
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold,
                      color: isVotingPhase ? Colors.deepOrange : Colors.green.shade800
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(project.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(project.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            
            if (isVotingPhase) ...[
               Text("Votos: ${project.approvalVotes} (Meta: 3 para aprobar)"),
               const SizedBox(height: 5),
               LinearProgressIndicator(value: project.approvalVotes / 3.0, color: Colors.orange),
               const SizedBox(height: 10),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: canVote ? () async {
                      String msg = await api.voteProject(project.id!);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                   } : null,
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                   child: Text(canVote ? "Votar Propuesta" : "No puedes votar (Zona distinta)"),
                 ),
               )
            ] else ...[
               Text("Presupuesto: \$${project.budgetCollected} / \$${project.budgetRequired}"),
               const SizedBox(height: 5),
               LinearProgressIndicator(value: progress, color: Colors.green),
               const SizedBox(height: 10),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () async {
                      // Demo: Invertir $1000
                      String msg = await api.investProject(project.id!, 1000.0);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                   child: const Text("Invertir \$1,000 (Demo)"),
                 ),
               )
            ]
          ],
        ),
      ),
    );
  }
}
