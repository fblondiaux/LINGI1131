all : Input.oz PlayerManager.oz GUI.oz Main.oz Pacman093other.oz Ghost093other.oz
	ozc -c Input.oz
	ozc -c PlayerManager.oz
	ozc -c Pacman093other.oz
	ozc -c Ghost093other.oz
	ozc -c GUI.oz
	ozc -c Main.oz
	ozengine Main.ozf


clear:
	rm Input.ozf
	rm PlayerManager.ozf
	rm Main.ozf
	rm GUI.ozf
