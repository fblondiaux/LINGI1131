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
		     snake(team:green name:steve
			   positions: [pos(x:8 y:12 to:east) pos(x:7 y:12 to:east) pos(x:6 y:12 to:east)]
			   effects: nil
			   strategy: [forward forward forward forward forward forward forward]
			   bombing: NoBomb
			  )
		     snake(team:red name:patrick
			   positions: [pos(x:13 y:9 to:south) pos(x:13 y:8 to:south) pos(x:13 y:7 to:south)]
			   effects: nil
			   strategy: [forward forward forward forward forward]
			   bombing: NoBomb
			  )
		    ]
	    bonuses: [
		    bonus(position:pos(x:15 y:11) color:green effect:grow target:catcher)
	    ]
	    bombs: nil
	   )
end