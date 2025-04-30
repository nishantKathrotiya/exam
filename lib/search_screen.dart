// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;
  bool _imageNotFound = false;

  // Base URL consistent with your FastAPI dev tunnel
  static const String baseUrl = "https://9qr74hdb-8000.inc1.devtunnels.ms";

  Future<void> _searchImageById() async {
    String searchId = _searchController.text.trim();
    if (searchId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an Image ID")),
      );
      return;
    }

    final String apiUrl =
        "$baseUrl/generated_images/$searchId.png"; // Adjusted to match FastAPI endpoint

    setState(() {
      _isLoading = true;
      _imageUrl = null;
      _imageNotFound = false;
    });

    try {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print("Fetching image from: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));

      // ignore: duplicate_ignore
      // ignore: avoid_print
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = apiUrl; // Use the direct image URL
          _imageNotFound = false;
        });

        // Scroll to top to show the image
        Future.delayed(const Duration(milliseconds: 200), () {
          Scrollable.ensureVisible(
            // ignore: use_build_context_synchronously
            context, // Pass the BuildContext directly
            duration: const Duration(milliseconds: 300),
          );
        });
      } else {
        setState(() {
          _imageNotFound = true;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image not found")),
        );
      }
    } catch (e) {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print("Exception: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching image: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _imageUrl = null;
      _imageNotFound = false;
    });
  }

  Future<void> _reloadScreen() async {
    _clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Image by ID")),
      body: RefreshIndicator(
        onRefresh: _reloadScreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter Image ID",
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _searchImageById,
                    child: const Text("Search"),
                  ),
                  ElevatedButton(
                    onPressed: _clearSearch,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Clear"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_imageNotFound)
                const Center(
                  child: Text(
                    "❌ No image found for this ID",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              else if (_imageUrl != null)
                Column(
                  children: [
                    Image.network(
                      _imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print("Image load error: $error");
                        return const Text("Failed to load image");
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "✅ Image loaded successfully!",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                )
              else
                const Center(child: Text("Enter an Image ID to search")),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
