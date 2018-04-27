all : Input.oz PlayerManager.oz GUI.oz Main.oz Ghost000random.ozf Pacman000random.ozf
	ozc -c Input.oz
	ozc -c PlayerManager.oz
	ozc -c GUI.oz
	ozc -c Main.oz
	ozengine Main.ozf
	
	# Pour le mac de Nono : 
	#/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz
	#/Applications/Mozart2.app/Contents/Resources/bin/ozc -c PlayerManager.oz
	#/Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz
	#/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Main.oz
	#/Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf

test: Input.ozf PlayerManager.ozf GUI.ozf Main.oz Ghost000random.ozf Pacman000random.ozf
		ozc -c Main.oz
		ozengine Main.ozf

		# Pour le mac de Nono : 
		#/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Main.oz
		#/Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf
ghost: Input.ozf PlayerManager.ozf GUI.ozf Main.oz Ghost000other.oz Pacman000other.oz
		#ozc -c Ghost000other.oz
		ozc -c Pacman000other.oz
		ozc -c Main.oz
		ozengine Main.ozf

clear:
	rm Input.ozf
	rm PlayerManager.ozf
	rm Main.ozf
	rm GUI.ozf
