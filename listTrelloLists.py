from trello import TrelloClient
import os

trello = TrelloClient(os.environ['TRELLO_API_KEY'], os.environ['TRELLO_TOKEN'])
boards = trello.list_boards()
for board in boards:
	print "Board {} ({}) lists:".format(board.name, board.id)
	lists = board.all_lists()
	for l in lists:
		print "\t- {}: {}".format(l.name, l.id)

