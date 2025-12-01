package com.civicworks.controller;

import com.civicworks.model.mysql.User;
import com.civicworks.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired private AuthService authService;

    @PostMapping("/register")
    public User register(@RequestBody User user) {
        return authService.register(user);
    }

    @PostMapping("/login")
    public User login(@RequestBody LoginRequest req) {
        return authService.login(req.email, req.password);
    }
    
    @PostMapping("/{id}/team")
    public String addMember(@PathVariable Long id, @RequestParam String email) {
        authService.addTeamMember(id, email);
        return "Miembro agregado";
    }

    @GetMapping("/search")
    public List<User> searchUsers(@RequestParam String query) {
        return authService.searchUsers(query);
    }

    @GetMapping("/{id}/team-details")
    public List<User> getTeamMembers(@PathVariable Long id) {
        return authService.getTeamMembers(id);
    }

    public static class LoginRequest {
        public String email;
        public String password;
    }
}
