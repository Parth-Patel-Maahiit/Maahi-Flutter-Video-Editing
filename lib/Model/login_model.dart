class LoginModel {
  bool? status;
  dynamic message;
  dynamic count;
  Data? data;

  LoginModel({this.status, this.message, this.count, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    count = json['count'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  dynamic id;
  dynamic role;
  dynamic userIdentity;
  dynamic registeredFrom;
  dynamic mobileToken;
  dynamic videoBalance;
  dynamic type;
  dynamic name;
  dynamic emailId;
  dynamic empCode;
  dynamic dob;
  dynamic phoneNo;
  dynamic mobile;
  dynamic stateId;
  dynamic cityId;
  dynamic code;
  dynamic loginName;
  dynamic password;
  dynamic passwordTxt;
  dynamic referralCode;
  dynamic status;
  dynamic isDeleted;
  dynamic tokenId;
  dynamic logo;
  dynamic userImg;
  dynamic insertedTime;
  dynamic updatedTime;
  dynamic createdByUserId;

  Data(
      {this.id,
      this.role,
      this.userIdentity,
      this.registeredFrom,
      this.mobileToken,
      this.videoBalance,
      this.type,
      this.name,
      this.emailId,
      this.empCode,
      this.dob,
      this.phoneNo,
      this.mobile,
      this.stateId,
      this.cityId,
      this.code,
      this.loginName,
      this.password,
      this.passwordTxt,
      this.referralCode,
      this.status,
      this.isDeleted,
      this.tokenId,
      this.logo,
      this.userImg,
      this.insertedTime,
      this.updatedTime,
      this.createdByUserId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    userIdentity = json['user_identity'];
    registeredFrom = json['registered_from'];
    mobileToken = json['mobile_token'];
    videoBalance = json['video_balance'];
    type = json['type'];
    name = json['name'];
    emailId = json['email_id'];
    empCode = json['emp_code'];
    dob = json['dob'];
    phoneNo = json['phone_no'];
    mobile = json['mobile'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    code = json['code'];
    loginName = json['login_name'];
    password = json['password'];
    passwordTxt = json['password_txt'];
    referralCode = json['referral_code'];
    status = json['status'];
    isDeleted = json['is_deleted'];
    tokenId = json['token_id'];
    logo = json['logo'];
    userImg = json['user_img'];
    insertedTime = json['inserted_time'];
    updatedTime = json['updated_time'];
    createdByUserId = json['created_by_user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['user_identity'] = this.userIdentity;
    data['registered_from'] = this.registeredFrom;
    data['mobile_token'] = this.mobileToken;
    data['video_balance'] = this.videoBalance;
    data['type'] = this.type;
    data['name'] = this.name;
    data['email_id'] = this.emailId;
    data['emp_code'] = this.empCode;
    data['dob'] = this.dob;
    data['phone_no'] = this.phoneNo;
    data['mobile'] = this.mobile;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data['code'] = this.code;
    data['login_name'] = this.loginName;
    data['password'] = this.password;
    data['password_txt'] = this.passwordTxt;
    data['referral_code'] = this.referralCode;
    data['status'] = this.status;
    data['is_deleted'] = this.isDeleted;
    data['token_id'] = this.tokenId;
    data['logo'] = this.logo;
    data['user_img'] = this.userImg;
    data['inserted_time'] = this.insertedTime;
    data['updated_time'] = this.updatedTime;
    data['created_by_user_id'] = this.createdByUserId;
    return data;
  }
}