package com.civicworks.service;

import com.civicworks.model.mysql.User;
import com.civicworks.model.mysql.PublicWorkProject;
import com.civicworks.model.mysql.BudgetProposal;
import com.civicworks.model.redis.SocialPost;
import com.civicworks.repository.mysql.ProjectRepository;
import com.civicworks.repository.mysql.UserRepository;
import com.civicworks.repository.mysql.BudgetProposalRepository;
import com.civicworks.repository.redis.SocialPostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;
import java.math.BigDecimal;

@Service
public class ChatService {
    @Autowired private SocialPostRepository postRepo;
    @Autowired private UserRepository userRepo;
    @Autowired private ProjectRepository projectRepo;
    @Autowired private BudgetProposalRepository budgetRepo;

    public SocialPost createPost(SocialPost post) {
        User user = userRepo.findById(post.getAuthorId()).orElseThrow();
        PublicWorkProject project = projectRepo.findById(post.getProjectId()).orElseThrow();

        if("LOCAL".equals(post.getChannel())) {
             if(!user.getLocality().equalsIgnoreCase(project.getZone())) {
                 throw new RuntimeException("Acceso denegado: No resides en la zona.");
             }
        }

        // If it's flagged as a formal proposal (amount present)
        if(post.getBudgetAmount() != null) {
            if(user.getRole() != User.UserRole.COMPANY) {
                throw new RuntimeException("Solo empresas pueden proponer presupuestos.");
            }
            BudgetProposal bp = new BudgetProposal();
            bp.setProjectId(project.getId());
            bp.setCompanyId(user.getId());
            bp.setCompanyName(user.getFullName());
            bp.setAmount(new BigDecimal(post.getBudgetAmount()));
            // Description can now be the post content (with PDF link usually)
            bp.setDescription(post.getContent());
            bp.setVotes(0);
            bp = budgetRepo.save(bp);
            
            post.setBudgetProposalId(bp.getId());
        }

        post.setTimestamp(System.currentTimeMillis());
        return postRepo.save(post);
    }

    public List<SocialPost> getPosts(Long projectId, String channel) {
        List<SocialPost> all = postRepo.findByProjectId(projectId);
        return all.stream()
                  .filter(p -> p.getChannel().equals(channel))
                  .collect(Collectors.toList());
    }
}
