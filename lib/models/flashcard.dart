class FlashCard {
  final String front;
  final String back;



factory FlashCard.fromJson(Map<String, dynamic> json){
  return FlashCard(
    front: json['front'],
    back: json ['back'],
  );
}

const FlashCard({
  required this.front,
  required this.back
  
  });
}



