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
			   strategy: [forward forward forward]
			   bombing: NoBomb
			  )
		     snake(team:green name:steve
			   positions: [pos(x:12 y:12 to:east) pos(x:11 y:12 to:east) pos(x:10 y:12 to:east)]
			   effects: nil
			   strategy: [forward turn(right) turn(right) repeat([forward] times:20)]
			   bombing: NoBomb
			  )
		     snake(team:red name:patrick
			   positions: [pos(x:7 y:10 to:north) pos(x:7 y:11 to:north) pos(x:7 y:12 to:north)]
			   effects: nil
			   strategy: [forward forward forward forward]
			   bombing: NoBomb
			  )
		    ]
	    bonuses: [
		    bonus(position:pos(x:13 y:12) color:orange effect:teleport(x:8 y:13) target:catcher)
		    bonus(position:pos(x:8 y:13) color:orange effect:teleport(x:13 y:12) target:catcher)
		    bonus(position:pos(x:7 y:8) color:peru effect:teleport(x:7 y:16) target:catcher)
		    bonus(position:pos(x:7 y:16) color:peru effect:teleport(x:7 y:8) target:catcher)
	    ]
	    bombs: nil
	   )
end