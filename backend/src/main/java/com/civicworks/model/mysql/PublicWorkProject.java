package com.civicworks.model.mysql;
import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "projects")
public class PublicWorkProject {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    @Column(length = 2000)
    private String description;
    
    private Double latitude;
    private Double longitude;
    
    @Enumerated(EnumType.STRING)
    private ProjectScope scope; 
    
    private String country;
    private String zone;

    @Column(precision = 19, scale = 4)
    private BigDecimal budgetRequired;
    @Column(precision = 19, scale = 4)
    private BigDecimal budgetCollected;
    
    private int approvalVotes; 

    private Long executorCompanyId;
    private Long winningProposalId;
    
    // Validation Phase Counters
    private int validationPositiveVotes;
    private int validationNegativeVotes;
    
    private Long proposerId;

    @Enumerated(EnumType.STRING)
    private ProjectStatus status;
    private LocalDateTime createdAt;

    public enum ProjectStatus { PROPOSED, FUNDING, IN_PROGRESS, VALIDATION_PHASE, COMPLETED, REJECTED }
    public enum ProjectScope { LOCAL, PROVINCIAL, NATIONAL }
}
