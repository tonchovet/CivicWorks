package com.civicworks.model.redis;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.index.Indexed;
import java.util.List;

@RedisHash("SocialPost")
@Data
public class SocialPost {
    @Id private String id;
    @Indexed private Long projectId;
    
    private String content;
    private String authorName;
    private Long authorId;
    private long timestamp;
    
    @Indexed private String channel; 
    
    // Proposal Data
    private Long budgetProposalId;
    private String budgetAmount; 
    
    // Rich Media
    private List<String> imageUrls; 
    private String documentUrl;
    private String audioUrl;
    
    private MediaType mediaType;

    public enum MediaType { TEXT, IMAGE, DOCUMENT, AUDIO }
}
