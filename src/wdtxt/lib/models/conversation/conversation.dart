import 'package:meta/meta.dart';

@immutable
class Conversation {
  
  late final String alpha;
  late final String beta;

  Conversation({
    required String id1,
    required String id2
  }){
    alpha = (id1.compareTo(id2) < 0) ? id1 : id2;
    beta = (alpha == id1) ? id2 : id1;
  }

  Conversation copyWith({
    String? id1,
    String? id2
  }){
    return Conversation(
      id1: id1 ?? alpha, 
      id2: id2 ?? beta,
    );
  }

  @override
  String toString() {
    return 'Converstation($alpha, $beta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return (other is Conversation) && 
      (other.alpha == alpha) &&
      (other.beta == beta);
  }

  @override
  int get hashCode => 
    Object.hash(alpha.hashCode, beta.hashCode);
  
}
