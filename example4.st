def iter() {
	def i = 0
	lambda () {
		if (i < 10) {
			i := i + 1
			i
		} else {
			null    
		}
	} 
}
for (x in ?iter()) {     
	print x 
}
