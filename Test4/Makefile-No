all : Input.oz PlayerManager.oz GUI.oz Main.oz Pacman093other.oz Ghost093other.oz
	ozc -c Input.oz
	ozc -c PlayerManager.oz
	ozc -c Pacman093other.oz
	ozc -c Ghost093other.oz
	ozc -c GUI.oz
	ozc -c Main.oz
	ozengine Main.ozf

test4 : Input.oz PlayerManager.oz GUI.oz Main.oz Pacman093other.oz Ghost093other.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c PlayerManager.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Pacman093other.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Ghost093other.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Main.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf


clear:
	rm Input.ozf
	rm Input.ozf
	rm PlayerManager.ozf
	rm Main.ozf
	rm GUI.ozf
