class SignupModel {
  dynamic status;
  dynamic message;
  dynamic count;
  dynamic data;

  SignupModel({this.status, this.message, this.count, this.data});

  SignupModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    count = json['count'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['count'] = this.count;
    data['data'] = this.data;
    return data;
  }
}
