package com.sakamotodesu.mcare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;

@SpringBootApplication
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    // 実装順番
    // 　ログインしましたの分岐だけ
    // 　予約しましたの分岐だけ
    // 　予約結果のDB保存
    // 　　ローカル
    // 　　　DB起動
    // 　　　　Dockerでいいや
    // 　　　schema作成とか？
    // 　　　プロセスから接続
    // 　　AWS
    //     RDS
    // 　　　コード化
    // 　予約結果のメール通知
    // 　ユーザ管理
    // DBやってみたいこと
    // 　インデックス貼る
    // 　テーブルdrop
    // 　実行計画
    // 　まてびゅー
    // 　dbflute




    @RequestMapping("/")
    String home() {
        return "index";
    }

    public String getGreeting() {
        return "Hello world....";
    }

}
