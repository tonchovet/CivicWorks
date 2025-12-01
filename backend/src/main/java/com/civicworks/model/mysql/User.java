package com.civicworks.model.mysql;
import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Data
@Table(name = "users")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true)
    private String email;
    private String password;
    
    private String fullName;
    private String country;
    private String province;
    private String locality;
    private String address;

    @Enumerated(EnumType.STRING)
    private UserRole role;

    @Column(precision = 19, scale = 4)
    private BigDecimal walletBalance;

    @ElementCollection
    private List<Long> teamMemberIds = new ArrayList<>();
    
    public enum UserRole { CITIZEN, COMPANY }
}
