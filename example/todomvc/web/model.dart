// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library model;

import 'dart:html' show CompoundBinding;
import 'package:observe/observe.dart';
import 'package:web_ui/web_ui.dart';

final appModel = new AppModel._();

class AppModel extends ObservableBase {
  final ObservableList<Todo> todos = new ObservableList<Todo>();
  @observable int doneCount;
  @observable int remaining;
  @observable List<Todo> visibleTodos;
  @observable bool hasTodos;
  @observable bool hasCompleteTodos;

  bool _allChecked;

  AppModel._() {
    // TODO(jmesserly): need to make this easier.
    new ListPathObserver(todos, 'done').changes.listen(_updateTodoDone);
    windowLocation.changes.listen(_updateVisibleTodos);
    _updateTodoDone(null);
  }

  _updateTodoDone(_) {
    doneCount = todos.fold(0, (count, t) => count + (t.done ? 1 : 0));
    hasCompleteTodos = doneCount > 0;
    remaining = todos.length - doneCount;
    hasTodos = todos.length > 0;

    _allChecked = notifyPropertyChange(const Symbol('allChecked'),
        _allChecked, hasTodos && remaining == 0);

    _updateVisibleTodos(_);
  }

  _updateVisibleTodos(_) {
    bool filterDone = null;
    if (windowLocation.hash == '#/completed') {
      filterDone = true;
    } else if (windowLocation.hash == '#/active') {
      filterDone = false;
    }

    // TODO(jmesserly): the filter should be stable.
    visibleTodos = todos.where(
        (t) => filterDone == null || t.done == filterDone)
        .toList(growable: false);
  }

  // TODO(jmesserly): the @observable here is temporary.
  bool get allChecked => _allChecked;
  set allChecked(bool value) {
    todos.forEach((t) { t.done = value; });
  }

  void clearDone() => todos.removeWhere((t) => t.done);
}

class Todo extends ObservableBase {
  @observable String task;
  @observable bool done = false;

  Todo(this.task);

  String toString() => "$task ${done ? '(done)' : '(not done)'}";
}