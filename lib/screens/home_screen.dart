import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/place_item.dart';
import 'map_screen.dart';
import 'place_detail_screen.dart';
import '../ai/widgets/floating_ai_button.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _safeNetworkImage(String imageUrl, {BoxFit fit = BoxFit.cover}) {
    if (imageUrl.startsWith("assets/")) {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image_outlined)),
          );
        },
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        );
      },
    );
  }

  void _onNavTap(int idx) {
    switch (idx) {
      case 0:
        setState(() => _selectedIndex = 0);
        break;

      case 1:
        Navigator.pushNamed(context, '/tickets');
        break;

      case 2:
        Navigator.pushNamed(context, '/emergency');
        break;

      case 3:
        Navigator.pushNamed(context, '/help');
        break;
    }
  }

  void _navigateToCategory(String label) {
    switch (label) {
      case 'Hotel':
        Navigator.pushNamed(context, '/hotels');
        break;
      case 'Destination':
        Navigator.pushNamed(context, '/destinations');
        break;
      case 'Food':
        Navigator.pushNamed(context, '/food');
        break;
      case 'Translate':
        Navigator.pushNamed(context, '/translate');
        break;
      case 'Tickets':
        Navigator.pushNamed(context, '/tickets');
        break;
      default:
        break;
    }
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/destinations'),
      child: Container(
        height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 24, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Search destinations, hotels, restaurants...",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _navigateToCategory(label),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.withValues(alpha: 0.1),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Transform.scale(
        scale: 0.82,
        child: FloatingAIButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // 🔥 MAIN CHANGE HERE
      body: _selectedIndex == 1
          ? const MapScreen() // 👉 Discover tab = Map
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kathmandu, Nepal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/profile'),
                          icon: const Icon(Icons.person_outline),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Where do you want to go?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  _buildSearchBar(),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/map');
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: const Icon(
                                  Icons.navigation,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Navigate",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _buildCategory(Icons.hotel, 'Hotel'),
                        _buildCategory(Icons.fastfood, 'Food'),
                        _buildCategory(Icons.translate, 'Translate'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Popular Destination',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: DummyData.destinations
                                    .map(_destinationCard)
                                    .toList(),
                              ),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Recommended Near You',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: DummyData.landscapes
                                  .map(_landscapeCard)
                                  .toList(),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num_outlined),
            activeIcon: Icon(Icons.confirmation_num),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_outlined),
            activeIcon: Icon(Icons.emergency),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Help',
          ),
        ],
      ),
    );
  }

  Widget _emergencyButton(String title, IconData icon, String number) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Emergency"),
            content: Text("Call $title ($number)?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final Uri phone = Uri(scheme: 'tel', path: number);

                  if (await canLaunchUrl(phone)) {
                    await launchUrl(phone);
                  }
                },
                child: const Text("Call"),
              ),
            ],
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.red.shade100,
            child: Icon(icon, color: Colors.red),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _destinationCard(PlaceItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaceDetailScreen(item: item)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _safeNetworkImage(item.imageUrl),
              Container(color: Colors.black.withValues(alpha: 0.25)),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _landscapeCard(PlaceItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaceDetailScreen(item: item)),
        );
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _safeNetworkImage(item.imageUrl),
        ),
      ),
    );
  }
}
