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

		numSurroundingMines: ()->
			surroundingSquares = @surroundingSquares()
			count = 0
			_.each surroundingSquares, (id)=>
				if id and @collection.getByCid("c#{id}").get('isMine')
					count++
			console.log count
			count

		surroundingSquares: ()->
			cid = @getID()
			rows = @collection.rows
			cols = @collection.cols
			
			left   = if cid % rows == 0          then undefined else cid-1
			right  = if cid % rows == rows-1     then undefined else cid + 1
			top    = if cid - cols < 0           then undefined else cid-cols
			bottom = if cid + cols > rows*cols-1 then undefined else cid+cols


			topLeft     = if left  and top    then top-1    else undefined
			topRight    = if right and top    then top+1    else undefined
			bottomLeft  = if left  and bottom then bottom-1 else undefined
			bottomRight = if right and bottom then bottom+1 else undefined

			{
				left: left
				right: right
				top: top
				bottom: bottom
				topLeft: topLeft
				topRight: topRight
				bottomLeft: bottomLeft
				bottomRight: bottomRight
			}

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
			@$el.html(@template(@model.toJSON())).text(@model.getID())
			this

		click: ()->
			event.preventDefault()
			@model.click()
			@reveal()
			this

		reveal: ()->
			if @model.get('isMine')
			else
				numSurroundingMines = @model.numSurroundingMines()
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
