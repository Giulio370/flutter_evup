import 'package:evup_flutter/Classi/User.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:palette_generator/palette_generator.dart';

class ProfilePicture extends StatelessWidget {
  final String imageUrl;

  const ProfilePicture({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width / 6,
      height: MediaQuery.of(context).size.width / 6,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Colore di sfondo del quadrato
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.0), // Bordo arrotondato in basso a sinistra
        ),
      ),
      child: ClipRect(
        child: Image.network(
          imageUrl,
          fit: BoxFit.fill, // Adatta l'immagine per coprire tutto il quadrato
        ),
      ),
    );
  }
}
////////////////////////////////////////////////////////////////////////

class UserInfoPage extends StatefulWidget {
  final String refreshToken;
  final String accessToken;

  UserInfoPage({required this.refreshToken, required this.accessToken});

  @override
  _UserInfoPageState createState() => _UserInfoPageState(refreshToken: refreshToken,accessToken: accessToken);
}

class _UserInfoPageState extends State<UserInfoPage> {
  late Future<User> _userFuture;
  late PaletteGenerator _paletteGenerator;
  Color? _backgroundColor;



  final String refreshToken;
  final String accessToken;
  _UserInfoPageState({required this.refreshToken, required this.accessToken});

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUser();
    _paletteGenerator = PaletteGenerator.fromColors([PaletteColor(Colors.white, 1)]); // Inizializza _paletteGenerator con un colore predefinito
  }

  Future<User> fetchUser() async {
    String url1 = 'http://localhost:8000/auth/fetch/user';
    final Dio dio = Dio();

    try {
      // Crea un oggetto Options per includere i cookie nella richiesta
      Options options = Options(
        responseType: ResponseType.json,
        followRedirects: false,
        headers: {'cookie': '$refreshToken; $accessToken'},
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

  Future<void> _generatePalette(String imageUrl) async {
    final imageProvider = NetworkImage(imageUrl);
    final paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);

    setState(() {
      _paletteGenerator = paletteGenerator;
      _backgroundColor = _paletteGenerator.darkVibrantColor != null ? _paletteGenerator.darkVibrantColor!.color.withOpacity(0.3) : Colors.white;
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagina Utente'),
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final User user = snapshot.data!;
            _generatePalette(user.picture); // Genera la palette dei colori dall'immagine del profilo
            return Container(
              color: _backgroundColor,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Colore di sfondo del Container delle informazioni utente con opacità al 80%
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // Riduce l'intensità dell'ombra
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.0),
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user.picture),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(user.email, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ruolo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(user.role, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Piano', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(user.plan, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Descrizione', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(user.description, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('Nessun dato disponibile'));
          }
        },
      ),
    );
  }
}
////////////////////////////////////////////////////////////////////////////////////////////
// class UserInfoPage extends StatelessWidget {
//   final String refreshToken;
//   final String accessToken;

//   UserInfoPage({required this.refreshToken, required this.accessToken});//



//   Future<User> fetchUser() async {
//     String url1 = 'http://localhost:8000/auth/fetch/user';
//     final Dio dio = Dio();

//     try {
//       // Crea un oggetto Options per includere i cookie nella richiesta
//       Options options = Options(
//         responseType: ResponseType.json,
//         followRedirects: false,
//         headers: {'cookie': '$refreshToken; $accessToken'},
//       );
//       final response = await dio.get(
//         url1,
//         options: options,
//       );

//       if (response.statusCode == 200) {
//         return User.fromJson(response.data);
//       } else {
//         throw Exception('Errore durante la richiesta HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Errore durante la richiesta HTTP: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pagina Utente'),
//       ),
//       body: FutureBuilder<User>(
//         future: fetchUser(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Errore: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             final User user = snapshot.data!;
//             return Center(
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.4, // Larghezza del 80% della larghezza dello schermo
//                 padding: EdgeInsets.all(16.0),
//                 margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),//EdgeInsets.symmetric(horizontal: 20.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 5,
//                       blurRadius: 7,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 20.0),
//                     Center(
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundImage: NetworkImage(user.picture),
//                       ),
//                     ),
//                     SizedBox(height: 20.0),
//                     Text('Nome: ${user.firstName}'),
//                     Text('Cognome: ${user.lastName}'),
//                     Text('Email: ${user.email}'),
//                     Text('Ruolo: ${user.role}'),
//                     Text('Piano: ${user.plan}'),
//                     Text('Descrizione: ${user.description}'),
//                     SizedBox(height: 20.0),
//                   ],
//                 ),
//               ),
//             );
//           } else {
//             return Center(child: Text('Nessun dato disponibile'));
//           }
//         },
//       ),
//     );
//   }
// }



/////////////////////////////////////////////////////////////////////////////////////////////////////////////MetodoOK
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pagina Utente'),
//       ),
//       body: FutureBuilder<User>(
//         future: fetchUser(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Errore: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             final User user = snapshot.data!;
//             return Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Nome: ${user.firstName}'),
//                   Text('Cognome: ${user.lastName}'),
//                   Text('Email: ${user.email}'),
//                   Text('Ruolo: ${user.role}'),
//                   Text('Piano: ${user.plan}'),
//                   Text('Descrizione: ${user.description}'),
//                   SizedBox(height: 16.0),
//                   ProfilePicture(imageUrl: user.picture),
//                 ],
//               ),
//             );
//           } else {
//             return Center(child: Text('Nessun dato disponibile'));
//           }
//         },
//       ),
//     );
//   }
// }
