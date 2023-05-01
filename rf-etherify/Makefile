help:
	$(info make display-morse)
	$(info test-leak-on)
	$(info test-leak-off)
	$(info transmit-secret)
	$(info receive-secret)

display-morse:
	cat secret.txt
	./text2morse.sh $$(cat secret.txt)

test-leak-on:
	sudo ethtool -s enp0s31f6 autoneg off duplex full speed 100

test-leak-off:
	sudo ethtool -s enp0s31f6 autoneg off duplex full speed 10

transmit-secret:
	sudo ./etherify4.sh secret.txt

receive-secret:
	gqrx -r
	$(info Tune gain to maximum)
	$(info Tune center frequency around 125 Mhz)
	$(info Use 200 KS of sample rate and 200 kH of bandwidth)
	$(info Use CW-U mode)
