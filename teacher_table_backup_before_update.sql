-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: talaqqihub_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `teacher`
--

DROP TABLE IF EXISTS `teacher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teacher` (
  `teacherId` varchar(10) NOT NULL,
  `teacherName` varchar(100) NOT NULL,
  `teacherEmail` varchar(100) NOT NULL,
  `teacherPassword` varchar(255) NOT NULL,
  `teacherPhoneNo` varchar(15) DEFAULT NULL,
  `teacherDateofBirth` date DEFAULT NULL,
  `registrationDate` date NOT NULL,
  `teacherStatus` enum('Active','Inactive','Pending') NOT NULL DEFAULT 'Active',
  `teacherSecQues` varchar(255) DEFAULT NULL,
  `teacherSecPassword` varchar(255) DEFAULT NULL,
  `qualifications` varchar(255) DEFAULT NULL,
  `specialtyArea` varchar(100) DEFAULT NULL,
  `averageRating` decimal(3,2) DEFAULT NULL,
  `approvalStatusCertRefNo` varchar(50) DEFAULT NULL,
  `certificationPath` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`teacherId`),
  UNIQUE KEY `teacherEmail` (`teacherEmail`),
  KEY `idx_email` (`teacherEmail`),
  KEY `idx_status` (`teacherStatus`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher`
--

LOCK TABLES `teacher` WRITE;
/*!40000 ALTER TABLE `teacher` DISABLE KEYS */;
INSERT INTO `teacher` VALUES ('T001','Ustaz Azhar Idrus','azhar@gmail.com','azhar123','60189001236','1978-01-20','2024-12-01','Active','Favorite Surah','Yaseen','Islamic Studies PhD','Tajweed',4.80,'CERT001',NULL),('T002','Ustaz Ebit Lew','ebit@gmail.com','ebit123','60187654329','1985-05-10','2024-12-05','Active','Birth City','Cairo','Islamic University Graduate','Quran Recitation',4.90,'CERT002',NULL),('T003','Ustazah Asma\' Harun','asma@gmail.com','asma123','0116789014','1986-06-13','2026-01-16','Active','What is your favorite book?','Sirah Nabi','Master in Quranic Studies','Quran Recitation',NULL,NULL,NULL),('T004','Ustazah Norhafizah Musa','hafizah@gmail.com','hafizah123','0167890125','1984-10-31','2026-01-16','Active','What city were you born in?','Madinah','Bachelor in Quran & Hadith Studies','Islamic Studies',NULL,NULL,NULL),('T005','Ustaz Wadi Annuar','wadi@gmail.com','54f2cb4480927400fd567752ae21984727892044df2df6f860bb15a7df136b0c','0197556464','1964-10-27','2026-06-02','Active','What is your favorite book?','Alquran','Bachelor of Alquran Sunnah','Quran Recitation',NULL,NULL,NULL);
/*!40000 ALTER TABLE `teacher` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-02 12:46:39
