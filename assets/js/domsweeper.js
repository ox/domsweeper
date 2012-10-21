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
      },
      numSurroundingMines: function() {
        var mines,
          _this = this;
        mines = _.filter(this.surroundingSquares(), function(id) {
          return _this.collection.getByCid("c" + id).get('isMine');
        });
        return mines.length;
      },
      surroundingSquares: function() {
        var bottom, bottomLeft, bottomRight, cid, cols, left, right, rows, squares, top, topLeft, topRight;
        cid = this.getID();
        rows = this.collection.rows;
        cols = this.collection.cols;
        squares = [];
        left = cid % rows === 0 ? void 0 : cid - 1;
        right = cid % rows === rows - 1 ? void 0 : cid + 1;
        top = cid - cols < 0 ? void 0 : cid - cols;
        bottom = cid + cols > rows * cols - 1 ? void 0 : cid + cols;
        topLeft = left && top ? top - 1 : void 0;
        topRight = right && top ? top + 1 : void 0;
        bottomLeft = left && bottom ? bottom - 1 : void 0;
        bottomRight = right && bottom ? bottom + 1 : void 0;
        squares = [left, right, top, bottom, topLeft, topRight, bottomLeft, bottomRight];
        return squares.filter(function(square) {
          return square !== void 0;
        });
      }
    });
    app.Board = Backbone.Collection.extend({
      model: app.Square,
      initialize: function(rows, cols, numMines) {
        this.rows = rows != null ? rows : 8;
        this.cols = cols != null ? cols : 8;
        this.numMines = numMines != null ? numMines : 10;
        return this.generateSquares(this.rows, this.cols, this.numMines);
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
      className: 'center square',
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
        if (this.model.get('hasBeenClicked')) {
          this.$el.addClass('clicked');
          this.reveal();
        }
        return this;
      },
      click: function() {
        event.preventDefault();
        this.model.click();
        return this;
      },
      reveal: function() {
        var numSurroundingMines,
          _this = this;
        if (this.model.get('isMine')) {
          this.$el.text('DEAD');
        } else {
          numSurroundingMines = this.model.numSurroundingMines();
          this.$el.text(numSurroundingMines);
          if (numSurroundingMines === 0) {
            _.each(this.model.surroundingSquares(), function(id) {
              var square;
              square = _this.model.collection.getByCid("c" + id);
              if (!square.get('isMine') && !square.get('hasBeenClicked')) {
                return square.click();
              }
            });
          }
        }
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
        app.board.each(function(square) {
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
