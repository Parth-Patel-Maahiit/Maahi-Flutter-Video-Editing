class GetScriptModel {
  String? status;
  String? message;
  int? count;
  List<Data>? data;

  GetScriptModel({this.status, this.message, this.count, this.data});

  GetScriptModel.fromJson(Map<String, dynamic> json) {
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
  String? scriptText;
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
      this.scriptText,
      this.userId,
      this.isDeleted,
      this.status,
      this.insertedTime,
      this.updatedTime,
      this.createdByUserId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    scriptText = json['script_text'];
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
    data['script_text'] = this.scriptText;
    data['user_id'] = this.userId;
    data['is_deleted'] = this.isDeleted;
    data['status'] = this.status;
    data['inserted_time'] = this.insertedTime;
    data['updated_time'] = this.updatedTime;
    data['created_by_user_id'] = this.createdByUserId;
    return data;
  }
}