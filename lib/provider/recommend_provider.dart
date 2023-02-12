import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';


final recommendProvider = FutureProvider.family((ref, int id) =>  RecommendMovieProvider.getMovie(id));

class RecommendMovieProvider {

 static Future<List<Movie>> getMovie(int id) async{
    final dio = Dio();
    try{
      final response = await dio.get('https://api.themoviedb.org/3/movie/$id/recommendations',
          queryParameters: {
            'api_key': '2a0f926961d00c667e191a21c14461f8',
          }
      );
      final data = (response.data['results'] as List).map((e) => Movie.fromJson(e)).toList();
      return data;
    } on DioError catch(err){
      throw 'something went wrong';
    }
  }

}