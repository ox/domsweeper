window.app = {}

$ ()->
	app.Square = Backbone.Model.extend {
		defaults: {
			hasBeenClicked: false
			isFlagged: false
		}

		click: ()->
			@set({'hasBeenClicked': true})
			this

		getID: ()->
			parseInt(@cid.substring(1))
	}

	app.Board = Backbone.Collection.extend {
		model: app.Square

		initialize: (@rows=8, @cols=8, @numMines=10)->
			@generateSquares(@rows, @cols, @numMines)

		generateSquares: (rows, cols, numMines)->
			squares = _.shuffle([0..rows*cols-1])
			for square in squares
				@add new app.Square {
					isMine: square < numMines
				}
			this

		numClicked: ()->
			@size()

	}

	app.board = new app.Board()

	app.SquareView = Backbone.View.extend {

		tagName: 'a'
		className: 'square'
		template: _.template($('#square_template').html())

		attributes: {
			'href': '#'
		}

		events: {
			'click': 'click'
		}

		initialize: ()->
			@model.on('change', @render, @)

		render: ()->
			@$el.html(@template(@model.toJSON()))
			this

		click: ()->
			@model.click()
			this

		reveal: ()->
			this
	}

	app.BoardView = Backbone.View.extend {

		id: 'board'
		template: _.template($('#board_template').html())

		initialize: ()->
			@render()

		render: ()->
			app.board.each (square)=>
				squareView = new app.SquareView {
					model: square
				}

				@$el.append(squareView.render().el)

			$('#game').html(@el)


	}

	app.boardView = new app.BoardView()
