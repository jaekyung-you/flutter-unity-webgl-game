import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'data/repositories/local_score_repository.dart';
import 'data/repositories/score_repository.dart';
import 'features/splash/view/splash_screen.dart';

class KalToeWangApp extends StatelessWidget {
  const KalToeWangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ScoreRepository>(
      create: (_) => LocalScoreRepository(),
      child: MaterialApp(
        title: '칼퇴왕',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.yellow),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
