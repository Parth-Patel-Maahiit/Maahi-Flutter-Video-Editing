class GetCaptionDataModel {
  dynamic id;
  dynamic vidId;
  dynamic startFrom;
  dynamic endTo;
  dynamic keyword;
  dynamic text;
  dynamic textColor;
  dynamic backgroundColor;
  dynamic isBold;
  dynamic isUnderLine;
  dynamic isItalic;
  dynamic combineIds;

  GetCaptionDataModel(
      {this.id,
      this.vidId,
      this.startFrom,
      this.endTo,
      this.keyword,
      this.text,
      this.textColor,
      this.backgroundColor,
      this.isBold,
      this.isUnderLine,
      this.isItalic,
      this.combineIds});

  GetCaptionDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vidId = json['vid_id'];
    startFrom = json['start_from'];
    endTo = json['end_to'];
    keyword = json['keyword'];
    text = json['text'];
    textColor = json['text_color'];
    backgroundColor = json['background_color'];
    isBold = json['is_bold'];
    isUnderLine = json['is_underline'];
    isItalic = json['is_italic'];
    combineIds = json['combine_ids'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['vid_id'] = this.vidId;
    data['start_from'] = this.startFrom;
    data['end_to'] = this.endTo;
    data['keyword'] = this.keyword;
    data['text'] = this.text;
    data['text_color'] = this.textColor;
    data['background_color'] = this.backgroundColor;
    data['is_bold'] = this.isBold;
    data['is_underline'] = this.isUnderLine;
    data['is_italic'] = this.isItalic;
    data['combine_ids'] = this.combineIds;

    return data;
  }
}
