package com.civicworks.service;
import com.civicworks.model.mysql.BudgetProposal;
import com.civicworks.model.mysql.PublicWorkProject;
import com.civicworks.model.mysql.User;
import com.civicworks.model.mysql.Vote;
import com.civicworks.repository.mysql.BudgetProposalRepository;
import com.civicworks.repository.mysql.ProjectRepository;
import com.civicworks.repository.mysql.UserRepository;
import com.civicworks.repository.mysql.VoteRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class PublicWorkService {
    @Autowired private ProjectRepository projectRepo;
    @Autowired private UserRepository userRepo;
    @Autowired private VoteRepository voteRepo;
    @Autowired private BudgetProposalRepository budgetRepo;
    @Autowired private NotificationService notifService;

    public PublicWorkProject proposeProject(PublicWorkProject project) {
        project.setStatus(PublicWorkProject.ProjectStatus.PROPOSED);
        project.setBudgetCollected(BigDecimal.ZERO);
        project.setApprovalVotes(0);
        project.setValidationPositiveVotes(0);
        project.setValidationNegativeVotes(0);
        project.setCreatedAt(LocalDateTime.now());
        return projectRepo.save(project);
    }
    
    public List<PublicWorkProject> getAllProjects() {
        return projectRepo.findAll();
    }
    
    public List<PublicWorkProject> getProjectsByProposer(Long proposerId) {
        return projectRepo.findByProposerId(proposerId);
    }

    @Transactional
    public String voteForBudgetProposal(Long userId, Long proposalId) {
        User user = userRepo.findById(userId).orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        if(user.getRole() == User.UserRole.COMPANY) throw new RuntimeException("Las empresas no pueden votar en los proyectos.");

        BudgetProposal proposal = budgetRepo.findById(proposalId).orElseThrow(() -> new RuntimeException("Propuesta no encontrada"));
        PublicWorkProject project = projectRepo.findById(proposal.getProjectId()).orElseThrow();

        if (project.getScope() == PublicWorkProject.ProjectScope.LOCAL) {
             if (!project.getZone().equalsIgnoreCase(user.getLocality())) {
                 throw new RuntimeException("Solo residentes de " + project.getZone() + " pueden votar.");
             }
        }

        // Use Type PROPOSAL
        Optional<Vote> existingVoteOpt = voteRepo.findByUserIdAndProjectIdAndType(userId, project.getId(), Vote.VoteType.PROPOSAL);
        
        if (existingVoteOpt.isPresent()) {
            Vote existingVote = existingVoteOpt.get();
            if(existingVote.getBudgetProposalId() != null && existingVote.getBudgetProposalId().equals(proposalId)) {
                throw new RuntimeException("Ya votaste por esta propuesta.");
            }
            if(existingVote.getBudgetProposalId() != null) {
                BudgetProposal oldProp = budgetRepo.findById(existingVote.getBudgetProposalId()).orElse(null);
                if(oldProp != null) {
                    oldProp.setVotes(oldProp.getVotes() - 1);
                    budgetRepo.save(oldProp);
                }
            }
            existingVote.setBudgetProposalId(proposalId);
            voteRepo.save(existingVote);
        } else {
            Vote newVote = new Vote();
            newVote.setUserId(userId);
            newVote.setProjectId(project.getId());
            newVote.setType(Vote.VoteType.PROPOSAL);
            newVote.setBudgetProposalId(proposalId);
            voteRepo.save(newVote);
            project.setApprovalVotes(project.getApprovalVotes() + 1);
        }

        proposal.setVotes(proposal.getVotes() + 1);
        budgetRepo.save(proposal);

        long totalCitizens = userRepo.countByLocalityAndRole(project.getZone(), User.UserRole.CITIZEN);
        if (totalCitizens > 0) {
            double percentage = (double) proposal.getVotes() / totalCitizens;
            if (percentage >= 0.8) {
                project.setStatus(PublicWorkProject.ProjectStatus.IN_PROGRESS);
                project.setExecutorCompanyId(proposal.getCompanyId());
                project.setWinningProposalId(proposal.getId());
                project.setBudgetRequired(proposal.getAmount());
                projectRepo.save(project);
                return "¡Contrato Inteligente Iniciado! La propuesta ha superado el 80%. La obra comienza ahora.";
            }
        }
        projectRepo.save(project);
        return "Voto registrado. Progreso: " + proposal.getVotes() + "/" + totalCitizens;
    }
    
    // --- SMART CONTRACT EXECUTION PHASES ---

    public String markWorkFinished(Long projectId, Long companyId) {
        PublicWorkProject project = projectRepo.findById(projectId).orElseThrow();
        if(!project.getExecutorCompanyId().equals(companyId)) throw new RuntimeException("No eres la empresa ejecutora.");
        if(project.getStatus() != PublicWorkProject.ProjectStatus.IN_PROGRESS) throw new RuntimeException("El proyecto no está en progreso.");
        
        project.setStatus(PublicWorkProject.ProjectStatus.VALIDATION_PHASE);
        projectRepo.save(project);
        return "Obra marcada como terminada. Inicia fase de certificación ciudadana.";
    }
    
    @Transactional
    public String voteValidation(Long userId, Long projectId, boolean isPositive) {
        User user = userRepo.findById(userId).orElseThrow();
        if(user.getRole() == User.UserRole.COMPANY) throw new RuntimeException("Empresas no pueden validar.");
        
        PublicWorkProject project = projectRepo.findById(projectId).orElseThrow();
        if(project.getStatus() != PublicWorkProject.ProjectStatus.VALIDATION_PHASE) throw new RuntimeException("Proyecto no está en fase de validación.");
        
        if (project.getScope() == PublicWorkProject.ProjectScope.LOCAL && !project.getZone().equalsIgnoreCase(user.getLocality())) {
             throw new RuntimeException("Solo residentes pueden validar.");
        }
        
        if(voteRepo.findByUserIdAndProjectIdAndType(userId, projectId, Vote.VoteType.VALIDATION).isPresent()) {
            throw new RuntimeException("Ya has emitido tu voto de validación.");
        }
        
        Vote v = new Vote();
        v.setUserId(userId);
        v.setProjectId(projectId);
        v.setType(Vote.VoteType.VALIDATION);
        v.setPositiveValidation(isPositive);
        voteRepo.save(v);
        
        if(isPositive) project.setValidationPositiveVotes(project.getValidationPositiveVotes() + 1);
        else project.setValidationNegativeVotes(project.getValidationNegativeVotes() + 1);
        
        // CHECK SMART CONTRACT CONDITION ( > 50% of TOTAL citizens)
        long totalCitizens = userRepo.countByLocalityAndRole(project.getZone(), User.UserRole.CITIZEN);
        if(totalCitizens > 0 && isPositive) {
             if(project.getValidationPositiveVotes() > (totalCitizens / 2)) {
                 return executeSmartContractPayment(project);
             }
        }
        
        projectRepo.save(project);
        return "Voto de validación registrado.";
    }
    
    private String executeSmartContractPayment(PublicWorkProject project) {
        User company = userRepo.findById(project.getExecutorCompanyId()).orElseThrow();
        // Transfer funds (Conceptually, assumes funds are in system escrow)
        company.setWalletBalance(company.getWalletBalance().add(project.getBudgetRequired()));
        userRepo.save(company);
        
        project.setStatus(PublicWorkProject.ProjectStatus.COMPLETED);
        projectRepo.save(project);
        
        return "¡CERTIFICACIÓN EXITOSA! Smart Contract ejecutado: Fondos transferidos a " + company.getFullName();
    }

    public BudgetProposal getProposal(Long id) {
        BudgetProposal bp = budgetRepo.findById(id).orElse(null);
        if(bp != null) {
             PublicWorkProject p = projectRepo.findById(bp.getProjectId()).orElse(null);
             if(p != null) {
                bp.setTotalCitizensInLocality(userRepo.countByLocalityAndRole(p.getZone(), User.UserRole.CITIZEN));
             }
        }
        return bp;
    }
}
