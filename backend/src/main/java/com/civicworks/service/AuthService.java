package com.civicworks.service;

import com.civicworks.model.mysql.User;
import com.civicworks.repository.mysql.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class AuthService {
    @Autowired private UserRepository userRepo;

    public User register(User user) {
        if(userRepo.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("Email ya registrado");
        }
        user.setWalletBalance(new BigDecimal("5000.00")); 
        return userRepo.save(user);
    }

    public User login(String email, String password) {
        User u = userRepo.findByEmail(email).orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        if(!u.getPassword().equals(password)) {
            throw new RuntimeException("Contraseña incorrecta");
        }
        return u;
    }
    
    public void addTeamMember(Long companyId, String memberEmail) {
        User company = userRepo.findById(companyId).orElseThrow();
        if(company.getRole() != User.UserRole.COMPANY) throw new RuntimeException("Solo empresas pueden tener equipo");
        
        User member = userRepo.findByEmail(memberEmail).orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        company.getTeamMemberIds().add(member.getId());
        userRepo.save(company);
    }

    public List<User> searchUsers(String query) {
        return userRepo.findByEmailContaining(query);
    }

    public List<User> getTeamMembers(Long companyId) {
        User company = userRepo.findById(companyId).orElseThrow();
        List<User> members = new ArrayList<>();
        for(Long id : company.getTeamMemberIds()){
            userRepo.findById(id).ifPresent(members::add);
        }
        return members;
    }
}
