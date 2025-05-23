import 'package:flutter/material.dart';

class LatestNews extends StatelessWidget {
  const LatestNews({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      {
        'title': 'Ferrari presenta gli aggiornamenti per Monaco',
        'summary': 'La Scuderia Ferrari porta un nuovo pacchetto aerodinamico...',
        'time': '2 ore fa',
      },
      {
        'title': 'Verstappen: "Monaco è sempre speciale"',
        'summary': 'Il campione del mondo commenta la prossima gara...',
        'time': '4 ore fa',
      },
      {
        'title': 'McLaren fiduciosa per il weekend',
        'summary': 'Norris e Piastri puntano al podio a Monte Carlo...',
        'time': '6 ore fa',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ultime Notizie',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Vedi tutto'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...news.map((article) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                article['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(article['summary']!),
                  const SizedBox(height: 8),
                  Text(
                    article['time']!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {},
            ),
          );
        }),
      ],
    );
  }
}
