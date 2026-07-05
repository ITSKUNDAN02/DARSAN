import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/place_item.dart';
import 'place_detail_screen.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  void _openDetail(BuildContext context, PlaceItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Restaurants')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: DummyData.restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = DummyData.restaurants[index];
          return GestureDetector(
            onTap: () => _openDetail(context, restaurant),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                    child: Image.network(
                      restaurant.imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            restaurant.subtitle,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Expanded(child: Text(restaurant.location)),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(restaurant.rating.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
