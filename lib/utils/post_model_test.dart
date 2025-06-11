
import '../features/home/data/models/post_model.dart';

final  List<Post> posts=[
  Post(title: 'title1', description: 'description1', location: const Location(coordinates: [12,12]), status: 'found', userId: '67fa7475705be9c78ea1cfc0', createdAt: DateTime.now(),
      updatedAt: DateTime.now() ,images: const ['https://res.cloudinary.com/dr5cpch1n/image/upload/v1746226973/posts/ysieinvzvehvwt1ux1we.png'])
];

/*
*
_id
680041a4272c76b403f0b626
title
"withe Wallet"
description
"black wallet found near the park"

images
Array (1)
0
"https://res.cloudinary.com/dr5cpch1n/image/upload/v1746226973/posts/ys…"

location
Object

coordinates
Object
type
"Point"

coordinates
Array (2)
0
40.7128
1
-74.006
placeName
"New York"
status
"found"
category
""

predictedItems
Array (empty)
user_id
67fa7475705be9c78ea1cfc0
contactInfo
""
createdAt
2025-04-16T23:47:48.954+00:00
updatedAt
2025-05-03T00:02:52.003+00:00
__v
0*/