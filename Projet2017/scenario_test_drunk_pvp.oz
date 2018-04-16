local
   NoBomb=false|NoBomb
in
   scenario(bombLatency:3
	    walls:true
	    step: 0
	    snakes: [
		     snake(team:yellow name:gordon
			   positions: [pos(x:4 y:3 to:east) pos(x:3 y:3 to:east) pos(x:2 y:3 to:east)]
			   effects: nil
			   strategy: keyboard(left:'Left' right:'Right' intro:nil)
			   bombing: NoBomb
			  )
		    ]
	    bonuses: [
		      bonus(position:pos(x:6 y:6) color:orange effect:drunk(x:17 y:17) target:catcher)
			   ]
		      bombs: nil
		     )
	   end
