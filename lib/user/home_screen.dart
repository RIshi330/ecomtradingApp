import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primary = Color(0xFF4F378A);
  static const Color lavender = Color(0xFF7C83FD);
  static const Color secondary = Color(0xFF625B71);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color bgColor = Color(0xFFFEF7FF);

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const MembershipDialog(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1633332755192-727a05c4013d',
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "comm-Unity",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.location_on),
              label: const Text("New York"),
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Welcome Seller",
              style: TextStyle(
                color: primary,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Here's what's happening with your store today.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  SalesCard(),
                  SizedBox(width: 16),
                  OrdersCard(),
                  SizedBox(width: 16),
                  CsatCard(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// RECENT OPPORTUNITIES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Opportunities",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  OpportunityCard(
                    tag: "B2B Request",
                    title: "Bulk Supply: Eco-friendly Packaging",
                    desc: "Inquiry for 5000+ custom branded units for a startup in Berlin.",
                    value: "\$12,000 Est.",
                    color: Color(0xFF4F378A),
                  ),
                  SizedBox(width: 16),
                  OpportunityCard(
                    tag: "Partnership",
                    title: "Affiliate Program Invite",
                    desc: "GreenLife Retailer wants to list your products in marketplace.",
                    value: "20% Comm.",
                    color: Color(0xFF625B71),
                  ),
                  SizedBox(width: 16),
                  OpportunityCard(
                    tag: "Lead",
                    title: "Wholesale Quote Required",
                    desc: "Corporate gifting company interested in luxury leather series.",
                    value: "\$4,500 Est.",
                    color: Color(0xFF7D5260),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            /// BLOG SECTION
            const Text(
              "Seller Success Stories & Tips",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F378A),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  BlogCard(
                    image: "https://images.unsplash.com/photo-1552664730-d307ca884978",
                    title: "5 Ways to Optimize Your B2B Catalog for Global Buyers",
                    subtitle: "4 min read • Strategic Planning",
                  ),
                  SizedBox(width: 16),
                  BlogCard(
                    image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40",
                    title: "Understanding New Compliance Laws for Shipments",
                    subtitle: "7 min read • Logistics",
                  ),
                  SizedBox(width: 16),
                  BlogCard(
                    image: "https://images.unsplash.com/photo-1520607162513-77705c0f0d4a",
                    title: "Case Study: How ZenGallery Scaled 300%",
                    subtitle: "5 min read • Success Story",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// PRODUCT MANAGEMENT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Management",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F378A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Streamline your inventory across all channels. Update listings, manage B2B catalogs and create combo packages.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1556740749-887f6717d7e4",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: const [
                      ProductGridItem(
                        icon: Icons.inventory_2,
                        title: "Manage Listings",
                        color: Color(0xFF4F378A),
                      ),
                      ProductGridItem(
                        icon: Icons.corporate_fare,
                        title: "B2B Catalog",
                        color: Color(0xFF7C83FD),
                      ),
                      ProductGridItem(
                        icon: Icons.storefront,
                        title: "B2C Store",
                        color: Color(0xFF625B71),
                      ),
                      ProductGridItem(
                        icon: Icons.widgets,
                        title: "Combo Packages",
                        color: Color(0xFF7D5260),
                      ),
                      ProductGridItem(
                        icon: Icons.branding_watermark,
                        title: "Branding",
                        color: Color(0xFF6750A4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// RECENT ORDERS
            const Text(
              "Recent Orders",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F378A),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: const [
                  OrderTile(
                    orderId: "#ORD-99210",
                    amount: "\$124.00",
                    items: "2 items",
                    status: "Out for Delivery",
                    icon: Icons.local_shipping,
                    statusColor: Colors.green,
                  ),
                  Divider(height: 1),
                  OrderTile(
                    orderId: "#ORD-99208",
                    amount: "\$452.10",
                    items: "5 items",
                    status: "Processing",
                    icon: Icons.sync_alt,
                    statusColor: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: const ExpandableFab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF4F378A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Explore",
          ),
        ],
      ),
    );
  }
}

// ─── CUSTOM WIDGETS ──────────────────────────────────────────────────────────

class SalesCard extends StatelessWidget {
  const SalesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F378A),
            Color(0xFF7C83FD),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SALES TODAY",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.payments,
                color: Colors.white,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\$4,280.50",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "+12% vs yesterday",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.85),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL ORDERS"),
              Icon(Icons.shopping_bag),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1,248",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Lifetime volume"),
            ],
          ),
        ],
      ),
    );
  }
}

class CsatCard extends StatelessWidget {
  const CsatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7D5260),
            Color(0xFF633B48),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CUSTOMER SATISFACTION",
                style: TextStyle(color: Colors.white),
              ),
              Icon(Icons.verified, color: Colors.white),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "4.9 / 5.0",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 18),
                  Icon(Icons.star, color: Colors.white, size: 18),
                  Icon(Icons.star, color: Colors.white, size: 18),
                  Icon(Icons.star, color: Colors.white, size: 18),
                  Icon(Icons.star, color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MembershipDialog extends StatelessWidget {
  const MembershipDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose Your Plan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F378A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Unlock premium features and exclusive content.",
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF4F378A),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "PRO",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "\$149.99 / Year",
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xFF4F378A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F378A),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {},
                    child: const Text("Upgrade to Pro"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OpportunityCard extends StatelessWidget {
  final String tag;
  final String title;
  final String desc;
  final String value;
  final Color color;

  const OpportunityCard({
    super.key,
    required this.tag,
    required this.title,
    required this.desc,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                "2h ago",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                ),
                child: const Text("Respond"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const BlogCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              image,
              height: 150,
              width: 260,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductGridItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const ProductGridItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(.05),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final String orderId;
  final String amount;
  final String items;
  final String status;
  final IconData icon;
  final Color statusColor;

  const OrderTile({
    super.key,
    required this.orderId,
    required this.amount,
    required this.items,
    required this.status,
    required this.icon,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "$items • $amount",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              heroTag: "product",
              backgroundColor: Colors.white,
              onPressed: () {},
              label: const Text(
                "List Product",
                style: TextStyle(
                  color: Color(0xFF4F378A),
                ),
              ),
              icon: const Icon(
                Icons.add,
                color: Color(0xFF4F378A),
              ),
            ),
          ),
        FloatingActionButton(
          backgroundColor: const Color(0xFF4F378A),
          onPressed: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: AnimatedRotation(
            turns: expanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
