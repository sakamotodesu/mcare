---- drop ----
DROP TABLE IF EXISTS `reserve`;

---- create ----
create table IF not exists `reserve`
(
 `id`               INT(20) AUTO_INCREMENT,
 `reserve_date`       Datetime DEFAULT NULL,
    PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_bin;