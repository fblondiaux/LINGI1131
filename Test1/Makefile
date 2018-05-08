all : run

%.ozf: %.oz
	ozc -c $<
run: Input.ozf PlayerManager.ozf GUI.ozf Main.ozf Pacman093other.ozf Ghost093other.ozf
	ozengine Main.ozf

clear:
	rm Input.ozf
	rm PlayerManager.ozf
	rm Main.ozf
	rm GUI.ozf
