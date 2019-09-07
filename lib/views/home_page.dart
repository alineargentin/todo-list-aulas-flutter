import 'dart:developer';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:todo_list/helpers/task_helper.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/views/task_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> _taskList = [];
  TaskHelper _helper = TaskHelper();
  bool _loading = true;
  int _doneTasksCount = 0;

  @override
  void initState() {
    super.initState();
    _helper.getAll().then((list) {
      // quando ele retornar uma informação entao...
      setState(() {
        _taskList = list;
        _loading = false;
        _doneTasksCount = 0;
        for (Task task in _taskList) {
          if (task.isDone) {
            _doneTasksCount++;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        actions: <Widget>[
          // Adicionar um PercentIndicator circular na barra de navegação para
          // indicar a porcentagem de tarefas concluídas

          CircularPercentIndicator(
            radius: 48.0,
            lineWidth: 5.0,
            percent: _doneTasksCount /
                _taskList
                    .length, // qtde de tasks feitas dividido pelo tamanho da lista
            center: new Text(
                "${((_doneTasksCount / _taskList.length) * 100).toStringAsPrecision(3)}%",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            progressColor: Colors.white,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: _addNewTask), //botao
      body: _buildTaskList(),
    );
  }

  Widget _buildTaskList() {
    if (_taskList.isEmpty) {
      // a lista esta vazia
      return Center(
        child: _loading
            ? CircularProgressIndicator()
            : Text(
                "Sem tarefas!"), // esta carregando alguma coisa - fica um circulo carregando
      );
    } else {
      // Na lista de tarefas, adicionar divisões entre as linhas
      return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: _buildTaskItemSlidable, //constroi a lista
        itemCount: _taskList.length, //quantidade itens na lista
      );
    }
  }

//construção de cada item "slidable"
  Widget _buildTaskItem(BuildContext context, int index) {
    final task = _taskList[index];
    return CheckboxListTile(
      value: task.isDone, //falso ou true
      title: Text(task.title),
      subtitle: Text(task.description),
      onChanged: (bool isChecked) {
        setState(() {
          task.isDone = isChecked; // pertence a interface
          if (isChecked) {
            _doneTasksCount++;
          } else {
            _doneTasksCount--;
          }
        });

        _helper.update(task); // atualiza a base de dados com o novo valor
      },
    );
  }

//
  Widget _buildTaskItemSlidable(BuildContext context, int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25, //porcentagem de quanto cada botao ocupa na area
      child: _buildTaskItem(context, index),
      actions: <Widget>[
        IconSlideAction(
          //esquerda para direita ou direita para esquerda
          caption: 'Editar', // botao
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            _addNewTask(editedTask: _taskList[index], index: index);
          },
        ),
        IconSlideAction(
          caption: 'Excluir', //botao excluir
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deleteTask(deletedTask: _taskList[index], index: index);
          },
        ),
      ],
    );
  }

//para adicionar - deixar a tela modal
  Future _addNewTask({Task editedTask, int index}) async {
    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {
      setState(() {
        if (index == null) {
          _taskList.add(task);
          _helper.save(task);
        } else {
          _taskList[index] = task;
          _helper.update(task);
        }
      });
    }
  }

//botao remover
  void _deleteTask({Task deletedTask, int index}) {
    setState(() {
      if (_taskList[index].isDone) {
        // se a task removida estiver concluída, atualiza o estado
        _doneTasksCount--;
      }
      _taskList.removeAt(index);
    });

    _helper.delete(deletedTask.id);

    Flushbar(
      title: "Exclusão de tarefas",
      message: "Tarefa \"${deletedTask.title}\" removida.",
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      mainButton: FlatButton(
        child: Text(
          "Desfazer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            _taskList.insert(index, deletedTask); // reinsiro na lista
            _helper.update(deletedTask);
          });
        },
      ),
    )..show(context);
  }
}
