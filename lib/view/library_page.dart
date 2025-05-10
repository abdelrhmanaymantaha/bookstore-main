import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/library_book.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<LibraryBook> books = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://book-app-backend-production-304e.up.railway.app/library'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.map((json) => LibraryBook.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load books';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(book.author),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: book.available
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            book.available ? 'Available' : 'Not Available',
                            style: TextStyle(
                              color: book.available ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
