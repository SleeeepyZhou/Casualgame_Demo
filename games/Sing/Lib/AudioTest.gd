extends Node

const RISE = 2 ** (1.0/12.0)
const C0 = 27.5 * (RISE ** 3.0)
var alist : PackedFloat64Array = [C0]
var nlist : PackedStringArray = ["C0"]

func _ready():
	for i in range(12*8-1):
		alist.append(alist[i]*RISE)
		if i:
			nlist.append(Readcsv.PName[i%12] + str(int(i/12)))
	nlist.append("B7")
	
	spectrum = AudioServer.get_bus_effect_instance(1,0)
	var effect = AudioServer.get_bus_effect(1,0)
	effect.set_fft_size(AudioEffectSpectrumAnalyzer.FFT_SIZE_4096)
	
	#playback = $AudioStreamPlayer.get_stream_playback()
	#fill_buffer()

var spectrum : AudioEffectSpectrumAnalyzerInstance
var pitch : Array = ["", 69.0]

func _on_timer_timeout():
	var maxen : float = 0
	var maxindex : int = 0
	var T : PackedFloat64Array = []
	for i in range(500, 40000):
		var prev_hz : float = i / 10
		var hz : float = i / 10 + 0.1
		var tma = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, 0)
		var magnitude: float = (tma.x + tma.y)/2
		T.append(magnitude*10000)
		if magnitude > maxen:
			maxen = magnitude
			maxindex = i
	var endT : float = maxindex / 10
	var note = 12 * (log(endT/440.0) / log(2)) + 69.0
	pitch = [Readcsv.PName[int(round(note))%12], note]
	
	#var maturity = ""
	#if maxindex > 1648:
		#maturity = "NoNoNo"
	#elif maxindex >= 1300 and maxindex <= 1648:
		#maturity = "OK!"
	#elif maxindex < 1300:
		#maturity = "Out"
	#print(maturity, maxindex)

#var playback # 存放 AudioStreamGeneratorPlayback。
#@onready var sample_hz = $AudioStreamPlayer.stream.mix_rate
#var pulse_hz = 440.0 # 声音波形的频率。
#
#func fill_buffer():
	#var phase = 0.0
	#var increment = pulse_hz / sample_hz
	#var frames_available = playback.get_frames_available()
#
	#for i in range(frames_available):
		#playback.push_frame(Vector2.ONE * sin(phase * TAU))
		#phase = fmod(phase + increment, 1.0)

