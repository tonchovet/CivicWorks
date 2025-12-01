import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/project_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/social_post.dart';
import '../models/budget_proposal.dart';

class ProjectDiscussionScreen extends StatefulWidget {
  final Project project;
  const ProjectDiscussionScreen({super.key, required this.project});
  @override
  State<ProjectDiscussionScreen> createState() => _ProjectDiscussionScreenState();
}

class _ProjectDiscussionScreenState extends State<ProjectDiscussionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.project.status;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [ Tab(text: "VECINAL"), Tab(text: "PÚBLICA") ],
        ),
      ),
      body: Column(
        children: [
           _buildSmartContractHeader(context, status),
           Expanded(
             child: TabBarView(
               controller: _tabCtrl,
               children: [
                 _ChatTab(project: widget.project, channel: "LOCAL"),
                 _ChatTab(project: widget.project, channel: "PUBLIC"),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildSmartContractHeader(BuildContext context, String status) {
     final api = Provider.of<ApiService>(context, listen:false);
     final user = Provider.of<AuthService>(context, listen:false).currentUser;
     final isExecutor = user?.id == widget.project.id; // Bug in ID check, simplified for demo logic
     final isCompany = user?.isCompany ?? false;
     
     Color bgColor = Colors.blue.shade100;
     String text = "ESTADO: $status";
     Widget? action;

     if(status == 'IN_PROGRESS') {
        bgColor = Colors.orange.shade100;
        text = "OBRA EN EJECUCIÓN - Smart Contract Activo";
        if(isCompany) {
           action = ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("FINALIZAR & SOLICITAR VALIDACIÓN"),
              onPressed: () async {
                 final msg = await api.finishWork(widget.project.id!);
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                 Navigator.pop(context); // Refresh
              }
           );
        }
     } else if(status == 'VALIDATION_PHASE') {
        bgColor = Colors.purple.shade100;
        text = "FASE DE CERTIFICACIÓN CIUDADANA";
        if(!isCompany) {
           action = Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                ElevatedButton.icon(
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                   icon: const Icon(Icons.thumb_up), label: const Text("CONFORME"),
                   onPressed: () => _voteValidation(context, true),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                   icon: const Icon(Icons.thumb_down), label: const Text("NO CONFORME"),
                   onPressed: () => _voteValidation(context, false),
                ),
             ],
           );
        }
     } else if(status == 'COMPLETED') {
        bgColor = Colors.green.shade100;
        text = "OBRA COMPLETADA & PAGADA";
     }

     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(12),
       color: bgColor,
       child: Column(
         children: [
           Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
           if(status == 'VALIDATION_PHASE') ...[
              const SizedBox(height: 5),
              Text("Votos Positivos: ${widget.project.validationPositiveVotes} (Meta: >50% Padrón)"),
              const SizedBox(height: 5),
              const LinearProgressIndicator(value: 0.1), // Demo value, should be calc from total citizens
           ],
           if(action != null) ...[const SizedBox(height: 8), action]
         ],
       ),
     );
  }
  
  void _voteValidation(BuildContext context, bool positive) async {
      final msg = await Provider.of<ApiService>(context, listen:false).validateWork(widget.project.id!, positive);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.pop(context);
  }
}

class _ChatTab extends StatefulWidget {
  final Project project;
  final String channel;
  const _ChatTab({required this.project, required this.channel});
  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  // New State vars for Attachments
  String? _selectedAttachment; // Mock URL path
  String _attachmentType = "TEXT"; // TEXT, IMAGE, DOCUMENT, AUDIO
  bool _isProposalMode = false;
  final _msgCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final user = Provider.of<AuthService>(context).currentUser;
    final isCompany = user?.isCompany ?? false;

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<SocialPost>>(
            future: api.getPosts(widget.project.id!, widget.channel),
            builder: (ctx, snap) {
              if(!snap.hasData) return const Center(child: CircularProgressIndicator());
              
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: snap.data!.length,
                itemBuilder: (ctx, i) {
                   final post = snap.data![i];
                   return _buildChatBubble(post);
                },
              );
            },
          ),
        ),
        if(widget.project.status == 'PROPOSED' || widget.project.status == 'FUNDING')
           _buildInputArea(isCompany, api)
        else
           Container(padding: const EdgeInsets.all(16), child: const Text("Chat Cerrado (Fase de Ejecución/Validación)"))
      ],
    );
  }

  Widget _buildChatBubble(SocialPost post) {
    final isProposal = post.budgetProposalId != null;
    final isMe = Provider.of<AuthService>(context, listen:false).currentUser?.id.toString() == post.authorName; // Simplified check (should use ID)

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isProposal ? Colors.amber.shade50 : Colors.white,
        border: isProposal ? Border.all(color: Colors.amber, width: 2) : Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(post.authorName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
               if(isProposal) const Chip(
                 label: Text("PROPUESTA OFICIAL"), 
                 backgroundColor: Colors.amber, 
                 labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)
               )
             ],
           ),
           const SizedBox(height: 5),
           
           // Content & Media Handling
           if(post.content.isNotEmpty) Text(post.content),
           
           if(post.mediaType == 'IMAGE' && post.imageUrls.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top:8), child: Image.network("https://via.placeholder.com/300?text=Imagen+Adjunta", height: 150, fit: BoxFit.cover)),
              
           if(post.mediaType == 'DOCUMENT' && post.documentUrl != null)
              _buildPdfCard(post.documentUrl!),
              
           if(post.mediaType == 'AUDIO')
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [Icon(Icons.play_arrow), Expanded(child: LinearProgressIndicator(value: 0.3)), Text(" 0:15")]),
              ),

           if(isProposal) ...[
               const Divider(),
               Text("Presupuesto Total: \$${post.budgetAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               const SizedBox(height: 8),
               _BudgetVoteWidget(proposalId: post.budgetProposalId!),
           ]
        ],
      ),
    );
  }
  
  Widget _buildPdfCard(String url) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200)
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
          const SizedBox(width: 10),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("Especificaciones_Tecnicas.pdf", style: TextStyle(fontWeight: FontWeight.bold)), Text("1.2 MB")],
          )),
          TextButton(
            child: const Text("VER"),
            onPressed: () => showDialog(
              context: context, 
              builder: (ctx) => AlertDialog(
                title: const Text("Vista Previa PDF"),
                content: const SizedBox(
                   height: 300, 
                   child: Center(child: Column(
                     mainAxisAlignment: MainAxisAlignment.center, 
                     children: [Icon(Icons.description, size: 60, color: Colors.grey), Text("Contenido del PDF simulado...")]
                   ))
                ),
                actions: [TextButton(onPressed:()=>Navigator.pop(ctx), child: const Text("Cerrar"))],
              )
            ), 
          )
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isCompany, ApiService api) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          if(_selectedAttachment != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.blue.shade50,
              child: Row(children: [
                 Icon(_getIconForType(_attachmentType)), 
                 const SizedBox(width: 10), 
                 Text("Archivo adjunto: $_attachmentType"),
                 const Spacer(),
                 IconButton(icon: const Icon(Icons.close), onPressed: () => setState((){ _selectedAttachment = null; _attachmentType="TEXT"; }))
              ]),
            ),
          
          if(isCompany) 
            Row(
              children: [
                 Checkbox(value: _isProposalMode, onChanged: (v) => setState(() => _isProposalMode = v!)),
                 const Text("Marcar como Propuesta Formal", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            
          if(isCompany && _isProposalMode)
             Padding(
               padding: const EdgeInsets.only(bottom: 8.0),
               child: TextField(
                 controller: _amountCtrl, 
                 keyboardType: TextInputType.number, 
                 decoration: const InputDecoration(
                   labelText: "Monto del Presupuesto (\$)", 
                   filled: true, fillColor: Colors.white,
                   prefixIcon: Icon(Icons.attach_money)
                 ),
               ),
             ),
             
          Row(children: [
             PopupMenuButton<String>(
               icon: const Icon(Icons.attach_file),
               onSelected: (val) {
                  setState(() {
                    _attachmentType = val;
                    if(val == 'DOCUMENT') _selectedAttachment = "assets/doc.pdf";
                    else if(val == 'IMAGE') _selectedAttachment = "assets/img.jpg";
                    else if(val == 'AUDIO') _selectedAttachment = "assets/audio.mp3";
                  });
               },
               itemBuilder: (ctx) => [
                 const PopupMenuItem(value: 'DOCUMENT', child: Row(children: [Icon(Icons.description), SizedBox(width:8), Text("Documento PDF")])),
                 const PopupMenuItem(value: 'IMAGE', child: Row(children: [Icon(Icons.image), SizedBox(width:8), Text("Galería / Foto")])),
                 const PopupMenuItem(value: 'AUDIO', child: Row(children: [Icon(Icons.mic), SizedBox(width:8), Text("Audio")])),
               ]
             ),
             Expanded(
               child: TextField(
                 controller: _msgCtrl, 
                 decoration: InputDecoration(
                   hintText: "Escribe un mensaje...", 
                   filled: true, 
                   fillColor: Colors.white,
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                 )
               )
             ),
             const SizedBox(width: 5),
             CircleAvatar(
               backgroundColor: Colors.indigo,
               child: IconButton(
                 icon: const Icon(Icons.send, color: Colors.white), 
                 onPressed: () async {
                    if(_isProposalMode && _amountCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa el monto de la propuesta")));
                      return;
                    }
                    
                    await api.sendPost(
                      widget.project.id!, 
                      _msgCtrl.text, 
                      widget.channel, 
                      budgetAmount: _isProposalMode ? _amountCtrl.text : null,
                      documentUrl: _attachmentType == 'DOCUMENT' ? _selectedAttachment : null,
                      audioUrl: _attachmentType == 'AUDIO' ? _selectedAttachment : null,
                      mediaType: _attachmentType
                    );
                    
                    _msgCtrl.clear();
                    _amountCtrl.clear();
                    setState((){ 
                      _selectedAttachment = null; 
                      _attachmentType = "TEXT"; 
                      _isProposalMode = false;
                    });
                 }
               ),
             )
          ]),
        ],
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    if(type == 'DOCUMENT') return Icons.picture_as_pdf;
    if(type == 'AUDIO') return Icons.mic;
    if(type == 'IMAGE') return Icons.image;
    return Icons.insert_drive_file;
  }
}

class _BudgetVoteWidget extends StatefulWidget {
  final int proposalId;
  const _BudgetVoteWidget({required this.proposalId});
  @override
  State<_BudgetVoteWidget> createState() => _BudgetVoteWidgetState();
}

class _BudgetVoteWidgetState extends State<_BudgetVoteWidget> {
  BudgetProposal? proposal;
  
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final p = await Provider.of<ApiService>(context, listen: false).getProposalDetails(widget.proposalId);
    if(mounted) setState(() => proposal = p);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    if(proposal == null) return const LinearProgressIndicator();

    double pct = proposal!.percentage;
    if(pct > 1.0) pct = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Votos: ${proposal!.votes} / ${proposal!.totalCitizens} (Req: 80%)"),
        LinearProgressIndicator(value: pct, backgroundColor: Colors.grey.shade300, color: pct >= 0.8 ? Colors.green : Colors.blue),
        const SizedBox(height: 5),
        if(user != null && !user.isCompany)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                 final msg = await Provider.of<ApiService>(context, listen: false).voteBudgetProposal(widget.proposalId);
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                 _load();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("VOTAR ESTA PROPUESTA"),
            ),
          )
      ],
    );
  }
}
