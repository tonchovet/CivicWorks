package com.civicworks.repository.mysql;
import com.civicworks.model.mysql.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByEmailContaining(String email);
    long countByLocalityAndRole(String locality, User.UserRole role);
}
