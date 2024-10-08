import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([
  FirebaseFirestore,
  DocumentReference,
  DocumentSnapshot,
  WriteBatch,
], customMocks: [
  MockSpec<CollectionReference>(as: #MockCollectionsRef),
])
class Ref<T> extends Mock {
  T get ref;
}

void main() {}