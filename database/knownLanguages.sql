-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema knownLanguages
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema knownLanguages
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `knownLanguages` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `knownLanguages` ;

-- -----------------------------------------------------
-- Table `knownLanguages`.`userSession`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `knownLanguages`.`userSession` (
  `token` VARCHAR(500) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `device` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`token`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `knownLanguages`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `knownLanguages`.`users` (
  `name` VARCHAR(255) NOT NULL,
  `password` LONGTEXT NOT NULL,
  `email` LONGTEXT NOT NULL,
  `DOB` DATE NULL DEFAULT NULL,
  `gender` VARCHAR(255) NULL DEFAULT NULL,
  `dateOfCreation` DATETIME NOT NULL,
  PRIMARY KEY (`name`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
