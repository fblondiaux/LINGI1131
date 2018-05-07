all : Input.oz PlayerManager.oz GUI.oz Main.oz Pacman093other.oz Ghost093other.oz
	ozc -c Input.oz
	ozc -c PlayerManager.oz
	ozc -c Pacman093other.oz
	ozc -c Ghost093other.oz
	ozc -c GUI.oz
	ozc -c Main.oz
	ozengine Main.ozf
test1: InputTest1.oz PlayerManager.ozf GUITest1.oz MainTest1.oz Pacman093otherTest1.ozf Ghost093otherTest1.ozf
	ozc -c InputTest1.oz
	ozc -c Pacman093otherTest1.oz
	ozc -c Ghost093otherTest1.oz
	ozc -c GUITest1.oz
	ozc -c MainTest1.oz
test2: InputTest2.oz PlayerManager.ozf GUI.ozf Main.ozf Pacman093other.ozf Ghost093other.ozf
	ozc -c InputTest1.oz
	ozc -c Main.oz
	ozengine Main.ozf


clear:
	rm Input.ozf
	rm PlayerManager.ozf
	rm Main.ozf
	rm GUI.ozf
