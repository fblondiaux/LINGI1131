all : Input.oz PlayerManager.oz GUI.oz Main.oz Ghost000random.ozf Pacman000random.ozf
	ozc -c Input.oz
	ozc -c PlayerManager.oz
	ozc -c GUI.oz
	ozc -c Main.oz
	ozengine Main.ozf
test: Input.ozf PlayerManager.ozf GUI.ozf Main.oz Ghost000random.ozf Pacman000random.ozf
		ozc -c Main.oz
		ozengine Main.ozf
clear:
	rm Input.ozf
	rm PlayerManager.ozf
	rm Main.ozf
	rm GUI.ozf
