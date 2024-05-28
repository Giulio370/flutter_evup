import 'package:evup_flutter/Classi/User.dart';
import 'package:evup_flutter/signup.dart';
import 'package:evup_flutter/userInfo.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class HomePage extends StatefulWidget {
  final String refreshToken;
  final String accessToken;

  const HomePage({
    required this.refreshToken,
    required this.accessToken,
  });

  @override
  _HomePageState createState() => _HomePageState(refreshToken: this.refreshToken, accessToken: this.accessToken);
}

class _HomePageState extends State<HomePage> {
  final String refreshToken;
  final String accessToken;
  _HomePageState({required this.refreshToken, required this.accessToken});

  late Future<User> _futureUser;
  
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUser();
  }

  Future<User> fetchUser() async {
    String url1 = 'http://localhost:8000/auth/fetch/user';
    final Dio dio = Dio();

    try {
      Options options = Options(
        responseType: ResponseType.json,
        followRedirects: false,
        headers: {'cookie': '${widget.refreshToken}; ${widget.accessToken}'},
      );
      final response = await dio.get(
        url1,
        options: options,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Errore durante la richiesta HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore durante la richiesta HTTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca...',
                    //border: InputBorder.none,
                  ),
                  // Logica per la ricerca
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search), // Icona della lente di ingrandimento
              onPressed: () {
                // Logica da eseguire quando viene premuto il pulsante di ricerca
              },
            ),
            // FutureBuilder<User>(
            //   future: _futureUser,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return CircularProgressIndicator();
            //     } else if (snapshot.hasError) {
            //       return Text('Errore durante il recupero delle informazioni dell\'utente');
            //     } else {
            //       return Row(
            //         children: [
            //           CircleAvatar(
            //             backgroundImage: NetworkImage(snapshot.data?.picture ?? ''),
            //           ),
            //           SizedBox(width: 10),
            //           Text(snapshot.data?.firstName ?? ''),
            //         ],
            //       );
            //     }
            //   },
            // ),

          ],
        ),
        actions: [// Altri elementi dell'app bar a destra se necessario
          FutureBuilder<User>(
              future: _futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Errore durante il recupero delle informazioni dell\'utente');
                } else {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Logica da eseguire quando viene premuto il CircleAvatar
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> UserInfoPage(refreshToken: refreshToken, accessToken: accessToken,) ));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0), // Imposta il padding sui lati del CircleAvatar
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data?.picture ?? ''),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          
          ],
        ),
        drawer: Drawer(
          // Contenuto del Drawer (menu a scomparsa)
        ),
        body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(46.040012, 11.075988),
                  initialZoom: 9.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        //onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                        ],
                ),
            ],
          ) 
        );
      }
    } 
