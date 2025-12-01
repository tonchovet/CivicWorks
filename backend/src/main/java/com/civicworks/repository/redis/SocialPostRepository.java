package com.civicworks.repository.redis;
import com.civicworks.model.redis.SocialPost;
import org.springframework.data.repository.CrudRepository;
import java.util.List;
public interface SocialPostRepository extends CrudRepository<SocialPost, String> {
    List<SocialPost> findByProjectId(Long projectId);
}
