class BudgetProposal {
  final int id;
  final int projectId;
  final String companyName;
  final double amount;
  final int votes;
  final int totalCitizens;

  BudgetProposal({
    required this.id, required this.projectId, required this.companyName,
    required this.amount, required this.votes, required this.totalCitizens
  });

  factory BudgetProposal.fromJson(Map<String, dynamic> json) {
    return BudgetProposal(
      id: json['id'],
      projectId: json['projectId'],
      companyName: json['companyName'] ?? 'Empresa',
      amount: json['amount'] ?? 0.0,
      votes: json['votes'] ?? 0,
      totalCitizens: json['totalCitizensInLocality'] ?? 100,
    );
  }
  
  double get percentage => totalCitizens == 0 ? 0 : votes / totalCitizens;
  bool get isWinner => percentage >= 0.8;
}
