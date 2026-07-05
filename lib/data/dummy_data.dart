import '../models/place_item.dart';

class DummyData {
  static const hotels = <PlaceItem>[
    PlaceItem(
      id: 'hotel1',
      title: 'Hyatt Regency Kathmandu',
      subtitle: 'Luxury hotel near Boudhanath',
      location: 'Boudha, Kathmandu',
      rating: 4.7,
      imageUrl:
           "assets/hotels/Hyatt.jpg",
      description:
          'A five-star property near Boudhanath Stupa with landscaped gardens, a large outdoor pool, and multiple dining venues. It is popular for travelers seeking comfort close to heritage areas.',
      contact: '+977 1 4491234',
    ),
    PlaceItem(
      id: 'hotel2',
      title: 'Hotel Yak & Yeti',
      subtitle: 'Colonial-style five-star hotel',
      location: 'Thamel, Kathmandu',
      rating: 4.6,
      imageUrl:
          "assets/hotels/yak yeti.jpg",
      description:
          'A heritage-style luxury hotel in central Kathmandu known for spacious rooms, conference facilities, and quick access to Durbar Marg and major city landmarks.',
      contact: '+977 1 4250000',
    ),
    PlaceItem(
      id: 'hotel3',
      title: 'Kantipur Temple House',
      subtitle: 'Boutique hotel with heritage charm',
      location: 'Durbar Square, Kathmandu',
      rating: 4.5,
      imageUrl:
          "assets/hotels/kantipur.jpg",
      description:
          'A boutique eco-conscious stay built with traditional Newari design elements. It offers a quiet atmosphere while staying close to old Kathmandu and cultural sites.',
      contact: '+977 1 4223000',
    ),
  ];

  static const destinations = <PlaceItem>[
    PlaceItem(
      id: 'dest1',
      title: 'Patan Durbar Square',
      subtitle: 'UNESCO palace square in Lalitpur',
      location: 'Patan, Lalitpur',
      rating: 4.8,
      imageUrl:
        "assets/destinations/patan.jpg",
      description: '''Overview

    Patan Durbar Square was once the royal palace of the Malla kings of Patan. It is famous for Newari architecture, intricate wood carvings, stone sculptures, and historic temples. The square is a UNESCO World Heritage Site and remains a major cultural and religious center.

    Key Features

    1. Royal Palace (Durbar Complex)
    The former residence of the Malla kings includes courtyards like Mul Chowk, Sundari Chowk, and Keshav Narayan Chowk.

    2. Krishna Mandir
    A standout stone temple in Shikhara style dedicated to Lord Krishna.

    3. Hiranya Varna Mahavihar (Golden Temple)
    A nearby Buddhist monastery known for its golden facade and peaceful courtyard.

    4. Taleju Bhawani Temple
    A multi-tiered pagoda-style temple dedicated to the royal goddess Taleju.

    5. Patan Museum
    Located within the palace complex, it houses traditional art, sculptures, and religious artifacts.

    Cultural Significance

    Patan Durbar Square reflects the peak of Newari craftsmanship and artistry. Festivals, rituals, and daily religious practices still take place here, making it a living heritage site.''',
      contact: '+977 1 5523456',
    ),
    PlaceItem(
      id: 'dest2',
      title: 'Basantapur Durbar Square',
      subtitle: 'Heart of old Kathmandu',
      location: 'Kathmandu',
      rating: 4.7,
      imageUrl:
        "assets/destinations/Bhaktapur.jpg",
      description: '''✨ Overview

This UNESCO World Heritage Site is a vibrant mix of palaces, courtyards, temples, and shrines. It reflects centuries of Nepalese art, architecture, and royal history, and remains a lively cultural hub filled with locals, tourists, and religious activity.

🏯 Key Features

1. Hanuman Dhoka Palace
The ancient royal palace named after Lord Hanuman, whose statue guards the entrance. It was the residence of kings until the 19th century.

2. Taleju Temple
A towering pagoda-style temple dedicated to the goddess Taleju, built in the 16th century.

3. Kumari Ghar (Living Goddess House)
Home of the Kumari, a young girl worshipped as a living goddess. Visitors sometimes catch a glimpse of her during special appearances.

4. Kasthamandap
A historic wooden pavilion (from which Kathmandu gets its name), traditionally believed to be built from a single tree.

5. Kal Bhairav Statue
A large, fierce stone image of Lord Bhairav, associated with justice and protection.

🎨 Cultural Importance

Basantapur Durbar Square is not just a historic site—it’s a living center of festivals, ceremonies, and daily worship. Major celebrations like Indra Jatra take place here, featuring chariot processions and the appearance of the Kumari.''',
      contact: '+977 1 4372581',
    ),
    PlaceItem(
      id: 'dest3',
      title: 'Pashupatinath Temple',
      subtitle: 'Sacred Shiva temple on Bagmati River',
      location: 'Kathmandu',
      rating: 4.9,
      imageUrl:
        "assets/destinations/lumbini.jpg",
      description: '''✨ Overview

This UNESCO World Heritage Site is a major pilgrimage destination for Hindus from Nepal and India. The temple complex includes hundreds of smaller shrines, ashrams, and statues, creating a deeply spiritual and historic environment.

🏯 Key Features

1. Main Temple (Shiva Shrine)
A pagoda-style temple with a golden roof and silver doors. Only Hindus are allowed inside the main sanctum, but visitors can view it from across the river.

2. Arya Ghat (Cremation Site)
Sacred cremation ghats along the Bagmati River where traditional Hindu funeral rites are performed. It is believed that cremation here helps achieve liberation (moksha).

3. Sadhus (Holy Men)
You’ll often see ash-covered Hindu ascetics meditating, praying, or blessing visitors.

4. Surrounding Temples & Monasteries
The area includes many smaller temples dedicated to various deities, making it a large and spiritually active complex.

🕉️ Religious Significance

Pashupatinath is one of the most important temples dedicated to Lord Shiva. During Maha Shivaratri, thousands of pilgrims gather here to worship, making it one of the biggest religious events in Nepal.''',
      contact: '+977 1 4372581',
    ),
  ];

  static const restaurants = <PlaceItem>[
    PlaceItem(
      id: 'food1',
      title: 'OR2K',
      subtitle: 'Popular vegetarian cafe',
      location: 'Thamel, Kathmandu',
      rating: 4.5,
      imageUrl:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Thamel%2C_Kathmandu.jpg',
      description:
          'A long-running Thamel favorite known for vegetarian and Middle Eastern-inspired plates, cozy seating, and a relaxed traveler-friendly ambiance.',
      contact: '+977 1 4250022',
    ),
    PlaceItem(
      id: 'food2',
      title: 'Bhojan Griha',
      subtitle: 'Traditional Nepali cuisine',
      location: 'Thaulihal, Kathmandu',
      rating: 4.6,
      imageUrl:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Nepali_food_daal_bhat_tarkari.jpg',
      description:
          'A heritage dining venue serving traditional Nepali set meals with cultural performances. It is well known for introducing visitors to classic Nepali flavors in a historic setting.',
      contact: '+977 1 4410208',
    ),
    PlaceItem(
      id: 'food3',
      title: 'Fire and Ice Pizzeria',
      subtitle: 'Casual pizza restaurant',
      location: 'Durbar Marg, Kathmandu',
      rating: 4.3,
      imageUrl:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Pizza_%281%29.jpg',
      description:
          'A classic Kathmandu pizzeria popular for wood-fired style pizzas, casual atmosphere, and central location near Durbar Marg.',
      contact: '+977 1 4000188',
    ),
  ];

  static const landscapes = <PlaceItem>[
    PlaceItem(
      id: 'land1',
      title: 'Phewa Lake',
      subtitle: 'Scenic lake in Pokhara',
      location: 'Pokhara',
      rating: 4.8,
      imageUrl: 'assets/landscapes/phewa.jpg',
      description:
          'Pokhara\'s signature lake with reflections of surrounding hills and Himalayan peaks on clear days. Boating at sunrise or sunset is a top local experience.',
    ),
    PlaceItem(
      id: 'land2',
      title: 'Nagarkot Sunrise',
      subtitle: 'Himalayan sunrise viewpoint',
      location: 'Nagarkot',
      rating: 4.9,
      imageUrl: 'assets/landscapes/phewa.jpg',
      description:
          'Nagarkot is known for panoramic Himalayan sunrise views and short ridge walks. On clear mornings, the mountain range stretches dramatically across the horizon.',
    ),
    PlaceItem(
      id: 'land3',
      title: 'Chitwan Jungle',
      subtitle: 'Wildlife and nature tours',
      location: 'Chitwan',
      rating: 4.6,
      imageUrl: 'assets/landscapes/phewa.jpg',
      description:
          'Chitwan National Park offers jeep safaris, canoe trips, birdwatching, and opportunities to spot rhinos and other wildlife in Nepal\'s lowland jungle ecosystem.',
    ),
    PlaceItem(
      id: 'land4',
      title: 'Pathivara Temple',
      subtitle: 'Religious Site',
      location: 'Taplejung, Nepal',
      rating: 4.7,
      imageUrl: 'assets/landscapes/phewa.jpg',
      description:
          'Pathivara Temple is a sacred Hindu pilgrimage site located in the hills of Taplejung, Nepal, known for its spiritual significance and stunning mountain views. Devotees visit to seek blessings and experience the serene atmosphere of this revered temple.',
    ),
  ];
}
