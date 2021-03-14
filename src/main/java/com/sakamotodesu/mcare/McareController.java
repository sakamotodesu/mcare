package com.sakamotodesu.mcare;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class McareController {

    @RequestMapping("/login")
    String login() {
        return "login";
    }

    @RequestMapping("/login_yes")
    String loginYes() {
        return "login_yes";
    }
}
