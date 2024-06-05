import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Classi/Event.dart';

class AddEventPage extends StatefulWidget {
  final String accessToken;
  final String refreshToken;
  final Future<List<Event>>? futureEvents;

  //AddEventPage({required this.accessToken, required this.refreshToken});
  AddEventPage({required this.accessToken, required this.refreshToken,  this.futureEvents});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = fetchEvents();
  }

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/events/get'),
      headers: {
        'Cookie': '${widget.accessToken}; ${widget.refreshToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> eventsJson = jsonDecode(response.body);
      return eventsJson.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  // void _showAddEventDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AddEventDialog(accessToken: widget.accessToken, refreshToken: widget.refreshToken);
  //     },
  //   );
  // }
  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEventDialog(
          accessToken: widget.accessToken, 
          refreshToken: widget.refreshToken,
          onEventAdded: () {
            setState(() {
              _futureEvents = fetchEvents(); // Aggiorna la lista degli eventi dopo l'aggiunta
            });
          },
        );
      },
    );
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEventDetailRow('Sottotitolo', event.sbtitle),
              _buildEventDetailRow('Indirizzo', event.address),
              _buildEventDetailRow('Ospite Speciale', event.specialGuest.name),
              _buildEventDetailRow('Tag', event.tags.name),
              _buildEventDetailRow('Descrizione', event.description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildEventDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8), // Aggiunge spazio tra label e value
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16), // Imposta la dimensione del testo
            ),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(Event event) async {
    showDialog(
      context: context,
      builder: (context) {
        return EditEventDialog(
          event: event,
          accessToken: widget.accessToken,
          refreshToken: widget.refreshToken,
        );
      },
    ).then((_) {
      setState(() {
        _futureEvents = fetchEvents(); // Aggiorna la lista degli eventi dopo la modifica
      });
    });
  }

  void _confirmDeleteEvent(Event event) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Conferma eliminazione'),
          content: Text('Sei sicuro di voler eliminare questo evento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = 'http://localhost:8000/events/remove/${event.slug}';
                final response = await http.delete(
                  Uri.parse(url),
                  headers: {
                    'Cookie': '${widget.accessToken}; ${widget.refreshToken}',
                  },
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Evento eliminato con successo!')),
                  );
                  setState(() {
                    _futureEvents = fetchEvents(); // Aggiorna la lista degli eventi dopo l'eliminazione
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore durante l\'eliminazione dell\'evento')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Elimina'),
            ),
          ],
        );
      },
    );
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Eventi'),
      actions: [
        TextButton.icon(
          icon: Icon(Icons.add),
          label: Text('Aggiungi Evento'),
          onPressed: _showAddEventDialog,
          style: TextButton.styleFrom(
            side: BorderSide(width: 1),
          ),
        ),
      ],
    ),
    body: FutureBuilder<List<Event>>(
      //future: _futureEvents,
      future: widget.futureEvents ?? _futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore nel caricamento degli eventi'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Non hai ancora pubblicato nessun evento', style: TextStyle(color: Colors.grey)));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Event event = snapshot.data![index];
              return GestureDetector(
                onTap: () => _showEventDetails(event),
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Indirizzo: ${event.address}'),
                              SizedBox(height: 8),
                              Text('Descrizione: ${event.description}'),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Logica per la modifica dell'evento
                                _showEditEventDialog(event);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Logica per l'eliminazione dell'evento
                                _confirmDeleteEvent(event);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    ),
  );
}

}
////Finestra PopUp di dialogo per Aggiunta Evento
class AddEventDialog extends StatefulWidget {
  final String accessToken;
  final String refreshToken;
  final Function()? onEventAdded; // Funzione di callback

  //AddEventDialog({required this.accessToken, required this.refreshToken});
  AddEventDialog({required this.accessToken, required this.refreshToken, this.onEventAdded});

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _addressController = TextEditingController();
  final _specialGuestController = TextEditingController();
  final _tagsController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://localhost:8000/events/create'),
        headers: {
          'Cookie': '${widget.accessToken}; ${widget.refreshToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'sbtitle': _subtitleController.text,
          'address': _addressController.text,
          'special_guest': {'name': _specialGuestController.text},
          'tags': {'name': _tagsController.text},
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201 ) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evento aggiunto con successo!')),
        );
        // Chiamata alla funzione di callback per aggiornare la lista degli eventi
        if (widget.onEventAdded != null) {
          widget.onEventAdded!();
        }
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella creazione dell\'evento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Aggiungi un nuovo evento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titolo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci un titolo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(labelText: 'Sottotitolo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci un sottotitolo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Indirizzo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci un indirizzo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _specialGuestController,
                decoration: InputDecoration(labelText: 'Ospite speciale'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci un ospite speciale';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(labelText: 'Tags'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci un tag';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrizione'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci una descrizione';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed:  _submitEvent,
          child: Text('Conferma'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _addressController.dispose();
    _specialGuestController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}


/////Finestra PopUp di Dialogo per modifica Evento
///
class EditEventDialog extends StatefulWidget {
  final Event event;
  final String accessToken;
  final String refreshToken;

  EditEventDialog({
    required this.event,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  _EditEventDialogState createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _addressController;
  late TextEditingController _specialGuestController;
  late TextEditingController _tagsController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _subtitleController = TextEditingController(text: widget.event.sbtitle);
    _addressController = TextEditingController(text: widget.event.address);
    _specialGuestController = TextEditingController(text: widget.event.specialGuest.name);
    _tagsController = TextEditingController(text: widget.event.tags.name);
    _descriptionController = TextEditingController(text: widget.event.description);
    print(widget.event.slug);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifica evento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titolo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Per favore, inserisci un titolo';
                  }
                  return null;
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _subtitleController,
                    decoration: InputDecoration(labelText: 'Sottotitolo'),
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Indirizzo'),
                  ),
                  TextFormField(
                    controller: _specialGuestController,
                    decoration: InputDecoration(labelText: 'Ospite speciale'),
                  ),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(labelText: 'Tags'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descrizione'),
                  ),
                ],
              ),
              
              // Aggiungi altri TextFormField per gli altri campi dell'evento
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final url = 'http://localhost:8000/events/update/${widget.event.slug}';
              //final url = 'http://localhost:8000/events/update/Evento-di-prova';
              final response = await http.put(
                Uri.parse(url),
                headers: {
                  'Cookie': '${widget.accessToken}; ${widget.refreshToken}',
                  
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'title': _titleController.text,
                  'sbtitle': _subtitleController.text,
                  'address': _addressController.text,
                  'special_guest': {'name': _specialGuestController.text},
                  'tags': {'name': _tagsController.text},
                  'description': _descriptionController.text,
                }),
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Modifica evento avvenuta con successo!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Errore durante la modifica dell\'evento')),
                );
              }
            }
          },
          child: Text('Conferma modifiche'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _addressController.dispose();
    _specialGuestController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

