declare Revert Snake
local
   fun {DoRevert H T}
      case H of nil then T
      [] X|Xr then case X.to of
		      north then {DoRevert Xr pos(to:south x:X.x y:X.y)|T}
		   []  south then {DoRevert Xr pos(to:north x:X.x y:X.y)|T}
		   []  east then {DoRevert Xr pos(to:west x:X.x y:X.y)|T}
		   []  west then {DoRevert Xr pos(to:east x:X.x y:X.y)|T}
		   end
      end
   end
in
   fun {Revert H} {DoRevert H nil} end
end


Snake = snake(positions:[pos(x:4 y:2 to:east) pos(x:3 y:2 to:east) pos(x:2 y:2 to:east)] effects:nil)
{Browse Snake}
{Browse snake(positions:{Revert Snake.positions} effects:nil)}
