import 'dart:ui';
import 'package:flutter_movie/provider/fav_movie_provider.dart';
import 'package:flutter_movie/services/connectivity_check.dart';
import 'package:flutter_movie/view/genre_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';
import 'package:sizer/sizer.dart';
import '../models/movie.dart';
import '../provider/recommend_provider.dart';
import '../provider/video_key_provider.dart';



class DetailPage extends StatelessWidget {
final Movie movie;
final ConnectivityStatus connects;
DetailPage(this.movie, this.connects);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OrientationBuilder(
            builder: (context, ori) {
              return Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(movie.poster_path), onError: (o, s) => AssetImage('assets/images/perfume.jpg')),
                    ),
                    child: BackdropFilter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0)),
                  ),
                  Container(
                    child: Consumer(
                        builder: (context, ref, child) {
                          final keyData = ref.watch(keyProvider(movie.id));
                          final favMovie = ref.watch(favMovieProvider);
                          final isFav = favMovie.firstWhere((element) => element.id == movie.id, orElse: (){
                            return Movie(id: 0,
                                title: 'no-data',
                                overview: '', release_date: '', vote_average: 0, poster_path: '', isFavorite: false, genres: []);
                          });
                          return SafeArea(
                            child: Container(
                              child: keyData.when(
                                  data: (data) {
                                    return VideoShow(data, ref, ori, movie, connects, isFav, movie.id);
                                  },
                                  error: (err, stack) =>
                                      Center(child: Text('$err')),
                                  loading: () => Container()
                              ),
                            ),
                          );
                        }
                    ),
                  ),

                ],
              );
            }
        )
    );
  }
}



class VideoShow extends StatefulWidget {
final String id;
final WidgetRef ref;
final  ori;
final Movie movie;
final ConnectivityStatus connects;
final int movieId;
final Movie isFav;
VideoShow(this.id, this.ref, this.ori, this.movie, this.connects, this.isFav, this.movieId);
  @override
  State<VideoShow> createState() => _VideoShowState();
}

class _VideoShowState extends State<VideoShow> {

  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube(
        'https://youtu.be/${widget.id}',
      ),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
 final recommend = widget.ref.watch(recommendProvider(widget.movieId));
    return  ListView(
      physics: BouncingScrollPhysics(),
      children: [
        Container(
          height:
          250 ,
          child: widget.id == '' ? Container(child: Center(child: Text('video not available'),),):  PodVideoPlayer(
              controller: controller
          ),),
        if(widget.ori == Orientation.portrait) Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width* 0.7,
                    child: Wrap(
                      children: widget.movie.genres.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  )
                              ),
                              onPressed: (){
                                Navigator.of(context).pop();
                                Get.to(() => GenrePage(e.id, widget.connects), transition: Transition.leftToRight);
                              }, child: Text(e.name)),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(onPressed: (){
                    if(widget.isFav.title == 'no-data'){
                      widget.ref.read(favMovieProvider.notifier).addMovie(widget.movie);
                    }else{
                     widget.ref.read(favMovieProvider.notifier).removeMovie(widget.movie);
                    }

                  }, icon: Icon(widget.isFav.title == 'no-data' ?  Icons.favorite_border : Icons.favorite))
                ],
              ),
              Text('Story Line', style: TextStyle(fontSize: 30, letterSpacing: 2),),
              SizedBox(height: 15,),
              Text(widget.movie.overview,
                style: TextStyle(fontSize: 15,

                    letterSpacing: 1),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('Recommended Movies', style: TextStyle(fontSize: 15.sp),),
                  ),
                  Container(
                    child: recommend.when(
               data: (data){
                 return Container(
                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                   child: GridView.builder(
                     shrinkWrap: true,
                     physics: NeverScrollableScrollPhysics(),
                     itemCount: data.length,
                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                           crossAxisCount: 4,
                         childAspectRatio: 2/3,
                         mainAxisSpacing: 10,
                         crossAxisSpacing: 10
                       ),
                       itemBuilder: (context, index){
                         return Image.network(data[index].poster_path);
                       }
                   ),
                 );
               },
               error: (err, stack) => Container(),
               loading: () =>Container()
             )
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
