// Generated by CoffeeScript 1.3.3
(function() {

  window.app = {};

  $(function() {
    app.Square = Backbone.Model.extend({
      defaults: {
        hasBeenClicked: false,
        isFlagged: false
      },
      click: function() {
        this.set({
          'hasBeenClicked': true
        });
        return this;
      },
      getID: function() {
        return parseInt(this.cid.substring(1));
      }
    });
    app.Board = Backbone.Collection.extend({
      model: app.Square,
      initialize: function(rows, cols, numMines) {
        if (rows == null) {
          rows = 8;
        }
        if (cols == null) {
          cols = 8;
        }
        if (numMines == null) {
          numMines = 10;
        }
        return this.generateSquares(rows, cols, numMines);
      },
      generateSquares: function(rows, cols, numMines) {
        var square, squares, _i, _j, _len, _ref, _results;
        squares = _.shuffle((function() {
          _results = [];
          for (var _i = 0, _ref = rows * cols - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this));
        for (_j = 0, _len = squares.length; _j < _len; _j++) {
          square = squares[_j];
          this.add(new app.Square({
            isMine: square < numMines
          }));
        }
        return this;
      },
      numClicked: function() {
        return this.size();
      }
    });
    app.board = new app.Board();
    app.SquareView = Backbone.View.extend({
      tagName: 'a',
      className: 'square',
      template: _.template($('#square_template').html()),
      attributes: {
        'href': '#'
      },
      events: {
        'click': 'click'
      },
      initialize: function() {
        return this.model.on('change', this.render, this);
      },
      render: function() {
        this.$el.html(this.template(this.model.toJSON()));
        return this;
      },
      click: function() {
        this.model.click();
        return this;
      },
      reveal: function() {
        return this;
      }
    });
    app.BoardView = Backbone.View.extend({
      id: 'board',
      template: _.template($('#board_template').html()),
      initialize: function() {
        return this.render();
      },
      render: function() {
        var _this = this;
        app.board.each(function(square, i) {
          var squareView;
          squareView = new app.SquareView({
            model: square
          });
          return _this.$el.append(squareView.render().el);
        });
        return $('#game').html(this.el);
      }
    });
    return app.boardView = new app.BoardView();
  });

}).call(this);
