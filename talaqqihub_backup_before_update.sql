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
-- Table structure for table `aiassistance`
--

DROP TABLE IF EXISTS `aiassistance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aiassistance` (
  `aiId` varchar(10) NOT NULL,
  `aiQuestion` text NOT NULL,
  `aiResponse` text NOT NULL,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`aiId`),
  KEY `idx_studentId` (`studentId`),
  KEY `idx_teacherId` (`teacherId`),
  CONSTRAINT `aiassistance_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aiassistance_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_AiAssistance_studentId` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_AiAssistance_teacherId` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aiassistance`
--

LOCK TABLES `aiassistance` WRITE;
/*!40000 ALTER TABLE `aiassistance` DISABLE KEYS */;
INSERT INTO `aiassistance` VALUES ('AI01','How to improve tajweed?','Practice daily recitation focusing on proper articulation points and listen to expert reciters.','S001','T001'),('AI02','What is sukoon?','Sukoon is the absence of a vowel on a letter, making the letter stop without any sound extension.','S002','T002'),('AI03','How to memorize faster?','Break Quran into small sections, repeat daily, and review previously memorized portions regularly.','S003',NULL),('AI04','Tips for kids learning Quran?','Make it fun with games, use colorful materials, keep sessions short, and praise progress.','S004',NULL),('AI05','Understanding Maddul Alif?','Maddul Alif is an extended vowel sound lasting 2-4 counts. Always appears with the letter Alif.','S005',NULL),('AI06','Correct pronunciation guide?','Identify each letter\'s makhraj (exit point), practice individually, then in words and sentences.','S006',NULL),('AI07','How to handle exam stress?','Prepare thoroughly, do deep breathing, get adequate sleep, and trust in your preparation.','S007',NULL),('AI08','Why is consistency important?','Consistency builds muscle memory, reinforces learning, and maintains steady progress in Quran study.','S008',NULL);
/*!40000 ALTER TABLE `aiassistance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendance` (
  `attendanceId` varchar(10) NOT NULL,
  `attendanceDate` date NOT NULL,
  `attendanceStatus` enum('Present','Absent','Late','Excused') NOT NULL,
  `joinTime` time DEFAULT NULL,
  `leaveTime` time DEFAULT NULL,
  `markAutoAttendance` tinyint(1) DEFAULT 0,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) NOT NULL,
  `scheduleId` varchar(10) NOT NULL,
  PRIMARY KEY (`attendanceId`),
  KEY `idx_studentId` (`studentId`),
  KEY `idx_teacherId` (`teacherId`),
  KEY `idx_scheduleId` (`scheduleId`),
  KEY `idx_date` (`attendanceDate`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendance_ibfk_3` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Attendance_scheduleId` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Attendance_studentId` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Attendance_teacherId` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendanceanalytics`
--

DROP TABLE IF EXISTS `attendanceanalytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendanceanalytics` (
  `attendanceAnalyticId` varchar(10) NOT NULL,
  `attendanceAnalyticDate` date NOT NULL,
  `attendanceAnalyticType` varchar(50) DEFAULT NULL,
  `attendanceInsights` text DEFAULT NULL,
  `managerId` varchar(10) NOT NULL,
  PRIMARY KEY (`attendanceAnalyticId`),
  KEY `idx_managerId` (`managerId`),
  KEY `idx_date` (`attendanceAnalyticDate`),
  CONSTRAINT `attendanceanalytics_ibfk_1` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_AttendanceAnalytics_managerId` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendanceanalytics`
--

LOCK TABLES `attendanceanalytics` WRITE;
/*!40000 ALTER TABLE `attendanceanalytics` DISABLE KEYS */;
INSERT INTO `attendanceanalytics` VALUES ('AA01','2025-02-01','Monthly Report','Overall attendance rate is 92%, exceeding targets','M001'),('AA06','2025-02-03','Gender Comparison','Female students 3% higher attendance than males','M001');
/*!40000 ALTER TABLE `attendanceanalytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendancerecordprogress`
--

DROP TABLE IF EXISTS `attendancerecordprogress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendancerecordprogress` (
  `recordId` varchar(10) NOT NULL,
  `absentSessions` int(11) DEFAULT 0,
  `attendedSessions` int(11) DEFAULT 0,
  `attendanceRate` decimal(5,2) DEFAULT NULL,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) NOT NULL,
  `packageId` varchar(10) NOT NULL,
  PRIMARY KEY (`recordId`),
  KEY `idx_studentId` (`studentId`),
  KEY `idx_teacherId` (`teacherId`),
  KEY `idx_packageId` (`packageId`),
  CONSTRAINT `attendancerecordprogress_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendancerecordprogress_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendancerecordprogress_ibfk_3` FOREIGN KEY (`packageId`) REFERENCES `packages` (`packageId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_AttendanceRecordProgress_packageId` FOREIGN KEY (`packageId`) REFERENCES `packages` (`packageId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_AttendanceRecordProgress_studentId` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_AttendanceRecordProgress_teacherId` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendancerecordprogress`
--

LOCK TABLES `attendancerecordprogress` WRITE;
/*!40000 ALTER TABLE `attendancerecordprogress` DISABLE KEYS */;
INSERT INTO `attendancerecordprogress` VALUES ('ARP01',0,10,100.00,'S001','T001','P001');
/*!40000 ALTER TABLE `attendancerecordprogress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classbooking`
--

DROP TABLE IF EXISTS `classbooking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classbooking` (
  `bookingId` varchar(10) NOT NULL,
  `bookingDate` date NOT NULL,
  `bookingTime` time NOT NULL,
  `bookingStatus` enum('Pending','Confirmed','Cancelled','Completed','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  `studentId` varchar(10) NOT NULL,
  `scheduleId` varchar(10) NOT NULL,
  PRIMARY KEY (`bookingId`),
  KEY `idx_studentId` (`studentId`),
  KEY `idx_scheduleId` (`scheduleId`),
  KEY `idx_status` (`bookingStatus`),
  CONSTRAINT `classbooking_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `classbooking_ibfk_2` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ClassBooking_scheduleId` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ClassBooking_studentId` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classbooking`
--

LOCK TABLES `classbooking` WRITE;
/*!40000 ALTER TABLE `classbooking` DISABLE KEYS */;
INSERT INTO `classbooking` VALUES ('B002','2026-05-30','10:00:00','Cancelled','S006','C050'),('B003','2026-05-30','10:15:00','Cancelled','S006','C051'),('B004','2026-05-30','10:45:00','Pending','S006','C053'),('B005','2026-05-31','20:00:00','Pending','S006','C054');
/*!40000 ALTER TABLE `classbooking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classschedule`
--

DROP TABLE IF EXISTS `classschedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classschedule` (
  `scheduleId` varchar(10) NOT NULL,
  `teacherId` varchar(10) DEFAULT NULL,
  `studentId` varchar(10) DEFAULT NULL,
  `className` varchar(100) DEFAULT NULL,
  `scheduleDate` date NOT NULL,
  `startTime` time NOT NULL,
  `endTime` time NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `classStatus` enum('Scheduled','Ongoing','Completed','Cancelled') NOT NULL DEFAULT 'Scheduled',
  `classJuzuk` int(11) DEFAULT NULL,
  `classSurah` int(11) DEFAULT NULL,
  `classAyah` int(11) DEFAULT NULL,
  PRIMARY KEY (`scheduleId`),
  KEY `idx_date` (`scheduleDate`),
  KEY `idx_status` (`classStatus`),
  KEY `teacherId` (`teacherId`),
  CONSTRAINT `classschedule_ibfk_1` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classschedule`
--

LOCK TABLES `classschedule` WRITE;
/*!40000 ALTER TABLE `classschedule` DISABLE KEYS */;
INSERT INTO `classschedule` VALUES ('C001','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','08:45:00','09:00:00',15,'Scheduled',NULL,NULL,NULL),('C002','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','08:30:00','08:45:00',15,'Scheduled',NULL,NULL,NULL),('C003','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','10:00:00','10:15:00',15,'Scheduled',NULL,NULL,NULL),('C004','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','10:15:00','10:30:00',15,'Scheduled',NULL,NULL,NULL),('C005','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','12:00:00','12:15:00',15,'Scheduled',NULL,NULL,NULL),('C006','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','12:15:00','12:30:00',15,'Scheduled',NULL,NULL,NULL),('C007','T001',NULL,'Quran Recitation & Tajweed','2026-01-24','17:15:00','17:30:00',15,'Scheduled',NULL,NULL,NULL),('C008','T001',NULL,'Quran Recitation & Tajweed','2026-01-24','17:30:00','17:45:00',15,'Scheduled',NULL,NULL,NULL),('C009','T001',NULL,'Quran Recitation & Tajweed','2026-01-24','17:45:00','18:00:00',15,'Scheduled',NULL,NULL,NULL),('C010','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','13:00:00','13:15:00',15,'Scheduled',NULL,NULL,NULL),('C011','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','13:15:00','13:30:00',15,'Scheduled',NULL,NULL,NULL),('C012','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','13:30:00','13:45:00',15,'Scheduled',NULL,NULL,NULL),('C013','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','13:45:00','14:00:00',15,'Scheduled',NULL,NULL,NULL),('C014','T001',NULL,'Quran Recitation & Tajweed','2026-01-28','13:45:00','14:00:00',15,'Scheduled',NULL,NULL,NULL),('C015','T001',NULL,'Quran Recitation & Tajweed','2026-01-28','14:00:00','14:15:00',15,'Scheduled',NULL,NULL,NULL),('C016','T001',NULL,'Quran Recitation & Tajweed','2026-01-28','14:15:00','14:30:00',15,'Scheduled',NULL,NULL,NULL),('C017','T001',NULL,'Quran Recitation & Tajweed','2026-01-28','14:30:00','14:45:00',15,'Scheduled',NULL,NULL,NULL),('C018','T001',NULL,'Quran Recitation & Tajweed','2026-01-30','10:00:00','10:15:00',15,'Scheduled',NULL,NULL,NULL),('C019','T001',NULL,'Quran Recitation & Tajweed','2026-01-30','10:15:00','10:30:00',15,'Scheduled',NULL,NULL,NULL),('C020','T001',NULL,'Quran Recitation & Tajweed','2026-01-30','10:30:00','10:45:00',15,'Scheduled',NULL,NULL,NULL),('C021','T001',NULL,'Quran Recitation & Tajweed','2026-01-30','10:45:00','11:00:00',15,'Scheduled',NULL,NULL,NULL),('C022','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','10:00:00','10:15:00',15,'Scheduled',NULL,NULL,NULL),('C023','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','10:15:00','10:30:00',15,'Scheduled',NULL,NULL,NULL),('C024','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','10:30:00','10:45:00',15,'Scheduled',NULL,NULL,NULL),('C025','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','10:45:00','11:00:00',15,'Scheduled',NULL,NULL,NULL),('C026','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','11:00:00','11:15:00',15,'Scheduled',NULL,NULL,NULL),('C027','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','11:15:00','11:30:00',15,'Scheduled',NULL,NULL,NULL),('C028','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','11:30:00','11:45:00',15,'Scheduled',NULL,NULL,NULL),('C029','T003',NULL,'Quran Recitation & Tajweed','2026-01-23','11:45:00','12:00:00',15,'Scheduled',NULL,NULL,NULL),('C030','T003',NULL,'Quran Recitation & Tajweed','2026-01-26','08:00:00','08:15:00',15,'Scheduled',NULL,NULL,NULL),('C031','T003',NULL,'Quran Recitation & Tajweed','2026-01-26','08:15:00','08:30:00',15,'Scheduled',NULL,NULL,NULL),('C032','T003',NULL,'Quran Recitation & Tajweed','2026-01-26','08:30:00','08:45:00',15,'Scheduled',NULL,NULL,NULL),('C033','T003',NULL,'Quran Recitation & Tajweed','2026-01-26','08:45:00','09:00:00',15,'Scheduled',NULL,NULL,NULL),('C034','T003',NULL,'Quran Recitation & Tajweed','2026-01-27','10:00:00','10:15:00',15,'Scheduled',NULL,NULL,NULL),('C035','T003',NULL,'Quran Recitation & Tajweed','2026-01-27','10:15:00','10:30:00',15,'Scheduled',NULL,NULL,NULL),('C036','T003',NULL,'Quran Recitation & Tajweed','2026-01-27','10:30:00','10:45:00',15,'Scheduled',NULL,NULL,NULL),('C037','T003',NULL,'Quran Recitation & Tajweed','2026-01-27','10:45:00','11:00:00',15,'Scheduled',NULL,NULL,NULL),('C038','T003',NULL,'Quran Recitation & Tajweed','2026-01-27','11:00:00','11:15:00',15,'Scheduled',NULL,NULL,NULL),('C039','T003',NULL,'Quran Recitation & Tajweed','2026-01-27','11:15:00','11:30:00',15,'Scheduled',NULL,NULL,NULL),('C040','T003',NULL,'Quran Recitation & Tajweed','2026-01-28','13:00:00','13:15:00',15,'Scheduled',NULL,NULL,NULL),('C041','T003',NULL,'Quran Recitation & Tajweed','2026-01-28','13:15:00','13:30:00',15,'Scheduled',NULL,NULL,NULL),('C042','T003',NULL,'Quran Recitation & Tajweed','2026-01-28','13:30:00','13:45:00',15,'Scheduled',NULL,NULL,NULL),('C043','T003',NULL,'Quran Recitation & Tajweed','2026-01-28','13:45:00','14:00:00',15,'Scheduled',NULL,NULL,NULL),('C044','T003',NULL,'Quran Recitation & Tajweed','2026-01-29','17:00:00','17:15:00',15,'Scheduled',NULL,NULL,NULL),('C045','T003',NULL,'Quran Recitation & Tajweed','2026-01-29','17:15:00','17:30:00',15,'Scheduled',NULL,NULL,NULL),('C046','T003',NULL,'Quran Recitation & Tajweed','2026-01-29','17:30:00','17:45:00',15,'Scheduled',NULL,NULL,NULL),('C047','T003',NULL,'Quran Recitation & Tajweed','2026-01-29','17:45:00','18:00:00',15,'Scheduled',NULL,NULL,NULL),('C048','T001',NULL,'Quran Recitation & Tajweed','2026-05-29','08:00:00','08:15:00',15,'Scheduled',NULL,NULL,NULL),('C049','T001',NULL,'Quran Recitation & Tajweed','2026-05-29','08:15:00','08:30:00',15,'Scheduled',NULL,NULL,NULL),('C050','T001',NULL,'Quran Recitation & Tajweed','2026-05-30','10:00:00','10:15:00',15,'Cancelled',NULL,NULL,NULL),('C051','T001',NULL,'Quran Recitation & Tajweed','2026-05-30','10:15:00','10:30:00',15,'Scheduled',NULL,NULL,NULL),('C052','T001',NULL,'Quran Recitation & Tajweed','2026-05-30','10:30:00','10:45:00',15,'Scheduled',NULL,NULL,NULL),('C053','T001',NULL,'Quran Recitation & Tajweed','2026-05-30','10:45:00','11:00:00',15,'Scheduled',NULL,NULL,NULL),('C054','T001',NULL,'Quran Recitation & Tajweed','2026-05-31','20:00:00','20:15:00',15,'Scheduled',NULL,NULL,NULL),('C055','T001',NULL,'Quran Recitation & Tajweed','2026-05-31','20:15:00','20:30:00',15,'Scheduled',NULL,NULL,NULL);
/*!40000 ALTER TABLE `classschedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluationanalytics`
--

DROP TABLE IF EXISTS `evaluationanalytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluationanalytics` (
  `evaluationAnalyticId` varchar(10) NOT NULL,
  `evaluationAnalyticDate` date NOT NULL,
  `evaluationAnalyticType` varchar(50) DEFAULT NULL,
  `evaluationInsights` text DEFAULT NULL,
  `managerId` varchar(10) NOT NULL,
  PRIMARY KEY (`evaluationAnalyticId`),
  KEY `idx_managerId` (`managerId`),
  KEY `idx_date` (`evaluationAnalyticDate`),
  CONSTRAINT `evaluationanalytics_ibfk_1` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_EvaluationAnalytics_managerId` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluationanalytics`
--

LOCK TABLES `evaluationanalytics` WRITE;
/*!40000 ALTER TABLE `evaluationanalytics` DISABLE KEYS */;
INSERT INTO `evaluationanalytics` VALUES ('EA01','2025-02-01','Monthly Assessment','Average student performance score is 85%','M001'),('EA06','2025-02-03','Weakness Analysis','60% students struggle with recitation speed','M001');
/*!40000 ALTER TABLE `evaluationanalytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manager`
--

DROP TABLE IF EXISTS `manager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manager` (
  `managerId` varchar(10) NOT NULL,
  `managerName` varchar(100) NOT NULL,
  `managerEmail` varchar(100) NOT NULL,
  `managerPassword` varchar(255) NOT NULL,
  `managerPhoneNo` varchar(15) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `securityQuestion` varchar(255) DEFAULT NULL,
  `securityAnswer` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`managerId`),
  UNIQUE KEY `managerEmail` (`managerEmail`),
  KEY `idx_email` (`managerEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manager`
--

LOCK TABLES `manager` WRITE;
/*!40000 ALTER TABLE `manager` DISABLE KEYS */;
INSERT INTO `manager` VALUES ('M001','Iffah Afiqah','iffah@gmail.com','iffah123','60123456789','Operations','What is your favorite city?','Mecca');
/*!40000 ALTER TABLE `manager` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` varchar(36) NOT NULL,
  `userType` varchar(20) NOT NULL,
  `userId` varchar(10) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `bookingId` varchar(10) DEFAULT NULL,
  `relatedScheduleId` varchar(10) DEFAULT NULL,
  `isRead` tinyint(1) DEFAULT 0,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user` (`userType`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `packages` (
  `packageId` varchar(10) NOT NULL,
  `packageName` varchar(100) NOT NULL,
  `packageType` varchar(50) DEFAULT NULL,
  `totalSessions` int(11) NOT NULL,
  `managerId` varchar(10) NOT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `rangeAge` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`packageId`),
  KEY `idx_managerId` (`managerId`),
  CONSTRAINT `fk_Packages_managerId` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `packages_ibfk_1` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packages`
--

LOCK TABLES `packages` WRITE;
/*!40000 ALTER TABLE `packages` DISABLE KEYS */;
INSERT INTO `packages` VALUES ('P001','TalaqqiSpark','Kids',8,'M001',120.00,'6-12','A gentle introduction to Quran learning for children. Short and focused sessions help kids stay attentive while building confidence step by step.'),('P002','TalaqqiSpark+','Kids',16,'M001',220.00,'6-12','Perfect for children who need more regular practice. Consistent sessions support better recitation, focus, and learning habits.'),('P003','TalaqqiPro','Adults',8,'M001',160.00,'13+','Suitable for adult learners who want guided Quran learning in short, focused sessions that fit into a busy schedule.'),('P004','TalaqqiPro+','Adults',16,'M001',300.00,'13+','Best for adults who want consistent guidance and steady improvement through regular talaqqi sessions and teacher feedback.'),('P005','TalaqqiAlpha','Kids',8,'M001',80.00,'< 6','Introduces toddlers to Quranic sounds, Hijaiyah letters, and basic Islamic values in an engaging way.');
/*!40000 ALTER TABLE `packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `qurandisplay`
--

DROP TABLE IF EXISTS `qurandisplay`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qurandisplay` (
  `displayId` varchar(10) NOT NULL,
  `currentJuzuk` int(11) DEFAULT NULL,
  `currentSurah` int(11) DEFAULT NULL,
  `currentAyah` int(11) DEFAULT NULL,
  `sessionId` varchar(10) NOT NULL,
  PRIMARY KEY (`displayId`),
  KEY `idx_sessionId` (`sessionId`),
  CONSTRAINT `fk_QuranDisplay_sessionId` FOREIGN KEY (`sessionId`) REFERENCES `talaqqisession` (`sessionId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `qurandisplay_ibfk_1` FOREIGN KEY (`sessionId`) REFERENCES `talaqqisession` (`sessionId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qurandisplay`
--

LOCK TABLES `qurandisplay` WRITE;
/*!40000 ALTER TABLE `qurandisplay` DISABLE KEYS */;
/*!40000 ALTER TABLE `qurandisplay` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student` (
  `studentId` varchar(10) NOT NULL,
  `studentName` varchar(100) NOT NULL,
  `studentEmail` varchar(100) NOT NULL,
  `studentPassword` varchar(255) NOT NULL,
  `studentPhoneNo` varchar(15) DEFAULT NULL,
  `studentDateofBirth` date DEFAULT NULL,
  `registrationDate` date NOT NULL,
  `studentStatus` enum('Active','Inactive','Suspended') NOT NULL DEFAULT 'Active',
  `studentSecQues` varchar(255) DEFAULT NULL,
  `studentSecPassword` varchar(255) DEFAULT NULL,
  `packageId` varchar(10) NOT NULL,
  PRIMARY KEY (`studentId`),
  UNIQUE KEY `studentEmail` (`studentEmail`),
  KEY `idx_email` (`studentEmail`),
  KEY `idx_status` (`studentStatus`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES ('S001','Hannah Delisha','hannah@gmail.com','hannah123','60189001234','2005-03-15','2025-01-05','Active','Favorite Color','Blue','P001'),('S002','Fattah Amin','fattah@gmail.com','fattah123','60187654327','2004-07-22','2025-01-10','Active','Favorite Animal','Cat','P002'),('S003','Raja Amirah','raja@gmail.com','raja123','60123456790','2006-11-08','2025-01-12','Active','First School','Al-Noor','P001'),('S004','Kamal Adli','kamal@gmail.com','kamal123','60198765433','2003-05-30','2025-01-15','Active','Hometown','KL','P003'),('S005','Mira Filzah','mira@gmail.com','mira123','60112345679','2007-02-14','2025-01-18','Active','Pet Name','Luna','P004'),('S006','Amir Ahnaf','amir@gmail.com','amir123','60156789013','2005-09-25','2025-01-20','Active','Sports','Football','P002'),('S007','Erysha Emyra','erysha@gmail.com','erysha123','60189001235','2004-04-17','2025-01-22','Active','Color','Green','P005'),('S008','Nadhir Nasar','nadhir@gmail.com','nadhir123','60187654328','2006-08-03','2025-01-25','Inactive','Book','Quran','P001'),('S009','Qasrina Karim','qasrina@gmail.com','qas123','0197972525','2012-08-10','2026-05-31','Active','What was the name of your first school?','SMK Perak','P005');
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `studentcancellation`
--

DROP TABLE IF EXISTS `studentcancellation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `studentcancellation` (
  `bookingId` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cancellationReason` text DEFAULT NULL,
  `cancelledAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `cancelledBy` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`bookingId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `studentcancellation`
--

LOCK TABLES `studentcancellation` WRITE;
/*!40000 ALTER TABLE `studentcancellation` DISABLE KEYS */;
INSERT INTO `studentcancellation` VALUES ('B002','sick','2026-05-30 04:36:33','teacher'),('B003','Clash with appointment clinic','2026-05-30 05:14:32','student');
/*!40000 ALTER TABLE `studentcancellation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `studentevaluation`
--

DROP TABLE IF EXISTS `studentevaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `studentevaluation` (
  `studentEvaluationId` varchar(10) NOT NULL,
  `tajweedScore` int(11) DEFAULT NULL CHECK (`tajweedScore` >= 0 and `tajweedScore` <= 100),
  `fluencyScore` int(11) DEFAULT NULL CHECK (`fluencyScore` >= 0 and `fluencyScore` <= 100),
  `accuracyScore` int(11) DEFAULT NULL CHECK (`accuracyScore` >= 0 and `accuracyScore` <= 100),
  `strength` varchar(255) DEFAULT NULL,
  `weakness` varchar(255) DEFAULT NULL,
  `studentImprovements` text DEFAULT NULL,
  `nextTarget` varchar(255) DEFAULT NULL,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) NOT NULL,
  `scheduleId` varchar(10) NOT NULL,
  PRIMARY KEY (`studentEvaluationId`),
  KEY `idx_studentId` (`studentId`),
  KEY `idx_teacherId` (`teacherId`),
  KEY `idx_scheduleId` (`scheduleId`),
  CONSTRAINT `fk_StudentEvaluation_scheduleId` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_StudentEvaluation_studentId` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_StudentEvaluation_teacherId` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `studentevaluation_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `studentevaluation_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `studentevaluation_ibfk_3` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `studentevaluation`
--

LOCK TABLES `studentevaluation` WRITE;
/*!40000 ALTER TABLE `studentevaluation` DISABLE KEYS */;
/*!40000 ALTER TABLE `studentevaluation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `talaqqisession`
--

DROP TABLE IF EXISTS `talaqqisession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `talaqqisession` (
  `sessionId` varchar(10) NOT NULL,
  `sessionType` varchar(50) DEFAULT NULL,
  `sessionDate` date NOT NULL,
  `scheduleId` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`sessionId`),
  KEY `idx_date` (`sessionDate`),
  KEY `idx_scheduleId` (`scheduleId`),
  CONSTRAINT `fk_TalaqqiSession_scheduleId` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `talaqqisession`
--

LOCK TABLES `talaqqisession` WRITE;
/*!40000 ALTER TABLE `talaqqisession` DISABLE KEYS */;
INSERT INTO `talaqqisession` VALUES ('S001','Live Talaqqi','2026-05-30','C050'),('S002','Live Talaqqi','2026-05-30','C051'),('S003','Live Talaqqi','2026-05-30','C053'),('S004','Live Talaqqi','2026-05-31','C054');
/*!40000 ALTER TABLE `talaqqisession` ENABLE KEYS */;
UNLOCK TABLES;

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

--
-- Table structure for table `teacherevaluation`
--

DROP TABLE IF EXISTS `teacherevaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teacherevaluation` (
  `teacherEvaluationId` varchar(10) NOT NULL,
  `evaluationDate` date NOT NULL,
  `teacherComments` text DEFAULT NULL,
  `teacherImprovements` text DEFAULT NULL,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) NOT NULL,
  `scheduleId` varchar(10) NOT NULL,
  PRIMARY KEY (`teacherEvaluationId`),
  KEY `idx_studentId` (`studentId`),
  KEY `idx_teacherId` (`teacherId`),
  KEY `idx_scheduleId` (`scheduleId`),
  KEY `idx_date` (`evaluationDate`),
  CONSTRAINT `fk_TeacherEvaluation_scheduleId` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_TeacherEvaluation_studentId` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_TeacherEvaluation_teacherId` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `teacherevaluation_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `teacherevaluation_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `teacherevaluation_ibfk_3` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacherevaluation`
--

LOCK TABLES `teacherevaluation` WRITE;
/*!40000 ALTER TABLE `teacherevaluation` DISABLE KEYS */;
/*!40000 ALTER TABLE `teacherevaluation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `v_active_subscriptions`
--

DROP TABLE IF EXISTS `v_active_subscriptions`;
