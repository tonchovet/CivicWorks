package com.civicworks.service;
import org.springframework.stereotype.Service;

@Service
public class NotificationService {
    public void notifyUser(String email, String subject, String message) {
        System.out.println(">>> NOTIFICATION to [" + email + "]: " + subject + " - " + message);
    }
}
