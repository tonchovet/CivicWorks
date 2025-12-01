package com.civicworks.model.mysql;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "votes", uniqueConstraints = {
    // Unique constraint now includes TYPE, so a user can vote for a Proposal AND later for Validation
    @UniqueConstraint(columnNames = {"userId", "projectId", "type"}) 
})
public class Vote {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long userId;
    private Long projectId;
    
    @Enumerated(EnumType.STRING)
    private VoteType type;
    
    // For Proposal Vote
    private Long budgetProposalId; 
    
    // For Validation Vote
    private boolean isPositiveValidation;

    public enum VoteType { PROPOSAL, VALIDATION }
}
