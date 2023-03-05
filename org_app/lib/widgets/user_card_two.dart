import 'package:flutter/material.dart';

class CustomListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final VoidCallback onT;

  const CustomListItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.onT,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onT,
      child: Container(
        padding: const EdgeInsets.all(10),
     decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 75, 73, 73),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 10.0,
                                offset: Offset(0.0, 4.0),
                              ),
                            ],
                          ),
        margin: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(imageUrl),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              subtitle2,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
