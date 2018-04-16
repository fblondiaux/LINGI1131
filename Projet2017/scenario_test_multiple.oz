local
   NoBomb=false|NoBomb
in
   scenario(bombLatency:3
	    walls:true
	    step: 0
	    snakes: [
		     snake(team:red name:gordon
			   positions: [pos(x:11 y:13 to:west) pos(x:12 y:13 to:west) pos(x:13 y:13 to:west) pos(x:14 y:13 to:west) pos(x:14 y:12 to:south) pos(x:14 y:11 to:south) pos(x:13 y:11 to:east) pos(x:12 y:11 to:east) pos(x:11 y:11 to:east)]
			   effects: nil
			   strategy: keyboard(left:'Left' right:'Right' intro:nil)
			   bombing: NoBomb
			  )
		    ]
	    bonuses: [
		    bonus(position:pos(x:13 y:12) color:orange effect:teleport(x:8 y:13) target:catcher)
		    bonus(position:pos(x:8 y:13) color:orange effect:[grow teleport(x:13 y:12)] target:catcher)
	    ]
	    bombs: nil
	   )
end
