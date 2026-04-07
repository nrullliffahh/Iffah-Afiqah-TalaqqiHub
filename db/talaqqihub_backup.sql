-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: talaqqihub
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
  `aid` varchar(10) NOT NULL,
  `aiQuestion` text NOT NULL,
  `aiResponse` text NOT NULL,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`aid`),
  KEY `studentId` (`studentId`),
  KEY `teacherId` (`teacherId`),
  CONSTRAINT `aiassistance_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aiassistance_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aiassistance`
--

LOCK TABLES `aiassistance` WRITE;
/*!40000 ALTER TABLE `aiassistance` DISABLE KEYS */;
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
  `attendanceStatus` enum('Present','Absent','Late') NOT NULL,
  `joinTime` time DEFAULT NULL,
  `leaveTime` time DEFAULT NULL,
  `markAutoAttendance` tinyint(1) DEFAULT 0,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) NOT NULL,
  `scheduleId` varchar(10) NOT NULL,
  PRIMARY KEY (`attendanceId`),
  KEY `studentId` (`studentId`),
  KEY `teacherId` (`teacherId`),
  KEY `scheduleId` (`scheduleId`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendance_ibfk_3` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
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
  KEY `managerId` (`managerId`),
  CONSTRAINT `attendanceanalytics_ibfk_1` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendanceanalytics`
--

LOCK TABLES `attendanceanalytics` WRITE;
/*!40000 ALTER TABLE `attendanceanalytics` DISABLE KEYS */;
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
  KEY `studentId` (`studentId`),
  KEY `teacherId` (`teacherId`),
  KEY `packageId` (`packageId`),
  CONSTRAINT `attendancerecordprogress_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendancerecordprogress_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `attendancerecordprogress_ibfk_3` FOREIGN KEY (`packageId`) REFERENCES `packages` (`packageId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendancerecordprogress`
--

LOCK TABLES `attendancerecordprogress` WRITE;
/*!40000 ALTER TABLE `attendancerecordprogress` DISABLE KEYS */;
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
  `bookingStatus` enum('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  `studentId` varchar(10) NOT NULL,
  `scheduleId` varchar(10) NOT NULL,
  PRIMARY KEY (`bookingId`),
  KEY `studentId` (`studentId`),
  KEY `scheduleId` (`scheduleId`),
  CONSTRAINT `classbooking_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `classbooking_ibfk_2` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classbooking`
--

LOCK TABLES `classbooking` WRITE;
/*!40000 ALTER TABLE `classbooking` DISABLE KEYS */;
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
  `classStatus` enum('Scheduled','Completed','Cancelled') NOT NULL DEFAULT 'Scheduled',
  `classJuzuk` int(11) DEFAULT NULL,
  `classSurah` int(11) DEFAULT NULL,
  `classAyah` int(11) DEFAULT NULL,
  PRIMARY KEY (`scheduleId`),
  KEY `teacherId` (`teacherId`),
  KEY `studentId` (`studentId`),
  CONSTRAINT `classschedule_ibfk_1` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `classschedule_ibfk_2` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classschedule`
--

LOCK TABLES `classschedule` WRITE;
/*!40000 ALTER TABLE `classschedule` DISABLE KEYS */;
INSERT INTO `classschedule` VALUES ('C001','T001',NULL,'Quran Recitation & Tajweed','2026-01-22','09:00:00','09:15:00',15,'Scheduled',NULL,NULL,NULL),('C002','T001',NULL,'Quran Recitation & Tajweed','2026-01-22','09:15:00','09:30:00',15,'Scheduled',NULL,NULL,NULL),('C003','T001',NULL,'Quran Recitation & Tajweed','2026-01-22','09:30:00','09:45:00',15,'Scheduled',NULL,NULL,NULL),('C004','T001',NULL,'Quran Recitation & Tajweed','2026-01-22','09:45:00','10:00:00',15,'Scheduled',NULL,NULL,NULL),('C005','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','12:00:00','12:15:00',15,'Scheduled',NULL,NULL,NULL),('C006','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','12:15:00','12:30:00',15,'Scheduled',NULL,NULL,NULL),('C007','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','12:30:00','12:45:00',15,'Scheduled',NULL,NULL,NULL),('C008','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','12:45:00','13:00:00',15,'Scheduled',NULL,NULL,NULL),('C009','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','13:00:00','13:15:00',15,'Scheduled',NULL,NULL,NULL),('C010','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','13:15:00','13:30:00',15,'Scheduled',NULL,NULL,NULL),('C011','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','13:30:00','13:45:00',15,'Scheduled',NULL,NULL,NULL),('C012','T001',NULL,'Quran Recitation & Tajweed','2026-01-23','13:45:00','14:00:00',15,'Scheduled',NULL,NULL,NULL),('C013','T001',NULL,'Quran Recitation & Tajweed','2026-01-24','17:00:00','17:15:00',15,'Scheduled',NULL,NULL,NULL),('C014','T001',NULL,'Quran Recitation & Tajweed','2026-01-24','17:15:00','17:30:00',15,'Scheduled',NULL,NULL,NULL),('C015','T001',NULL,'Quran Recitation & Tajweed','2026-01-24','17:30:00','17:45:00',15,'Scheduled',NULL,NULL,NULL),('C016','T001',NULL,'Quran Recitation & Tajweed','2026-01-24','17:45:00','18:00:00',15,'Scheduled',NULL,NULL,NULL),('C017','T001',NULL,'Quran Recitation & Tajweed','2026-01-25','08:00:00','08:15:00',15,'Scheduled',NULL,NULL,NULL),('C018','T001',NULL,'Quran Recitation & Tajweed','2026-01-25','08:15:00','08:30:00',15,'Scheduled',NULL,NULL,NULL),('C019','T001',NULL,'Quran Recitation & Tajweed','2026-01-25','08:30:00','08:45:00',15,'Scheduled',NULL,NULL,NULL),('C020','T001',NULL,'Quran Recitation & Tajweed','2026-01-25','08:45:00','09:00:00',15,'Scheduled',NULL,NULL,NULL),('C021','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','10:00:00','10:15:00',15,'Scheduled',NULL,NULL,NULL),('C022','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','10:15:00','10:30:00',15,'Scheduled',NULL,NULL,NULL),('C023','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','10:30:00','10:45:00',15,'Scheduled',NULL,NULL,NULL),('C024','T001',NULL,'Quran Recitation & Tajweed','2026-01-26','10:45:00','11:00:00',15,'Scheduled',NULL,NULL,NULL);
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
  KEY `managerId` (`managerId`),
  CONSTRAINT `evaluationanalytics_ibfk_1` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluationanalytics`
--

LOCK TABLES `evaluationanalytics` WRITE;
/*!40000 ALTER TABLE `evaluationanalytics` DISABLE KEYS */;
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
  UNIQUE KEY `managerEmail` (`managerEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manager`
--

LOCK TABLES `manager` WRITE;
/*!40000 ALTER TABLE `manager` DISABLE KEYS */;
INSERT INTO `manager` VALUES ('M001','Iffah Afiqah','iffah@gmail.com','iffah123','01126427991','education','What city were you born in?','Mersing');
/*!40000 ALTER TABLE `manager` ENABLE KEYS */;
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
  `managerId` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`packageId`),
  KEY `managerId` (`managerId`),
  CONSTRAINT `packages_ibfk_1` FOREIGN KEY (`managerId`) REFERENCES `manager` (`managerId`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packages`
--

LOCK TABLES `packages` WRITE;
/*!40000 ALTER TABLE `packages` DISABLE KEYS */;
INSERT INTO `packages` VALUES ('P001','TalaqqiSpark','Kids',8,'M001'),('P002','TalaqqiSpark+','Kids',16,'M001'),('P003','TalaqqiPro','Adults',8,'M001'),('P004','Adults','Adults',16,'M001');
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
  KEY `sessionId` (`sessionId`),
  CONSTRAINT `qurandisplay_ibfk_1` FOREIGN KEY (`sessionId`) REFERENCES `talaqisession` (`sessionId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
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
  `studentStatus` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `studentSecQues` varchar(255) DEFAULT NULL,
  `studentSecPassword` varchar(255) DEFAULT NULL,
  `packageId` varchar(10) NOT NULL,
  PRIMARY KEY (`studentId`),
  UNIQUE KEY `studentEmail` (`studentEmail`),
  KEY `fk_student_package` (`packageId`),
  CONSTRAINT `fk_student_package` FOREIGN KEY (`packageId`) REFERENCES `packages` (`packageId`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES ('S001','Fattah Amin','fattah@gmail.com','fattah123','0123456789','2011-03-14','2026-01-01','Active','What was your childhood nickname?','fattah','P001'),('S002','Hannah Delisha','hannah@gmail.com','hannah123','0134567890','2010-07-22','2026-01-02','Active','What is your favorite Surah from the Quran?','Surah Al-Baqarah','P002'),('S003','Amir Ahnaf','amir@gmail.com','amir123','0145678901','2012-05-09','2026-01-03','Active','What city were you born in?','Kuala Terengganu','P001'),('S004','Erysha Emyra','erysha@gmail.com','erysha123','0156789012','2011-09-18','2026-01-04','Active','What was the name of your first school?','Sekolah Kebangsaan Seri Murni','P002'),('S005','Nadhir Nasar','nadhir@gmail.com','nadhir123','0167890123','2010-02-25','2026-01-05','Active','What is your mother\'s maiden name?','Aminah','P001'),('S006','Nabila Huda','nabila@gmail.com','nabila123','0178901234','2003-07-30','2026-01-06','Active','What was the name of your first pet?','Tommy','P003'),('S007','Remy Ishak','remy@gmail.com','remy123','0189012345','2002-12-11','2026-01-07','Active','What city were you born in?','Kuantan','P004'),('S008','Mira Filzah','mira@gmail.com','mira123','0190123456','2001-06-03','2026-01-08','Active','What is your favorite Surah from the Quran?','Surah Yasin','P003'),('S009','Shafiq Kyle','syafiq@gmail.com','syafiq123','0112233445','2004-10-21','2026-01-09','Active','What was your childhood nickname?','Alya','P004'),('S010','Mimi Lana','mini@gmail.com','mimi123','0109988776','2000-01-19','2026-01-10','Active','What was the name of your first school?','Sekolah Menengah Islam Darul Quran','P003');
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `studentcancellation`
--

DROP TABLE IF EXISTS `studentcancellation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `studentcancellation` (
  `bookingId` varchar(10) NOT NULL,
  `cancellationReason` text DEFAULT NULL,
  `cancelledAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `cancelledBy` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`bookingId`),
  CONSTRAINT `studentcancellation_ibfk_1` FOREIGN KEY (`bookingId`) REFERENCES `classbooking` (`bookingId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `studentcancellation`
--

LOCK TABLES `studentcancellation` WRITE;
/*!40000 ALTER TABLE `studentcancellation` DISABLE KEYS */;
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
  `tajweedScore` int(11) DEFAULT NULL,
  `fluencyScore` int(11) DEFAULT NULL,
  `accuracyScore` int(11) DEFAULT NULL,
  `strength` varchar(255) DEFAULT NULL,
  `weakness` varchar(255) DEFAULT NULL,
  `studentImprovements` text DEFAULT NULL,
  `nextTarget` varchar(255) DEFAULT NULL,
  `studentId` varchar(10) NOT NULL,
  `teacherId` varchar(10) NOT NULL,
  `scheduleId` varchar(10) NOT NULL,
  PRIMARY KEY (`studentEvaluationId`),
  KEY `studentId` (`studentId`),
  KEY `teacherId` (`teacherId`),
  KEY `scheduleId` (`scheduleId`),
  CONSTRAINT `studentevaluation_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`),
  CONSTRAINT `studentevaluation_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`),
  CONSTRAINT `studentevaluation_ibfk_3` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `studentevaluation`
--

LOCK TABLES `studentevaluation` WRITE;
/*!40000 ALTER TABLE `studentevaluation` DISABLE KEYS */;
/*!40000 ALTER TABLE `studentevaluation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `talaqisession`
--

DROP TABLE IF EXISTS `talaqisession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `talaqisession` (
  `sessionId` varchar(10) NOT NULL,
  `sessionType` varchar(50) DEFAULT NULL,
  `sessionDate` date NOT NULL,
  `scheduleId` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`sessionId`),
  KEY `scheduleId` (`scheduleId`),
  CONSTRAINT `talaqisession_ibfk_1` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `talaqisession`
--

LOCK TABLES `talaqisession` WRITE;
/*!40000 ALTER TABLE `talaqisession` DISABLE KEYS */;
/*!40000 ALTER TABLE `talaqisession` ENABLE KEYS */;
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
  `teacherStatus` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `teacherSecQues` varchar(255) DEFAULT NULL,
  `teacherSecPassword` varchar(255) DEFAULT NULL,
  `qualifications` varchar(255) DEFAULT NULL,
  `specialtyArea` varchar(100) DEFAULT NULL,
  `averageRating` decimal(3,2) DEFAULT NULL,
  `approvalStatusCertRef` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`teacherId`),
  UNIQUE KEY `teacherEmail` (`teacherEmail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher`
--

LOCK TABLES `teacher` WRITE;
/*!40000 ALTER TABLE `teacher` DISABLE KEYS */;
INSERT INTO `teacher` VALUES ('T001','Ustaz Azhar Idrus','azhar@gmail.com','azhar123','0123344556','1985-04-12','2026-01-01','Active','What was your childhood nickname?','Firdaus','Bachelor in Quran & Sunnah','Tajweed',4.70,'APPROVED'),('T002','Ustazah Asma Harun','asma@gmail.com','asma123','0134455667','1990-08-25','2026-01-01','Active','What is your favorite Surah from the Quran?','Surah Al-Fatihah','Diploma in Islamic Studies','Tajweed & Tarteel',4.80,'APPROVED'),('T003','Ustaz Ebit Lew','ebit@gmail.com','ebit123','0145566778','1988-02-19','2026-01-02','Active','What city were you born in?','Shah Alam','Bachelor in Quranic Studies','Hifz',4.60,'APPROVED'),('T004','Ustazah Hafizah Musa','hafizah@gmail.com','hafizah123','0156677889','1992-11-05','2026-01-02','Active','What was the name of your first school?','Sekolah Rendah Islam An-Nur','Diploma in Tajweed','Children Quran Learning',4.90,'APPROVED'),('T005','Ustaz Shamsul Debat','shamsul@gmail.com','shamsol123','0167788990','1983-06-17','2026-01-03','Active','What is your mother\'s maiden name?','Fatimah','Master in Quranic Education','Adult Quran Learning',4.50,'APPROVED');
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
  KEY `studentId` (`studentId`),
  KEY `teacherId` (`teacherId`),
  KEY `scheduleId` (`scheduleId`),
  CONSTRAINT `teacherevaluation_ibfk_1` FOREIGN KEY (`studentId`) REFERENCES `student` (`studentId`),
  CONSTRAINT `teacherevaluation_ibfk_2` FOREIGN KEY (`teacherId`) REFERENCES `teacher` (`teacherId`),
  CONSTRAINT `teacherevaluation_ibfk_3` FOREIGN KEY (`scheduleId`) REFERENCES `classschedule` (`scheduleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacherevaluation`
--

LOCK TABLES `teacherevaluation` WRITE;
/*!40000 ALTER TABLE `teacherevaluation` DISABLE KEYS */;
/*!40000 ALTER TABLE `teacherevaluation` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-17 15:30:48
