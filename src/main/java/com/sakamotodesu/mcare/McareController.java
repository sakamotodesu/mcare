package com.sakamotodesu.mcare;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Controller
public class McareController {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Autowired
    JdbcTemplate jdbcTemplate;

    @RequestMapping("/login")
    String login() {
        return "login";
    }

    @RequestMapping("/login_yes")
    String loginYes() {
        return "login_yes";
    }

    @RequestMapping("/reserve_yes")
    String reserveYes(Model model) {
        jdbcTemplate.update("INSERT INTO reserve(reserve_date) VALUES('2000-01-01 10:00:00')");

        List<String> reserveList = jdbcTemplate.query(
                "SELECT id, reserve_date FROM reserve",
                (rs, date) -> new Reserve(rs.getInt("id"),
                        //rs.getString("reserve_date"))).forEach(reserve -> logger.info(reserve.toString()));
                        rs.getString("reserve_date"))).stream().map(Reserve::getDate).collect(Collectors.toList());
        reserveList.forEach(logger::info);
        model.addAttribute("reserveList",reserveList);
        return "reserve_yes";
    }
}
