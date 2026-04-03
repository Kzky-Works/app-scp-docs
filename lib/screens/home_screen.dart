import 'package:flutter/material.dart';

import '../data/category_catalog.dart';
import '../theme/scp_reader_theme.dart';
import '../widgets/stark_card.dart';
import 'category_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCP READER // JP'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: kAllCategories.length,
        separatorBuilder: (context, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final cat = kAllCategories[index];
          return StarkCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CategoryDetailScreen(category: cat),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.titleJa,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.titleEn,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ScpReaderTheme.accent,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: ScpReaderTheme.accent.withValues(alpha: 0.8),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
