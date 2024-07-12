import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editing_app/UI/components/common.dart';

import '../../Model/filepath.dart';

class CoomonFileList extends StatelessWidget {
  const CoomonFileList(
      {super.key,
      required this.data,
      required this.onTap,
      required this.isScroll});
  final Future<List<FilePath>> data;
  final Function(FilePath) onTap;
  final bool isScroll;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FilePath>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No files found.'));
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of items per row
              // crossAxisSpacing: 8,
              // mainAxisSpacing: 8,
              childAspectRatio: 0.68, // Adjusted aspect ratio to fit text
            ),
            itemCount: snapshot.data?.length ?? 0,
            shrinkWrap: true,
            physics: isScroll ? null : NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              FilePath file = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () {
                              onTap(file);
                            },
                            child: Image.file(
                              File(file.thumbnail),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        // file.path.split('/').last,
                        file.title,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                        overflow:
                            TextOverflow.ellipsis, // Handle long file names
                      ),
                    ),
                    Text(formatDateString(file.date))
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
