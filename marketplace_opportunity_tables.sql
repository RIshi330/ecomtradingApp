DROP TABLE IF EXISTS `marketplace_opportunity`;
CREATE TABLE `marketplace_opportunity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `vendor_id` bigint NOT NULL,
  `site_id` bigint NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `cat_id` int DEFAULT NULL,
  `location` varchar(150) DEFAULT NULL,
  `opportunity_for` varchar(150) DEFAULT NULL,
  `organization` varchar(255) DEFAULT NULL,
  `application_deadline` date DEFAULT NULL,
  `program_duration` varchar(100) DEFAULT NULL,
  `short_description` text,
  `full_description` text,
  `benefits` text,
  `skills_required` text,
  `tags` text,
  `label` varchar(100) DEFAULT NULL,
  `opportunity_status` int DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `industry` varchar(150) DEFAULT NULL,
  `eligibility` text,
  `positions` int DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `moq` varchar(100) DEFAULT NULL,
  `price_model` varchar(100) DEFAULT NULL,
  `payment_terms` varchar(100) DEFAULT NULL,
  `funding_goal` varchar(100) DEFAULT NULL,
  `minimum_investment` varchar(100) DEFAULT NULL,
  `equity_offered` varchar(100) DEFAULT NULL,
  `campaign_duration` varchar(100) DEFAULT NULL,
  `startup_valuation` varchar(100) DEFAULT NULL,
  `current_revenue` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `marketplace_opportunity` (`id`, `vendor_id`, `site_id`, `title`, `type`, `cat_id`, `location`, `opportunity_for`, `organization`, `application_deadline`, `program_duration`, `short_description`, `full_description`, `benefits`, `skills_required`, `tags`, `label`, `opportunity_status`, `created_at`, `updated_at`, `industry`, `eligibility`, `positions`, `product_name`, `moq`, `price_model`, `payment_terms`, `funding_goal`, `minimum_investment`, `equity_offered`, `campaign_duration`, `startup_valuation`, `current_revenue`) VALUES ('1', '2', '3', 'Campus Brand Ambassador', 'Business opportunity', NULL, 'Remote', 'Students / Entrepreneurs / Creators', 'Acme Corp', NULL, NULL, 'Join us as a campus brand ambassador to promote our products.', 'This is a detailed description of the campus ambassador program. You will represent our brand on campus, organize events, and engage with students.', 'Stipend, Certificate, Networking Opportunities', 'Marketing, Social Media, Communication', 'marketing, campus, ambassador', '0', '1', '2026-06-08 16:29:05', '2026-06-08 16:29:05', '', '', '10', '', '', '', '', '', '', '', '', '', '');
INSERT INTO `marketplace_opportunity` (`id`, `vendor_id`, `site_id`, `title`, `type`, `cat_id`, `location`, `opportunity_for`, `organization`, `application_deadline`, `program_duration`, `short_description`, `full_description`, `benefits`, `skills_required`, `tags`, `label`, `opportunity_status`, `created_at`, `updated_at`, `industry`, `eligibility`, `positions`, `product_name`, `moq`, `price_model`, `payment_terms`, `funding_goal`, `minimum_investment`, `equity_offered`, `campaign_duration`, `startup_valuation`, `current_revenue`) VALUES ('2', '2', '3', 'tgh', '', NULL, '', NULL, NULL, NULL, NULL, NULL, '<p><br/></p>', NULL, '', '', NULL, '1', '2026-06-22 13:52:52', '2026-06-22 13:52:52', '', '<p><br/></p>', NULL, NULL, NULL, NULL, '<p><br/></p>', NULL, NULL, NULL, NULL, NULL, NULL);

/* -------------------------------------------------------- */

DROP TABLE IF EXISTS `marketplace_opportunity_application`;
CREATE TABLE `marketplace_opportunity_application` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `opportunity_id` bigint DEFAULT NULL,
  `vendor_id` bigint NOT NULL,
  `site_id` bigint NOT NULL,
  `application_method` varchar(100) DEFAULT NULL,
  `application_url` text,
  `screening_process` varchar(100) DEFAULT NULL,
  `approval_workflow` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `require_resume` tinyint DEFAULT '0',
  `require_portfolio` tinyint DEFAULT '0',
  `require_company_profile` tinyint DEFAULT '0',
  `require_pitch_deck` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `marketplace_opportunity_application` (`id`, `opportunity_id`, `vendor_id`, `site_id`, `application_method`, `application_url`, `screening_process`, `approval_workflow`, `created_at`, `require_resume`, `require_portfolio`, `require_company_profile`, `require_pitch_deck`) VALUES ('1', '1', '2', '3', 'Google Form', 'https://forms.gle/example', 'Manual Review', 'Admin Approval', '2026-06-08 16:29:05', '0', '0', '0', '0');

/* -------------------------------------------------------- */

DROP TABLE IF EXISTS `marketplace_opportunity_compensation`;
CREATE TABLE `marketplace_opportunity_compensation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `opportunity_id` bigint DEFAULT NULL,
  `vendor_id` bigint NOT NULL,
  `site_id` bigint NOT NULL,
  `payout_type` varchar(100) DEFAULT NULL,
  `payout_amount` varchar(100) DEFAULT NULL,
  `payment_frequency` varchar(100) DEFAULT NULL,
  `positions` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `marketplace_opportunity_compensation` (`id`, `opportunity_id`, `vendor_id`, `site_id`, `payout_type`, `payout_amount`, `payment_frequency`, `positions`, `created_at`) VALUES ('1', '1', '2', '3', 'Fixed Stipend', '₹5000', 'Monthly', '10', '2026-06-08 16:29:05');

/* -------------------------------------------------------- */

DROP TABLE IF EXISTS `marketplace_opportunity_media`;
CREATE TABLE `marketplace_opportunity_media` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `opportunity_id` bigint DEFAULT NULL,
  `vendor_id` bigint NOT NULL,
  `site_id` bigint NOT NULL,
  `cover_image` text,
  `video_url` text,
  `attachment` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `gallery` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `marketplace_opportunity_media` (`id`, `opportunity_id`, `vendor_id`, `site_id`, `cover_image`, `video_url`, `attachment`, `created_at`, `gallery`) VALUES ('1', '1', '2', '3', 'https://example.com/image.jpg', 'https://www.youtube.com/watch?v=example', 'https://example.com/file.pdf', '2026-06-08 16:29:05', '');

/* -------------------------------------------------------- */

DROP TABLE IF EXISTS `marketplace_opportunity_tags`;
CREATE TABLE `marketplace_opportunity_tags` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `opportunity_id` bigint DEFAULT NULL,
  `vendor_id` bigint NOT NULL,
  `site_id` bigint NOT NULL,
  `tag` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


/* -------------------------------------------------------- */

DROP TABLE IF EXISTS `marketplace_opportunity_visibility`;
CREATE TABLE `marketplace_opportunity_visibility` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `opportunity_id` bigint DEFAULT NULL,
  `vendor_id` bigint NOT NULL,
  `site_id` bigint NOT NULL,
  `featured` tinyint DEFAULT '0',
  `premium` tinyint DEFAULT '0',
  `sponsored` tinyint DEFAULT '0',
  `premium_price` varchar(50) DEFAULT NULL,
  `ad_budget` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `promotion_start` date DEFAULT NULL,
  `promotion_end` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `marketplace_opportunity_visibility` (`id`, `opportunity_id`, `vendor_id`, `site_id`, `featured`, `premium`, `sponsored`, `premium_price`, `ad_budget`, `created_at`, `promotion_start`, `promotion_end`) VALUES ('1', '1', '2', '3', '1', '0', '1', '₹99', '₹5000', '2026-06-08 16:29:05', NULL, NULL);

/* -------------------------------------------------------- */

