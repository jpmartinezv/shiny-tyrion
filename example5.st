def f () {
	def x = 1
	lambda () {x + 1}
}

def x = 0 

print ?f()
