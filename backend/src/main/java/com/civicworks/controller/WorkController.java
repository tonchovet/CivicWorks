package com.civicworks.controller;
import com.civicworks.model.mysql.PublicWorkProject;
import com.civicworks.model.mysql.BudgetProposal;
import com.civicworks.model.redis.SocialPost;
import com.civicworks.service.PublicWorkService;
import com.civicworks.service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/works")
public class WorkController {
    @Autowired private PublicWorkService workService;
    @Autowired private ChatService chatService;

    @PostMapping("/propose")
    public PublicWorkProject propose(@RequestBody PublicWorkProject project) { 
        if(project.getZone() != null) project.setZone(project.getZone().trim());
        return workService.proposeProject(project); 
    }

    @GetMapping
    public List<PublicWorkProject> getAll() { return workService.getAllProjects(); }
    
    @GetMapping("/my-proposals")
    public List<PublicWorkProject> getMyProposals(@RequestParam Long userId) {
        return workService.getProjectsByProposer(userId);
    }

    @PostMapping("/vote-proposal")
    public ResponseEntity<?> voteProposal(@RequestParam Long userId, @RequestParam Long proposalId) {
        try {
            String result = workService.voteForBudgetProposal(userId, proposalId);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    @GetMapping("/proposal/{id}")
    public BudgetProposal getProposal(@PathVariable Long id) {
        return workService.getProposal(id);
    }
    
    @PostMapping("/{id}/finish")
    public ResponseEntity<?> finishWork(@PathVariable Long id, @RequestParam Long companyId) {
        try { return ResponseEntity.ok(workService.markWorkFinished(id, companyId)); }
        catch(Exception e) { return ResponseEntity.badRequest().body(e.getMessage()); }
    }
    
    @PostMapping("/{id}/validate")
    public ResponseEntity<?> validateWork(@PathVariable Long id, @RequestParam Long userId, @RequestParam boolean positive) {
        try { return ResponseEntity.ok(workService.voteValidation(userId, id, positive)); }
        catch(Exception e) { return ResponseEntity.badRequest().body(e.getMessage()); }
    }

    @PostMapping("/{projectId}/posts")
    public SocialPost createPost(@RequestBody SocialPost post) {
        return chatService.createPost(post);
    }

    @GetMapping("/{projectId}/posts")
    public List<SocialPost> getProjectFeed(@PathVariable Long projectId, @RequestParam String channel) {
        return chatService.getPosts(projectId, channel);
    }
}
