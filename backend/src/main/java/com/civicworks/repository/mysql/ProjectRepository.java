package com.civicworks.repository.mysql;
import com.civicworks.model.mysql.PublicWorkProject;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProjectRepository extends JpaRepository<PublicWorkProject, Long> {
    List<PublicWorkProject> findByProposerId(Long proposerId);
}
