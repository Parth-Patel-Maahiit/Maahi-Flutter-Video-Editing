class GetVideoModel {
  String? status;
  String? message;
  int? count;
  List<Data>? data;

  GetVideoModel({this.status, this.message, this.count, this.data});

  GetVideoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    count = json['count'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? title;
  String? scriptId;
  String? fileName;
  String? userId;
  String? isDeleted;
  String? status;
  String? insertedTime;
  // ignore: unnecessary_question_mark
  Null? updatedTime;
  String? createdByUserId;

  Data(
      {this.id,
      this.title,
      this.scriptId,
      this.fileName,
      this.userId,
      this.isDeleted,
      this.status,
      this.insertedTime,
      this.updatedTime,
      this.createdByUserId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    scriptId = json['script_id'];
    fileName = json['file_name'];
    userId = json['user_id'];
    isDeleted = json['is_deleted'];
    status = json['status'];
    insertedTime = json['inserted_time'];
    updatedTime = json['updated_time'];
    createdByUserId = json['created_by_user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['script_id'] = this.scriptId;
    data['file_name'] = this.fileName;
    data['user_id'] = this.userId;
    data['is_deleted'] = this.isDeleted;
    data['status'] = this.status;
    data['inserted_time'] = this.insertedTime;
    data['updated_time'] = this.updatedTime;
    data['created_by_user_id'] = this.createdByUserId;
    return data;
  }
}