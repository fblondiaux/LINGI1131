local
   NoBomb=false|NoBomb
in
   scenario(bombLatency:3
	    walls:true
	    step: 0
	    snakes: [
		     snake(team:yellow name:jason
			   positions: [pos(x:4 y:3 to:east) pos(x:3 y:3 to:east) pos(x:2 y:3 to:east)]
			   effects: nil
			   strategy: keyboard(left:'Left' right:'Right' intro:nil)
			   bombing: NoBomb
			  )
		     snake(team:green name:steve
			   positions: [pos(x:19 y:20 to:west) pos(x:20 y:20 to:west) pos(x:21 y:20 to:west)]
			   effects: nil
			   strategy: keyboard(left:q right:d intro:nil)
			   bombing: NoBomb
			  )
		    ]
	    bonuses: [
		      bonus(position:pos(x:5 y:3) color:blue effect:tron target:catcher)
		      bonus(position:pos(x:18 y:20) color:blue effect:tron target:catcher)
			   ]
		      bombs: nil
		     )
	   end
