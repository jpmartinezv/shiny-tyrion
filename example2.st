def fac(n) {
	if (n <= 1) {
		1
	} else {
		n * ?fac(n-1)
	}
} 

print ?fac(4)
