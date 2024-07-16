import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_editing_app/Model/filepath.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  final String _videotable = "videos";
  final String _videoIdColumnName = "id";
  final String _videofilepathColumnName = "content";
  final String _videovidIdColumnName = "vid_id";
  final String _videothumbnailpathColumnName = "thumbnail";
  final String _videoVersionColumnName = "version";
  final String _videoTitleColumnName = "title";
  final String _videoWidthColumnName = "width";
  final String _videoheightColumnName = "height";
  final String _videoDateColumnName = "date";

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getApplicationCacheDirectory();
    final databasePath = join(databaseDirPath.path, "master_db.db");

    print("Database path ==> $databasePath");

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        createVideoTable(db);
        createCaptionTable(db);
      },
    );
    return database;
  }

  void createVideoTable(Database db) async {
    db.execute('''
        CREATE TABLE $_videotable (
          $_videoIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
          $_videofilepathColumnName TEXT NOT NULL,
          $_videovidIdColumnName INTEGER,
          $_videothumbnailpathColumnName TEXT,
          $_videoVersionColumnName INTEGER NOT NULL,
          $_videoTitleColumnName TEXT,
          $_videoWidthColumnName INTEGER,
          $_videoheightColumnName INTEGER,
          $_videoDateColumnName TEXT
        )
        ''');
  }

  Future<int> _getHighestVidId() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MAX($_videovidIdColumnName) as maxVidId FROM $_videotable');
    return result.first['maxVidId'] != null
        ? result.first['maxVidId'] as int
        : 0;
  }

  Future<int> _getVidIdById(int? id) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT $_videovidIdColumnName FROM $_videotable WHERE $_videoIdColumnName = ?',
        [id]);

    if (result.isNotEmpty) {
      return result.first[_videovidIdColumnName] as int;
    } else {
      // Handle case where no result is found, return a default value or throw an exception
      throw Exception('Video with ID $id not found');
    }
  }

  Future<int> getHighestVersionByVidId(int vidId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MAX($_videoVersionColumnName) as maxVersion FROM $_videotable WHERE $_videovidIdColumnName = ?',
        [vidId]);
    return result.first['maxVersion'] != null
        ? result.first['maxVersion'] as int
        : 0;
  }

  Future<int> getLowestVersionByVidId(int vidId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MIN($_videoVersionColumnName) as minVersion FROM $_videotable WHERE $_videovidIdColumnName = ?',
        [vidId]);
    return result.first['minVersion'] != null
        ? result.first['minVersion'] as int
        : 0;
  }

  Future<int> getCurrentVersionByPAth(String path) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT $_videoVersionColumnName as currentVersion FROM $_videotable WHERE $_videofilepathColumnName = ?',
        [path]);

    return result.first['currentVersion'] != null
        ? result.first['currentVersion'] as int
        : 0;
  }

  // Future<int> _getLastVidIdByVideoId(int videoId) async {
  //   final db = await database;
  //   final result = await db.rawQuery(
  //       'SELECT $_videovidIdColumnName FROM $_videotable WHERE $_videoIdColumnName = ? ORDER BY $_videoIdColumnName DESC LIMIT 1',
  //       [videoId]);
  //   return result.isNotEmpty ? result.first[_videovidIdColumnName] as int : 0;
  // }

  // Future<int> _getLastVidId() async {
  //   final db = await database;
  //   final result = await db.rawQuery(
  //       'SELECT $_videovidIdColumnName FROM $_videotable ORDER BY $_videoIdColumnName DESC LIMIT 1');
  //   return result.isNotEmpty ? result.first[_videovidIdColumnName] as int : 0;
  // }

  // Future<int> _getLastVidId(int id) async {
  //   final db = await database;
  //   final result = await db.rawQuery(
  //       'SELECT $_videovidIdColumnName FROM $_videotable WHERE $_videoIdColumnName = ? ORDER BY $_videoIdColumnName DESC LIMIT 1',
  //       [id]);
  //   return result.isNotEmpty ? result.first[_videovidIdColumnName] as int : 0;
  // }

  Future<void> addfile(String file, String thumbnail, String filename,
      double width, double height) async {
    try {
      final db = await database;
      int vidId = await _getHighestVidId() + 1;
      DateTime dateTime = DateTime.now();

      int version = 1;
      await db.insert(_videotable, {
        _videofilepathColumnName: file,
        _videovidIdColumnName: vidId,
        _videothumbnailpathColumnName: thumbnail,
        _videoVersionColumnName: version,
        _videoTitleColumnName: filename,
        _videoWidthColumnName: width,
        _videoheightColumnName: height,
        _videoDateColumnName: dateTime.toString(),
      });

      print("File added successfully: $file");
    } catch (e) {
      print("Failed to add file: $e");
    }
  }

//   Future<void> editFile(int id, String newFilePath, String newThumbnail) async {
//   try {
//     final db = await database;
//     //final originalFile = await getFileById(id);

//     if (originalFile != null) {
//       int vidId = originalFile.vid_id;
//       int version = (await _getHighestVersionByVidId(vidId)) + 1;

//       await db.insert(_videotable, {
//         _videofilepathColumnName: newFilePath,
//         _videovidIdColumnName: vidId,
//         _videothumbnailpathColumnName: newThumbnail,
//         _videoVersionColumnName: version,
//         _videoTitleColumnName: originalFile.title
//       });

//       print("File edited successfully: $newFilePath");
//     } else {
//       print("Original file not found for ID: $id");
//     }
//   } catch (e) {
//     print("Failed to edit file: $e");
//   }
// }

  Future<void> editFile(
      int vidId, String newFilePath, String newThumbnail) async {
    try {
      final db = await database;
      int version = (await getHighestVersionByVidId(vidId)) + 1;
      DateTime dateTime = DateTime.now();

      // Check if the video entry with the given vidId exists
      final result = await db.query(
        _videotable,
        where: '$_videovidIdColumnName = ?',
        whereArgs: [vidId],
      );

      if (result.isNotEmpty) {
        // Insert a new entry with the incremented version
        await db.insert(_videotable, {
          _videofilepathColumnName: newFilePath,
          _videovidIdColumnName: vidId,
          _videothumbnailpathColumnName: newThumbnail,
          _videoVersionColumnName: version,
          _videoTitleColumnName: result.first[_videoTitleColumnName],
          _videoWidthColumnName: result.last[_videoWidthColumnName],
          _videoheightColumnName: result.last[_videoheightColumnName],
          _videoDateColumnName: dateTime.toString(),
        });

        print("File edited successfully: $newFilePath");
      } else {
        print("Original file not found for vid_id: $vidId");
      }
    } catch (e) {
      print("Failed to edit file: $e");
    }
  }

  Future<List<FilePath>> getfile() async {
    final db = await database;

    final data = await db.query(_videotable);
    print("Data ========> $data");

    List<FilePath> files = data
        .map((e) => FilePath(
              id: e["id"] as int,
              vid_id: e["vid_id"] as int,
              path: e["content"] as String,
              thumbnail: e["thumbnail"].toString(),
              version: e["version"] as int,
              title: e["title"] as String,
              width: e[_videoWidthColumnName] as int,
              height: e[_videoheightColumnName] as int,
              date: e["date"] as String,
            ))
        .toList();
    return files;
  }

  Future<List<FilePath>> getFilesWithHighestVersion() async {
    final db = await database;

    final data = await db.rawQuery('''
      SELECT * FROM $_videotable
      WHERE $_videoVersionColumnName = (
        SELECT MAX($_videoVersionColumnName)
        FROM $_videotable AS inner_table
        WHERE inner_table.$_videovidIdColumnName = $_videotable.$_videovidIdColumnName
      )
    ''');

    print("Data ========> $data");

    List<FilePath> files = data
        .map((e) => FilePath(
              id: e[_videoIdColumnName] as int,
              vid_id: e[_videovidIdColumnName] as int,
              path: e[_videofilepathColumnName] as String,
              thumbnail: e[_videothumbnailpathColumnName].toString(),
              version: e[_videoVersionColumnName] as int,
              title: e[_videoTitleColumnName] as String,
              width: e[_videoWidthColumnName] as int,
              height: e[_videoheightColumnName] as int,
              date: e[_videoDateColumnName] as String,
            ))
        .toList();

    return files;
  }

  // Future<void> addVideo(File videoFile, String title) async {
  //   final db = await database;

  //   // Inserting a new video
  //   final List<Map<String, dynamic>> maxVidIdResult = await db.rawQuery(
  //       'SELECT MAX($_videovidIdColumnName) as maxVidId FROM $_videotable');
  //   final vidId = maxVidIdResult.first['maxVidId'] + 1;

  //   final version = 1;

  //   final filePath = videoFile.path;
  //   final thumbnailPath = ''; // Implement logic to generate or store thumbnail

  //   await db.insert(
  //     _videotable,
  //     {
  //       _videofilepathColumnName: filePath,
  //       _videovidIdColumnName: vidId,
  //       _videothumbnailpathColumnName: thumbnailPath,
  //       _videoVersionColumnName: version,
  //       _videoTitleColumnName: title,
  //     },
  //   );
  // }

  Future<void> deleteFile(int id) async {
    try {
      final db = await database;

      final data = await db.query(
        _videotable,
        where: '$_videovidIdColumnName = ?',
        whereArgs: [id],
      );

      if (data.isNotEmpty) {
        final filepath = data.first[_videofilepathColumnName] as String;
        final thumbnaipath =
            data.first[_videothumbnailpathColumnName] as String;

        File(filepath).deleteSync();
        File(thumbnaipath).deleteSync();

        await db.delete(
          _videotable,
          where: '$_videovidIdColumnName = ?',
          whereArgs: [id],
        );
        print("File Deleted Successfully $filepath");
      }
    } catch (e) {
      print("Failed to delete file: $e");
    }
  }

  Future<FilePath?> getFileById(int id) async {
    try {
      final db = await database;

      final data = await db.query(
        _videotable,
        where: '$_videoIdColumnName = ?',
        whereArgs: [id],
      );
      if (data.isNotEmpty) {
        final file = data.first;
        return FilePath(
          id: file[_videoIdColumnName] as int,
          vid_id: file[_videovidIdColumnName] as int,
          path: file[_videofilepathColumnName] as String,
          thumbnail: file[_videothumbnailpathColumnName] as String,
          version: file[_videoVersionColumnName] as int,
          title: file[_videoTitleColumnName] as String,
          width: file[_videoWidthColumnName] as int,
          height: file[_videoheightColumnName] as int,
          date: file[_videoDateColumnName] as String,
        );
      }
    } catch (e) {
      print("Error getting file by id: $e");
    }
    return null;
  }

  Future<int> getVidId(String path) async {
    try {
      final db = await database;
      final data = await db.query(
        _videotable,
        columns: [_videovidIdColumnName],
        where: '$_videofilepathColumnName = ?',
        whereArgs: [path],
      );
      if (data.isNotEmpty) {
        return data.first[_videovidIdColumnName] as int;
      }
    } catch (e) {
      print("Error getting ID by path: $e");
    }
    return -1;
  }

  Future<String> getFilepathBackward(String path, {int decrement = 1}) async {
    try {
      final db = await database;
      int vid_id = await getVidId(path);
      if (vid_id == -1) {
        return "";
      }

      final data = await db.query(
        _videotable,
        columns: [_videoVersionColumnName],
        where: '$_videovidIdColumnName=? AND $_videofilepathColumnName = ?',
        whereArgs: [vid_id, path],
      );
      if (data.isNotEmpty) {
        print("!!!!!!!!!!!!!");
        int currentVersion = data.first[_videoVersionColumnName] as int;
        int newVersion = currentVersion - decrement;
        if (newVersion < 1) {
          newVersion = 1; // Ensure version does not go below 1
        }

        final d = await db.query(_videotable,
            columns: [_videofilepathColumnName],
            where: '$_videovidIdColumnName=? And $_videoVersionColumnName=?',
            whereArgs: [vid_id, newVersion]);

        if (d.isNotEmpty) {
          return d.first[_videofilepathColumnName] as String;
        }
      }
    } catch (e) {
      print("Error getting ID by path: $e");
    }
    return "";
  }

  Future<String> getFilepathForward(String path,
      {int increament = 1, required int increment}) async {
    try {
      final db = await database;
      int vid_id = await getVidId(path);
      if (vid_id == -1) {
        return "";
      }

      final data = await db.query(
        _videotable,
        columns: [_videoVersionColumnName],
        where: '$_videovidIdColumnName=? AND $_videofilepathColumnName = ?',
        whereArgs: [vid_id, path],
      );
      if (data.isNotEmpty) {
        print("!!!!!!!!!!!!!");
        int currentVersion = data.first[_videoVersionColumnName] as int;
        int newVersion = currentVersion + increament;
        int highestversion = await getHighestVersionByVidId(vid_id);
        if (newVersion >= highestversion) {
          newVersion = highestversion; // Ensure version does not go below 1
        }

        final d = await db.query(_videotable,
            columns: [_videofilepathColumnName],
            where: '$_videovidIdColumnName=? And $_videoVersionColumnName=?',
            whereArgs: [vid_id, newVersion]);

        if (d.isNotEmpty) {
          return d.first[_videofilepathColumnName] as String;
        }
      }
    } catch (e) {
      print("Error getting ID by path: $e");
    }
    return "";
  }

  // Future<int> getVersionByFilePath(String path) async {
  //   try {
  //     final db = await database;
  //     final Vid_id = getVidId(path);

  //     final data = await db.query(
  //       _videotable,
  //       columns:
  //       );
  //   } catch (e) {}
  // }

  Future<double> getheight(String path) async {
    try {
      final db = await database;
      final id = await getId(path);

      final data = await db.query(_videotable,
          columns: [_videoheightColumnName],
          where: '$_videoIdColumnName = ?',
          whereArgs: [id]);

      if (data.isNotEmpty) {
        print("bbbb === >>> ${data.first[_videoheightColumnName]}");

        return (data.first[_videoheightColumnName] as int).toDouble();
      } else {
        return -1;
      }
    } catch (e) {
      print("error gatting height");
      return -1;
    }
  }

  Future<double> getwidth(String path) async {
    try {
      final db = await database;
      final id = await getId(path);
      print("id =========== >>>>>> $id");

      final data = await db.query(_videotable,
          columns: [_videoWidthColumnName],
          where: '$_videoIdColumnName = ?',
          whereArgs: [id]);

      if (data.isNotEmpty) {
        print("ddddd ========>>>> $data");
        print("rrrr ===> ${data.first[_videoWidthColumnName]}");
        return (data.first[_videoWidthColumnName] as int).toDouble();
      } else {
        return -1;
      }
    } catch (e) {
      print("error gatting width");
      return -1;
    }
  }

  Future<int> changeRatio(String path, double w, double h) async {
    try {
      final db = await database;
      final id = await getId(path);

      if (id == -1) {
        return -1;
      }

      final data = await db.update(
          _videotable, {_videoWidthColumnName: w, _videoheightColumnName: h},
          where: '$_videoIdColumnName = ?', whereArgs: [id]);

      return data;
    } catch (e) {
      print("Error in changeRatio: $e");
      return -1;
    }
  }

  Future<int> getId(String path) async {
    try {
      final db = await database;

      final data = await db.query(_videotable,
          columns: [_videoIdColumnName],
          where: '$_videofilepathColumnName = ?',
          whereArgs: [path]);

      if (data.isNotEmpty) {
        return data.first[_videoIdColumnName] as int;
      }
    } catch (e) {
      print("Error in getId: $e");
    }
    return -1;
  }

  Future<void> renameFile(int id, String newFilePath) async {
    try {
      final db = await database;

      await db.update(
        _videotable,
        {_videoTitleColumnName: newFilePath},
        where: '$_videovidIdColumnName = ?',
        whereArgs: [id],
      );

      print("File renamed successfully to: $newFilePath");
    } catch (e) {
      print("Failed to rename file: $e");
    }
  }

  Future<void> renameFilesByVidId(int vidId, String newFilePath) async {
    try {
      final db = await database;

      // Fetch all files with the same vid_id
      final files = await db.query(
        _videotable,
        where: '$_videovidIdColumnName = ?',
        whereArgs: [vidId],
      );

      // Iterate over each file and rename
      for (final file in files) {
        final oldFilePath = file[_videofilepathColumnName] as String;
        final oldThumbnailPath = file[_videothumbnailpathColumnName] as String;

        // Define new file paths
        final newFileName = basename(newFilePath);
        final newThumbnailName = 'thumbnail_${newFileName}';
        final newThumbnailPath = join(dirname(newFilePath), newThumbnailName);

        // Rename files on disk
        final newFile = await File(oldFilePath).rename(newFilePath);
        final newThumbnail =
            await File(oldThumbnailPath).rename(newThumbnailPath);

        // Update database record
        await db.update(
          _videotable,
          {
            _videofilepathColumnName: newFile.path,
            _videothumbnailpathColumnName: newThumbnail.path,
          },
          where: '$_videoIdColumnName = ?',
          whereArgs: [file[_videoIdColumnName]],
        );
      }

      print("Files renamed successfully for vid_id: $vidId");
    } catch (e) {
      print("Failed to rename files: $e");
    }
  }

  Future<String> getFileNameByVIdID(int videoId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
          'SELECT * FROM $_videotable WHERE $_videovidIdColumnName = ?',
          [videoId]);

      if (result.isNotEmpty) {
        return result.toString();
      } else {
        // Handle case where no result is found, return a default value or throw an exception
        throw Exception('Video with ID $videoId not found');
      }
    } catch (e) {
      print("Failed to rename file: $e");
      return "";
    }
  }

  final String _captionTable = "captions_table";
  final String _captionId = "id";
  final String _captionVideoId = "vid_id";
  final String _captionStartFrom = "start_from";
  final String _captionEndTo = "end_to";
  final String _captionKeyword = "keyword";
  final String _captionText = "text";
  final String _captionTextColor = "text_color";
  final String _captionBackgroundColor = "background_color";
  final String _captionIsBold = "is_bold";
  final String _captionIsUnderline = "is_underline";
  final String _captionIsItalic = "is_italic";
  final String _captionCombineIds = "combine_ids";

  void createCaptionTable(Database db) async {
    print("hello it working");
    await db.execute('''
  CREATE TABLE $_captionTable (
    $_captionId INTEGER PRIMARY KEY AUTOINCREMENT,
    $_captionVideoId TEXT NOT NULL,
    $_captionStartFrom TEXT,
    $_captionEndTo TEXT,
    $_captionKeyword TEXT,
    $_captionText TEXT,
    $_captionTextColor TEXT,
    $_captionBackgroundColor TEXT,
    $_captionIsBold TEXT,
    $_captionIsUnderline TEXT,
    $_captionIsItalic TEXT,
    $_captionCombineIds TEXT
  )
''');
  }

  Future<void> addCaptions(
      {required String videoId,
      required String startTime,
      required String toTime,
      required String keywords,
      required String text}) async {
    try {
      final db = await database;
      int id = await db.insert(_captionTable, {
        _captionVideoId: videoId,
        _captionStartFrom: startTime,
        _captionEndTo: toTime,
        _captionKeyword: keywords,
        _captionText: text,
        _captionTextColor: "0xFFFFFFFF",
        _captionBackgroundColor: "0xFFFF0000",
        _captionIsBold: "0",
        _captionIsUnderline: "0",
        _captionIsItalic: "0",
      });
      await db.update(
        _captionTable,
        {
          _captionCombineIds: "$id",
        },
        where: '$_captionId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Failed to add file: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getCaptionForVideo(
      {required String videoId}) async {
    try {
      final db = await database;
      final data = await db.query(
        _captionTable,
        where: '$_captionVideoId = ?',
        whereArgs: [videoId],
      );
      print("caption Data === > $data");
      return data;
    } catch (e) {
      print("Failed to fetch captions: $e");
      return [];
    }
  }

  Future<void> deleteCaptionData(int id) async {
    try {
      final db = await database;
      await db.delete(
        _captionTable,
        where: '$_captionVideoId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Failed to delete file: $e");
    }
  }

  Future<void> updatebold(String id, String value) async {
    print("Video Id === >>> $id");
    try {
      final db = await database;
      await db.update(_captionTable, {_captionIsBold: value},
          where: '$_captionId = ?', whereArgs: [id]);
      print('Updated bold status for caption with ID: $id');
    } catch (e) {
      print('Error updating bold status: $e');
    }
  }

  Future<void> updatecolor(String id, String value) async {
    print("Video Id === >>> $id");
    try {
      final db = await database;
      await db.update(_captionTable, {_captionTextColor: value},
          where: '$_captionId = ?', whereArgs: [id]);
      print('Updated Color status for caption with ID: $id');
    } catch (e) {
      print('Error updating color status: $e');
    }
  }

  Future<void> updateItalic(String id, String value) async {
    print("Video Id === >>> $id");
    try {
      final db = await database;
      await db.update(_captionTable, {_captionIsItalic: value},
          where: '$_captionId = ?', whereArgs: [id]);
      print('Updated bold status for caption with ID: $id');
    } catch (e) {
      print('Error updating bold status: $e');
    }
  }

  Future<void> updateUnderline(String id, String value) async {
    print("Video Id === >>> $id");
    try {
      final db = await database;
      await db.update(_captionTable, {_captionIsUnderline: value},
          where: '$_captionId = ?', whereArgs: [id]);
      print('Updated bold status for caption with ID: $id');
    } catch (e) {
      print('Error updating bold status: $e');
    }
  }

  Future<void> getUpdateCaptionValueById({
    required String mainIndexId,
    required String combineIds,
    required String text,
  }) async {
    try {
      final db = await database;
      List<int> idsIntList =
          combineIds.split(",").map((id) => int.parse(id.trim())).toList();

      final query = '''
    UPDATE $_captionTable
    SET $_captionKeyword = "$text"
    WHERE $_captionId IN($mainIndexId)
    ''';
      await db.rawQuery(query);

      _updateCaptions(db, idsIntList);
    } catch (e) {
      print("Failed to fetch captions: $e");
    }
  }

  Future<void> getSplitTextUpdate({
    required String mainIndexId,
    required String combineIds,
    required bool isSplitBefore,
  }) async {
    try {
      final db = await database;
      int mainIntIndexId = int.parse(mainIndexId);
      List<int> idsIntList =
          combineIds.split(",").map((id) => int.parse(id.trim())).toList();

      // Splitting IDs based on isSplitBefore
      List<int> splittingIds = [];
      List<int> staysIds = [];
      for (var id in idsIntList) {
        if (isSplitBefore) {
          (id < mainIntIndexId ? splittingIds : staysIds).add(id);
        } else {
          (id > mainIntIndexId ? splittingIds : staysIds).add(id);
        }
      }
      // Updating the database with the new values
      await _updateCaptions(db, splittingIds);
      await _updateCaptions(db, staysIds);
    } catch (e) {
      print("Failed to fetch captions: $e");
    }
  }

  Future<void> _updateCaptions(Database db, List<int> ids) async {
    if (ids.isEmpty) return;

    String idsString = ids.join(',');
    String text = await _getCombinedKeywords(db, ids);

    final query = '''
  UPDATE $_captionTable
  SET $_captionText = "$text", $_captionCombineIds = "$idsString"
  WHERE $_captionId IN($idsString)
''';

    print("Query: $query");

    var data = await db.rawQuery(query);
    print("caption data === > $data");
  }

  Future<String> _getCombinedKeywords(Database db, List<int> ids) async {
    List<String> keywords = [];

    for (var id in ids) {
      String keyword = await _getKeyword(db, id);
      keywords.add(keyword);
    }

    return keywords.join(' ');
  }

  Future<String> _getKeyword(Database db, int id) async {
    try {
      final query = '''
   SELECT $_captionKeyword FROM $_captionTable WHERE $_captionId = $id;
  ''';
      final data = await db.rawQuery(query);
      return data[0][_captionKeyword].toString();
    } catch (e) {
      print("Failed to fetch captions: $e");
    }
    return "";
  }

  Future<void> getCaptionMerga({
    required String combineIds,
    required String mergingCombineIds,
    required bool isMergeBefore,
  }) async {
    if (combineIds != mergingCombineIds) {
      try {
        final db = await database;
        List<int> mainIdsIntList =
            combineIds.split(",").map((id) => int.parse(id.trim())).toList();
        List<int> mergingIdsIntList = mergingCombineIds
            .split(",")
            .map((id) => int.parse(id.trim()))
            .toList();

        String mainText = await _getCombinedKeywords(db, mainIdsIntList);
        String mergingText = await _getCombinedKeywords(db, mergingIdsIntList);
        String finalText = "";
        String finalIds = "";
        if (isMergeBefore) {
          finalText = "$mergingText $mainText";
          finalIds = "$mergingCombineIds,$combineIds";
        } else {
          finalText = "$mainText $mergingText";
          finalIds = "$combineIds,$mergingCombineIds";
        }

        // Print the query for debugging
        final query = '''
      UPDATE $_captionTable
      SET $_captionText = "$finalText",$_captionCombineIds = "$finalIds"
      WHERE $_captionId IN($finalIds)
    ''';
        print("Query: $query");
        print("Values: $finalText");
        print("WhereArgs: [$finalIds]");

        // Execute the update query
        final data = await db.rawQuery(query);

        print("caption Data === > $data");
      } catch (e) {
        print("Failed to fetch captions: $e");
      }
    }
  }
}
