package com.civicworks.model.mysql;
import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;

@Entity
@Data
@Table(name = "budget_proposals")
public class BudgetProposal {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long projectId;
    private Long companyId;
    private String companyName;
    
    @Column(precision = 19, scale = 4)
    private BigDecimal amount;
    
    private String description;
    
    private int votes;
    
    @Transient
    private long totalCitizensInLocality; 
}
