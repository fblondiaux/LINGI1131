all : run

%.ozf: %.oz
	ozc -c $<
run: Input.ozf PlayerManager.ozf GUI.ozf Pacman093other.ozf Pacman060other.ozf Pacman047basic.ozf Pacman018random.ozf Ghost018random.ozf Ghost047basic.ozf Ghost060other.ozf Ghost093other.ozf Main.ozf
	ozengine Main.ozf

clear:
	rm Input.ozf
	rm PlayerManager.ozf
	rm Main.ozf
	rm GUI.ozf
