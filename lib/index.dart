import 'package:flutter/material.dart';

// Import Screens from their new locations
import 'loginscreen.dart';
import 'signupscreen.dart';
import 'otp_screen.dart';
import 'auth_screen_not_use.dart';
import 'admin/Community_Admin_Dashboard.dart';
import 'admin/admin_loginscreen.dart';
import 'admin/business_user_dashboard_screen.dart';
import 'admin/create_community_screen.dart';
import 'admin/profile_screen.dart' as admin;
import 'admin/admin_profile_screen.dart';
import 'admin/manage_items_screen.dart';
import 'admin/membership_builder_screen.dart';
import 'admin/membership_plans_screen.dart';
import 'admin/memberships_and_plans_screen.dart';
import 'admin/manage_vendors_screen.dart';
import 'admin/platform_settings_screen.dart';
import 'admin/commission_settings_screen.dart';
import 'admin/seller_dashboard_screen.dart';
import 'admin/seller_management_screen.dart';
import 'admin/taxonomy_manager_screen.dart';
import 'admin/seller_orders_screen.dart';
import 'admin/order_details_screen.dart';
import 'admin/wallet_admin_screen.dart';
import 'admin/marketplace_modules_screen.dart';
import 'admin/module_details_screen.dart';
import 'admin/module_manager_screen.dart';
import 'admin/module_integration_screen.dart';
import 'admin/opportunity_detail_screen.dart';
import 'admin/campaign_scheduler_screen.dart';
import 'screens/opportunity_action_hub_screen.dart';
import 'screens/manage_opportunities_screen.dart';
import 'screens/create_opportunity_screen.dart';
import 'screens/product_management_screen.dart';
import 'screens/low_stock_inventory_screen.dart';
import 'screens/trading_marketplace_screen.dart';
import 'screens/selected_items_screen.dart';
import 'screens/affiliate_orders_screen.dart';
import 'screens/manage_team_screen.dart';
import 'screens/manage_tasks_screen.dart';
import 'screens/explore_partners_screen.dart';
import 'screens/explore_talent_screen.dart';
import 'screens/rewards_recognition_screen.dart';
import 'screens/logistics_screen.dart';
import 'screens/packaging_screen.dart';
import 'screens/packaging_product_detail_screen.dart';
import 'screens/promotions_screen.dart';
import 'screens/local_delivery_screen.dart';
import 'screens/explore_charity_projects_screen.dart';
import 'screens/charity_marketplace_screen.dart';
import 'screens/charity_project_detail_screen.dart';
import 'screens/event_marketplace_screen.dart';
import 'screens/my_events_screen.dart';
import 'screens/event_opportunities_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/event_opp_detail_screen.dart';
import 'common/payment_screen.dart';
import 'screens/seller_profile_screen.dart';
import 'user/seller_bank_accounts_screen.dart';
import 'user/wallet_screen.dart';
import 'user/membership_plan.dart';
import 'common/community_inbox_screen.dart';
import 'common/notification_screen.dart';
import 'common/setting_screen.dart';
import 'common/splash_screen.dart';
import 'common/shell.dart';
import 'common/offers_screen.dart';
import 'common/terms_conditions_screen.dart';
import 'screens/marketplace_trainings_screen.dart';
import 'screens/enrolled_trainings_screen.dart';
import 'screens/training_details_screen.dart';
import 'screens/enroll_payment_screen.dart';

/// AppRoutes provides route names and route builders for the application.
class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Route Name Constants
  static const String splash = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String auth = '/auth';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProfile = '/admin/profile';
  static const String userProfile = '/user/profile';
  static const String sellerBankAccounts = '/user/bank-accounts';
  static const String wallet = '/user/wallet';
  static const String membership = '/user/membership';
  static const String chat = '/common/chat';
  static const String notification = '/common/notification';
  static const String setting = '/common/setting';
  static const String shell = '/shell';
  static const String businessDashboard = '/business/dashboard';
  static const String createCommunity = '/create_community';

  // New Admin Routes
  static const String walletAdmin = '/wallet';
  static const String sellerDashboard = '/seller';
  static const String communityAdmin = '/community_admin';
  static const String sellerManagement = '/seller_management';
  static const String taxonomyManager = '/taxonomy';
  static const String adminProfileScreen = '/admin_profile';
  static const String manageItems = '/manage_items';
  static const String platformSettings = '/platform_settings';
  static const String commissionSettings = '/commission_settings';
  static const String membershipPlans = '/membership_plans';
  static const String manageVendors = '/manage_vendors';
  static const String membershipsAndPlans = '/memberships_and_plans';
  static const String membershipBuilder = '/membership_builder';
  static const String marketplaceModules = '/marketplace_modules';
  static const String moduleDetails = '/module_details';
  static const String moduleManager = '/module_manager';
  static const String moduleIntegration = '/module_integration';
  static const String opportunityDetail = '/opportunity_detail';
  static const String opportunityActionHub = '/opportunity_action_hub';
  static const String manageOpportunities = '/manage_opportunities';
  static const String createOpportunity = '/create_opportunity';
  static const String productManagement = '/product_management';
  static const String manageInventory = '/manage_inventory';
  static const String tradingMarketplace = '/trading_marketplace';
  static const String selectedItems = '/selected_items';
  static const String affiliateOrders = '/affiliate_orders';
  static const String payment = '/payment';
  static const String sellerOrders = '/admin/seller_orders';
  static const String orderDetails = '/admin/order_details';
  static const String offers = '/common/offers';
  static const String terms = '/common/terms';
  static const String manageTeam = '/manage_team';
  static const String manageTasks = '/manage_tasks';
  static const String explorePartners = '/explore_partners';
  static const String exploreTalent = '/explore_talent';
  static const String rewardsRecognition = '/rewards_recognition';
  static const String logistics = '/logistics';
  static const String packaging = '/packaging';
  static const String packagingProductDetail = '/packaging_product_detail';
  static const String promotions = '/promotions';
  static const String localDelivery = '/local_delivery';
  static const String exploreCharityProjects = '/explore_charity_projects';
  static const String charityMarketplace = '/charity_marketplace';
  static const String charityProjectDetail = '/charity_project_detail';
  static const String eventMarketplace = '/event_marketplace';
  static const String myEvents = '/my_events';
  static const String eventOpportunities = '/event_opportunities';
  static const String eventDetail = '/event_detail';
  static const String eventOppDetail = '/event_opp_detail';
  static const String marketplaceTrainings = '/marketplace_trainings';
  static const String enrolledTrainings = '/enrolled_trainings';
  static const String trainingDetails = '/training_details';
  static const String enrollPayment = '/enroll_payment';
  static const String campaignScheduler = '/admin/campaign_scheduler';

  /// Named routes mapping for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const WelcomeSplashScreen(),
        login: (context) => const LoginScreen(),
        adminLogin: (context) => const AdminLoginScreen(),
        signup: (context) => const SignupScreen(),
        otp: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return OtpScreen(
            email: args['email'] as String,
            isRecruiter: args['isRecruiter'] as bool,
          );
        },
        auth: (context) => const AuthProduction(),
        adminDashboard: (context) => const CommunityAdminDashboard(),
        adminProfile: (context) => const admin.ProfileScreen(),
        userProfile: (context) => const SellerProfileScreen(),
        sellerBankAccounts: (context) => const SellerBankAccountsScreen(),
        wallet: (context) => const WalletScreen(),
        membership: (context) => const MembershipScreen(),
        chat: (context) => const CommunityInboxScreen(),
        notification: (context) => const NotificationsScreen(),
        setting: (context) => const SettingsScreen(),
        shell: (context) => const AppShell(),
        businessDashboard: (context) => const BusinessUserDashboard(),
        createCommunity: (context) => const CreateCommunityScreen(),

        // New Admin Route Builders
        walletAdmin: (context) => const WalletAdminScreen(),
        sellerDashboard: (context) => const SellerDashboardScreen(),
        communityAdmin: (context) => const CommunityAdminDashboard(),
        sellerManagement: (context) => const SellerManagementScreen(),
        taxonomyManager: (context) => const TaxonomyManagerScreen(),
        adminProfileScreen: (context) => const AdminProfileScreen(),
        manageItems: (context) => const ManageItemsScreen(),
        platformSettings: (context) => const PlatformSettingsScreen(),
        commissionSettings: (context) => const CommissionSettingsScreen(),
        membershipPlans: (context) => const MembershipPlansScreen(),
        manageVendors: (context) => const ManageVendorsScreen(),
        membershipsAndPlans: (context) => const MembershipsAndPlansScreen(),
        membershipBuilder: (context) => const MembershipBuilderScreen(),
        marketplaceModules: (context) => const MarketplaceModulesScreen(),
        moduleDetails: (context) => const ModuleDetailsScreen(),
        moduleManager: (context) => const ModuleManagerScreen(),
        moduleIntegration: (context) => const ModuleIntegrationScreen(),
        opportunityDetail: (context) => const OpportunityDetailScreen(),
        opportunityActionHub: (context) => const OpportunityActionHubScreen(),
        manageOpportunities: (context) => const ManageOpportunitiesScreen(),
        createOpportunity: (context) => const OpportunityFormScreen(),
        productManagement: (context) => const ProductManagementScreen(),
        manageInventory: (context) => const LowStockInventoryScreen(),
        tradingMarketplace: (context) => const TradingMarketplaceScreen(),
        selectedItems: (context) => const SelectedItemsScreen(),
        affiliateOrders: (context) => const AffiliateOrdersScreen(),
        payment: (context) => const PaymentScreen(),
        sellerOrders: (context) => const SellerOrderScreen(),
        orderDetails: (context) => const OrderDetailsScreen(),
        offers: (context) => const OffersScreen(),
        terms: (context) => const TermsConditionsScreen(),
        manageTeam: (context) => const ManageTeamScreen(),
        manageTasks: (context) => const ManageTasksScreen(),
        explorePartners: (context) => const ExplorePartnersScreen(),
        exploreTalent: (context) => const ExploreTalentScreen(),
        rewardsRecognition: (context) => const RewardsRecognitionScreen(),
        logistics: (context) => const LogisticsScreen(),
        packaging: (context) => const PackagingScreen(),
        packagingProductDetail: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return PackagingProductDetailPage(
            productId: args['productId'] as String,
            variantId: args['variantId'] as String?,
          );
        },
        promotions: (context) => const PromotionsScreen(),
        localDelivery: (context) => const LocalDeliveryScreen(),
        exploreCharityProjects: (context) =>
            const ExploreCharityProjectsScreen(),
        charityMarketplace: (context) => const CharityMarketplaceScreen(),
        charityProjectDetail: (context) {
          final project = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CharityProjectDetailScreen(project: project);
        },
        eventMarketplace: (context) => const EventMarketplaceScreen(),
        myEvents: (context) => const MyEventsScreen(),
        eventOpportunities: (context) => const EventOpportunitiesScreen(),
        eventDetail: (context) {
          final event = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EventDetailScreen(event: event);
        },
        eventOppDetail: (context) {
          final opportunity = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EventOppDetailScreen(opportunity: opportunity);
        },
        marketplaceTrainings: (context) => const MarketplaceTrainingsScreen(),
        enrolledTrainings: (context) => const EnrolledTrainingsScreen(),
        trainingDetails: (context) {
          final training = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TrainingDetailsScreen(training: training);
        },
        enrollPayment: (context) => const EnrollPaymentScreen(),
        campaignScheduler: (context) => const CampaignSchedulerScreen(),
      };
}
