traces=/tmp/traces
radio=USRP_B210
radioaddr=""
target=/dev/ttyACM0

# If there is a memory leak using the --plot option, then change the NFFT size
# of the plt.specgram function in the analyze.py file from Screaming Channels to 256:
# plt.specgram(
#     data, NFFT=256, Fs=config.sampling_rate, Fc=0, detrend=mlab.detrend_none,
plot() {
	sc-experiment \
    	--radio=$radio --radio-address=$radioaddr --device=$target \
    	collect --plot /docker/config/plot.json $traces
    # plot.json = example_collection_plot.json
}

collect() {
	sc-experiment \
    	--radio=$radio --radio-address=$radioaddr --device=$target \
    	collect /docker/config/collect.json $traces
    # collect.json = example_collection_attack.json
}

mkdir -p $traces
$@
