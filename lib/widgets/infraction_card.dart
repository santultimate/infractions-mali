import 'package:flutter/material.dart';
import '../models/infraction.dart';

Color _getClasseColor(String? classe) {
  switch (classe) {
    case '2ème':
      return Colors.blue;
    case '3ème':
      return Colors.orange;
    case '4ème':
      return Colors.red;
    case 'Délit':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

class InfractionCard extends StatelessWidget {
  final Infraction infraction;

  const InfractionCard({required this.infraction, required void Function() onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 3,
      child: ListTile(
        title: Text(
          infraction.infraction,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((infraction.classe ?? '').isNotEmpty)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Icon(
                    Icons.label,
                    color: _getClasseColor(infraction.classe),
                    size: 18,
                  ),
                  Text(
                    'Classe : ${infraction.classe}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getClasseColor(infraction.classe),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            if (infraction.texte.isNotEmpty)
              Text('Texte : ${infraction.texte}'),
            if ((infraction.extrait ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Extrait du code :\n${infraction.extrait}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
          ],
        ),
        trailing: Container(
          constraints: BoxConstraints(maxWidth: 100),
          child: Text(
            infraction.amende,
            style: TextStyle(
              color: infraction.amende.toLowerCase().contains('interdiction')
                  ? Colors.red
                  : Colors.green,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(infraction.infraction),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((infraction.classe ?? '').isNotEmpty)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.label,
                          color: _getClasseColor(infraction.classe),
                          size: 18,
                        ),
                        Text(
                          'Classe : ${infraction.classe}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getClasseColor(infraction.classe),
                          ),
                        ),
                      ],
                    ),
                  if (infraction.texte.isNotEmpty)
                    Text('Texte : ${infraction.texte}'),
                  if (infraction.amende.isNotEmpty)
                    Text('Amende : ${infraction.amende}'),
                  if ((infraction.extrait ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Extrait du code :\n${infraction.extrait}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Fermer"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
