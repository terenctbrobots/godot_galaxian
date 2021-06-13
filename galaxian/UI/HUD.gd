extends CanvasLayer

func message(message):
	$Message.text = message
	
func show():
	$Message.show()
	
func hide():
	$Message.hide()
	
func score(score):
	$Score.text = str(score)
	
func lives(lives):
	$Lives.text = str(lives)
