game = {
	announceWin: ()->
		$('#announcement').addClass('alert-box success').text('You won!')

	announceLoss: ()->
		$('#announcement').addClass('alert-box alert').text('You lost!')

	resetAnnouncement: ()->
		$('#announcement').removeAttr('class').text('')
}

$ ()->
	newGame = ()->
		game.resetAnnouncement()

		game.Square = Backbone.Model.extend {
			defaults: {
				hasBeenClicked: false
				isFlagged: false
			}

			click: ()->
				@set({'hasBeenClicked': true})
				this

			flag: ()->
				@set({'isFlagged': true})
				console.log 'wtf'
				this

			numSurroundingMines: ()->
				mines = _.filter @surroundingSquares(), (id)=>
					@collection.at(id).get('isMine')

				mines.length

			surroundingSquares: ()->
				rows = @collection.rows
				cols = @collection.cols

				squares = []
				
				left   = if @id % rows == 0          then undefined else @id-1
				right  = if @id % rows == rows-1     then undefined else @id + 1
				top    = if @id - cols < 0           then undefined else @id-cols
				bottom = if @id + cols > rows*cols-1 then undefined else @id+cols

				topLeft     = if left  and top    then top-1    else undefined
				topRight    = if right and top    then top+1    else undefined
				bottomLeft  = if left  and bottom then bottom-1 else undefined
				bottomRight = if right and bottom then bottom+1 else undefined

				squares = [left, right, top, bottom, topLeft, topRight, bottomLeft, bottomRight]
				squares.filter (square)->
					square != undefined
		}

		game.Board = Backbone.Collection.extend {
			model: game.Square

			initialize: (@rows=8, @cols=8, @numMines=10)->
				@gameOver = false
				@lost = false
				@generateSquares(@rows, @cols, @numMines)

			generateSquares: (rows, cols, numMines)->
				squares = _.shuffle([0..rows*cols-1])
				for square, i in squares
					@add new game.Square {
						isMine: square < numMines
						id: i
					}
				this

			numClicked: ()->
				@size()

			hitMine: ()->
				@gameOver = true
				@lost = true
				_.each @models, (square)->
					square.click()
				game.announceLoss()

			checkIfWon: ()->
				won = not @lost and _.all @models, (square)->
					(square.get('isMine') and not square.get('hasBeenClicked')) or
					(not square.get('isMine') and square.get('hasBeenClicked'))
				if won
					@gameOver = true
					game.announceWin()
		}

		game.board = new game.Board()

		game.SquareView = Backbone.View.extend {

			tagName: 'a'
			className: 'center square'
			template: _.template($('#square_template').html())

			attributes: {
				'href': '#'
				'oncontextmenu': 'return false;'
			}

			events: {
				'mousedown': 'click'
			}

			initialize: ()->
				@model.on('change', @render, @)
				@model.on('change', @model.collection.checkIfWon, @model.collection)

			render: ()->
				@$el.html(@template(@model.toJSON()))
				if @model.get('hasBeenClicked')
					@$el.addClass('clicked')
					@reveal()
				else if @model.get('isFlagged')
					@$el.addClass('flagged')
				this

			click: ()->
				event.preventDefault()
				switch event.which
					when 1 then @model.click()
					when 3 then @model.flag()
				this

			reveal: ()->
				@$el.removeClass('flagged')
				if @model.get('isMine')
					@$el.addClass('mine')
					if not game.board.gameOver
						game.board.hitMine()
				else
					numSurroundingMines = @model.numSurroundingMines()
					@$el.text(numSurroundingMines)
					if numSurroundingMines == 0
						_.each @model.surroundingSquares(), (id)=>
							square = @model.collection.at(id)
							if not square.get('isMine') and not square.get('hasBeenClicked')
								square.click()
				this

		}

		game.BoardView = Backbone.View.extend {

			id: 'board'
			template: _.template($('#board_template').html())

			initialize: ()->
				@render()

			render: ()->
				game.board.each (square)=>
					squareView = new game.SquareView {
						model: square
					}

					@$el.append(squareView.render().el)

				$('#game').html(@el)

		}

		game.boardView = new game.BoardView()
	
	$('#new_game_button').on('click', newGame)
	newGame()
