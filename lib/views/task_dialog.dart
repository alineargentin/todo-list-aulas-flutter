import 'package:flutter/material.dart';
import 'package:todo_list/models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

//codigo de tela
class _TaskDialogState extends State<TaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _priorityDropdownValue = 1;

  Task _currentTask = Task();

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _currentTask = Task.fromMap(widget.task.toMap());
    }

    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
    _priorityDropdownValue = _currentTask.priority;
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefas'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
              autofocus: true,
              validator: (String value) {
                // Adicionar validações no cadastro de uma atividade (lembre-se que é preciso utilizar o widget TextFormField para isso)
                return value.isEmpty ? 'O título é obrigatório' : null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
              // Campo descrição precisar aceitar múltiplas linhas
              keyboardType: TextInputType.multiline,
              maxLines: null,
              validator: (String value) {
                return value.isEmpty ? 'A descrição é obrigatória' : null;
              },
            ),
            // Criar um campo para nível de prioridades que aceita valores entre 1
            // (baixa prioridade) e 5 (alta prioridade).
            // Representar isso no card da forma como achar mais interessante.
            SizedBox(
              // Sized Box para largura ficar igual dos campos de texto
              width: double.infinity,
              child: DropdownButton<int>(
                value: _priorityDropdownValue,
                onChanged: (int newValue) {
                  setState(() {
                    _priorityDropdownValue = newValue;
                  });
                },
                items: <int>[1, 2, 3, 4, 5]
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("Prioridade: " + value.toString()),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Salvar'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _currentTask.title = _titleController.value.text;
              _currentTask.description = _descriptionController.text;
              _currentTask.priority = _priorityDropdownValue;

              Navigator.of(context).pop(
                  _currentTask); //fecha a tela - e devolve a tela (task) coloca na lista e/ou pode salvar numa bade de dados
            }
          },
        ),
      ],
    );
  }
}
