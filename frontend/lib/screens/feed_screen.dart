import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/project_model.dart';
import 'project_discussion_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isCompany = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthService>(context, listen: false);
    _isCompany = auth.currentUser?.isCompany ?? false;
    _tabCtrl = TabController(length: _isCompany ? 2 : 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed de Proyectos"),
        bottom: _isCompany 
          ? TabBar(
              controller: _tabCtrl,
              tabs: const [Tab(text: "Global"), Tab(text: "Mis Propuestas")]
            ) 
          : null,
      ),
      body: _isCompany 
        ? TabBarView(
            controller: _tabCtrl,
            children: [
              _buildList(context, api.projects),
              FutureBuilder<List<Project>>(
                future: api.fetchCompanyProjects(Provider.of<AuthService>(context).currentUser!.id),
                builder: (ctx, snap) {
                   if(!snap.hasData) return const Center(child: CircularProgressIndicator());
                   return _buildList(context, snap.data!);
                }
              )
            ]
          )
        : _buildList(context, api.projects),
    );
  }

  Widget _buildList(BuildContext context, List<Project> projects) {
    if(projects.isEmpty) return const Center(child: Text("No hay proyectos aún"));
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (ctx, i) {
        final p = projects[i];
        return ListTile(
          title: Text(p.title),
          subtitle: Text("${p.status.replaceAll('_', ' ')} • ${p.zone}"),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () async {
             await Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDiscussionScreen(project: p)));
             Provider.of<ApiService>(context, listen: false).fetchProjects();
          }, 
        );
      },
    );
  }
}
