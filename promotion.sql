/*
Navicat MySQL Data Transfer

Source Server         : myDB
Source Server Version : 80017
Source Host           : localhost:3306
Source Database       : promotion

Target Server Type    : MYSQL
Target Server Version : 80017
File Encoding         : 65001

Date: 2019-09-05 22:08:00
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `username` char(11) NOT NULL,
  `password` char(32) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for commodity
-- ----------------------------
DROP TABLE IF EXISTS `commodity`;
CREATE TABLE `commodity` (
  `id` bigint(12) unsigned NOT NULL AUTO_INCREMENT,
  `shopId` int(10) unsigned NOT NULL,
  `name` varchar(20) NOT NULL,
  `class` varchar(12) NOT NULL,
  `originalPrice` decimal(8,2) DEFAULT NULL,
  `price` decimal(8,2) NOT NULL,
  `details` tinytext NOT NULL,
  `promotionInfo` tinytext NOT NULL,
  `pic1` varchar(45) NOT NULL,
  `pic2` varchar(45) DEFAULT NULL,
  `pic3` varchar(45) DEFAULT NULL,
  `pic4` varchar(45) DEFAULT NULL,
  `pic5` varchar(45) DEFAULT NULL,
  `startTime` datetime NOT NULL,
  `endTime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `shop_commodity_FK1_idx` (`shopId`),
  CONSTRAINT `shop_commodity_FK1` FOREIGN KEY (`shopId`) REFERENCES `shop` (`shopId`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for favor
-- ----------------------------
DROP TABLE IF EXISTS `favor`;
CREATE TABLE `favor` (
  `userId` char(11) NOT NULL,
  `shopId` int(10) unsigned NOT NULL,
  PRIMARY KEY (`userId`,`shopId`),
  KEY `shop_favor_FK1_idx` (`shopId`),
  KEY `user_favor_FK1_idx` (`userId`),
  CONSTRAINT `shop_favor_FK1` FOREIGN KEY (`shopId`) REFERENCES `shop` (`shopId`),
  CONSTRAINT `user_favor_FK1` FOREIGN KEY (`userId`) REFERENCES `user` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for owner
-- ----------------------------
DROP TABLE IF EXISTS `owner`;
CREATE TABLE `owner` (
  `username` char(11) NOT NULL,
  `password` char(32) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for report
-- ----------------------------
DROP TABLE IF EXISTS `report`;
CREATE TABLE `report` (
  `reportId` int(10) NOT NULL AUTO_INCREMENT,
  `userId` char(11) NOT NULL,
  `shopId` int(10) unsigned NOT NULL,
  `cmdtId` bigint(12) unsigned NOT NULL,
  `reason` tinytext NOT NULL,
  `reportState` tinyint(1) NOT NULL,
  PRIMARY KEY (`reportId`),
  KEY `shop_report_FK1_idx` (`shopId`),
  KEY `commodity_report_FK1_idx` (`cmdtId`),
  KEY `user_report_FK1_idx` (`userId`),
  CONSTRAINT `commodity_report_FK1` FOREIGN KEY (`cmdtId`) REFERENCES `commodity` (`id`),
  CONSTRAINT `shop_report_FK1` FOREIGN KEY (`shopId`) REFERENCES `shop` (`shopId`),
  CONSTRAINT `user_report_FK1` FOREIGN KEY (`userId`) REFERENCES `user` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for shop
-- ----------------------------
DROP TABLE IF EXISTS `shop`;
CREATE TABLE `shop` (
  `shopId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner` char(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `time` varchar(30) NOT NULL,
  `address` varchar(45) NOT NULL,
  `lat` float(10,6) NOT NULL,
  `lng` float(10,6) NOT NULL,
  `tel` varchar(15) NOT NULL,
  `legalRepr` varchar(20) NOT NULL,
  `idNumber` char(18) NOT NULL,
  `shopImg` varchar(45) NOT NULL,
  `withIdFrontImg` varchar(45) NOT NULL,
  `withIdBackImg` varchar(45) NOT NULL,
  `licenseImg` varchar(45) NOT NULL,
  `notice` tinytext,
  `shopState` tinyint(1) NOT NULL,
  `toBeChecked` tinyint(1) NOT NULL,
  `checkMsg` tinytext,
  PRIMARY KEY (`shopId`),
  KEY `shop_FK1` (`owner`),
  KEY `location` (`lng`,`lat`),
  CONSTRAINT `owner_shop_FK1` FOREIGN KEY (`owner`) REFERENCES `owner` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `username` char(11) NOT NULL,
  `password` char(32) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Function structure for levenshtein
-- ----------------------------
DROP FUNCTION IF EXISTS `levenshtein`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `levenshtein`(`s1` varchar(255),`s2` varchar(255)) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE s1_len, s2_len, i, j, c, c_temp, cost INT;
DECLARE s1_char CHAR;
-- max strlen=255
DECLARE cv0, cv1 VARBINARY(256);
SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0;
IF s1 = s2 THEN
RETURN 0;
ELSEIF s1_len = 0 THEN
RETURN s2_len;
ELSEIF s2_len = 0 THEN
RETURN s1_len;
ELSE
WHILE j <= s2_len DO
SET cv1 = CONCAT(cv1, UNHEX(HEX(j))), j = j + 1;
END WHILE;
WHILE i <= s1_len DO
SET s1_char = SUBSTRING(s1, i, 1), c = i, cv0 = UNHEX(HEX(i)), j = 1;
WHILE j <= s2_len DO
SET c = c + 1;
IF s1_char = SUBSTRING(s2, j, 1) THEN 
SET cost = 0; ELSE SET cost = 1;
END IF;
SET c_temp = CONV(HEX(SUBSTRING(cv1, j, 1)), 16, 10) + cost;
IF c > c_temp THEN SET c = c_temp; END IF;
SET c_temp = CONV(HEX(SUBSTRING(cv1, j+1, 1)), 16, 10) + 1;
IF c > c_temp THEN 
SET c = c_temp; 
END IF;
SET cv0 = CONCAT(cv0, UNHEX(HEX(c))), j = j + 1;
END WHILE;
SET cv1 = cv0, i = i + 1;
END WHILE;
END IF;
RETURN c;
END
;;
DELIMITER ;

-- ----------------------------
-- Function structure for levenshtein_ratio
-- ----------------------------
DROP FUNCTION IF EXISTS `levenshtein_ratio`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `levenshtein_ratio`(`s1` varchar(255),`s2` varchar(255)) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE s1_len, s2_len, max_len INT;
SET s1_len = LENGTH(s1), s2_len = LENGTH(s2);
IF s1_len > s2_len THEN 
SET max_len = s1_len; 
ELSE 
SET max_len = s2_len; 
END IF;
RETURN ROUND((1 - LEVENSHTEIN(s1, s2) / max_len) * 100);
END
;;
DELIMITER ;
