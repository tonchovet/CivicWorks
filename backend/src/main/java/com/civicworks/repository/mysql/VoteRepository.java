package com.civicworks.repository.mysql;
import com.civicworks.model.mysql.Vote;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface VoteRepository extends JpaRepository<Vote, Long> {
    boolean existsByUserIdAndProjectId(Long userId, Long projectId);
    Optional<Vote> findByUserIdAndProjectIdAndType(Long userId, Long projectId, Vote.VoteType type);
}
