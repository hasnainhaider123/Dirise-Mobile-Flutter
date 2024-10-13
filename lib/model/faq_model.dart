class FaqModel {
  bool? status;
  String? message;
  List<Faq>? faq;

  FaqModel({this.status, this.message, this.faq});

  FaqModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['faq'] != null) {
      faq = <Faq>[];
      json['faq'].forEach((v) {
        faq!.add(new Faq.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = status;
    data['message'] = message;
    if (faq != null) {
      data['faq'] = faq!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Faq {
  bool isOpen = false;
  dynamic id;
  dynamic question;
  dynamic answer;
  String? arabQuestion;
  dynamic arabDescription;

  Faq({this.id, this.question, this.answer,this.arabDescription,this.arabQuestion});

  Faq.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    arabDescription = json['arab_description'];
    arabQuestion = json['arab_question'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['question'] = question;
    data['arab_question'] = arabQuestion;
    data['answer'] = answer;
    data['arab_description'] = arabDescription;
    return data;
  }
}
