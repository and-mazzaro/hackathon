import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/quiz_question.dart';

/// Italian quiz questions. An English file can be added next to it later.
const quizContentAsset = 'assets/content/quiz_questions_it.json';

/// All quiz questions, loaded once from the app's assets.
/// Tests override this provider with a small fixed bank.
final quizBankProvider = FutureProvider<QuizBank>((ref) async {
  final text = await rootBundle.loadString(quizContentAsset);
  return QuizBank.fromJson(
      (jsonDecode(text) as Map).cast<String, Object?>());
});
