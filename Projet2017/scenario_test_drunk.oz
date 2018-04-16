local
   NoBomb=false|NoBomb
in
   scenario(bombLatency:3
	    walls:true
	    step: 0
	    snakes: [
		     snake(team:red name:gordon
			   positions: [pos(x:14 y:11 to:east) pos(x:13 y:11 to:east) pos(x:12 y:11 to:east)]
			   effects: nil
			   strategy: [forward turn(right) turn(left) turn(left) turn(left) turn(left) turn(left)]
			   bombing: NoBomb
			  )
		    ]
	    bonuses: [
		    bonus(position:pos(x:15 y:11) color:black effect:drunk target:catcher)
	    ]
	    bombs: nil
	   )
end
