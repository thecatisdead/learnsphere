class Flashcard {
  final String front;
  final String back;



factory Flashcard.fromJson(Map<String, dynamic> json){
  return Flashcard(
    front: json['front'],
    back: json ['back'],
  );
}

const Flashcard({
  required this.front,
  required this.back
  
  });
}



