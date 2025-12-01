class SocialPost {
  final String? id;
  final String authorName;
  final String content;
  final int timestamp;
  final String channel; 
  final List<String> imageUrls;
  
  // Budget Props
  final int? budgetProposalId;
  final String? budgetAmount;
  
  // Rich Media
  final String? documentUrl;
  final String? audioUrl;
  final String? mediaType; // IMAGE, DOCUMENT, AUDIO, TEXT

  SocialPost({
    this.id, required this.authorName, required this.content,
    required this.timestamp, required this.channel,
    this.imageUrls = const [],
    this.budgetProposalId, this.budgetAmount,
    this.documentUrl, this.audioUrl, this.mediaType
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      authorName: json['authorName'] ?? 'Anon',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      channel: json['channel'] ?? 'PUBLIC',
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      budgetProposalId: json['budgetProposalId'],
      budgetAmount: json['budgetAmount'],
      documentUrl: json['documentUrl'],
      audioUrl: json['audioUrl'],
      mediaType: json['mediaType'] ?? 'TEXT',
    );
  }
}
