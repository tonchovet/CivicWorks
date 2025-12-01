package com.civicworks.repository.mysql;
import com.civicworks.model.mysql.BudgetProposal;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface BudgetProposalRepository extends JpaRepository<BudgetProposal, Long> {
    Optional<BudgetProposal> findByProjectIdAndCompanyId(Long projectId, Long companyId);
}
