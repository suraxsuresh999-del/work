import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/tamil_nadu_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedDistrict = 'All Districts';

  @override
  Widget build(BuildContext context) {
    final districts = ['All Districts', ...TamilNaduData.districts];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Marketplace'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search jobs, freelancers, skills...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDistrict,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: districts.map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDistrict = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildJobCard(
                  context,
                  title: 'UI/UX Redesign for Retail App',
                  location: 'Madurai, Tamil Nadu',
                  budget: '₹12,000',
                  skills: ['Figma', 'Mobile Design', 'Tamil'],
                ),
                _buildJobCard(
                  context,
                  title: 'Backend API in Supabase / Node.js',
                  location: 'Coimbatore, Tamil Nadu',
                  budget: '₹25,000',
                  skills: ['PostgreSQL', 'Supabase', 'REST API'],
                ),
                _buildJobCard(
                  context,
                  title: 'Digital Marketing Specialist for E-commerce',
                  location: 'Chennai, Tamil Nadu',
                  budget: '₹15,000/mo',
                  skills: ['SEO', 'Social Media', 'Content Writing'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required String title,
    required String location,
    required String budget,
    required List<String> skills,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  budget,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: skills.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 10)))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
