% Ghost000other.oz
functor
import
   Input
export
   portPlayer:StartPlayer
define   
   StartPlayer
   TreatStream

   GetId
   AssignSpawn
   Spawn
   Move
   GotKilled
   PacmanPos
   DeathPacman
   SetMode
   ListMap
   WallList
   
in
   fun {ListMap}
      fun {ReadMap Row Column}
    if (Row > (Input.nRow)) then nil
    else
      if(Column == Input.nColumn) then 
         if({List.nth {List.nth Input.map Row} Column} == 1) then
             pt(x:Column y:Row)|{ReadMap Row+1 1}
         else
            {ReadMap Row+1 1}
         end
      else 
         if({List.nth {List.nth Input.map Row} Column} == 1) then
             pt(x:Column y:Row)|{ReadMap Row Column+1}
         else
            {ReadMap Row Column+1}
         end
      end

     
    end
      end
   in
    {ReadMap 1 1} 
     end

   fun {GetId State ?ID}
         ID = State.g
         State
   end
   fun {AssignSpawn State P}
      {AdjoinList State [p#P s#P]}
   end
   fun {Spawn State ?ID ?P}
	 if State.ob == false then
	    P = State.s
	    ID = State.g
	    {AdjoinList State [ob#true]}
	 else
	    P = null
	    ID = null
	    State
      end
   end

   fun {Move State ?ID ?P}
      fun{PacmanOn Pos} %On ne retire pas les pacman de l'état, l'état n'est pas modifié
         fun{PacmanOnLoop Pos List}
       case List of pacmans(id:_ p:P)|T then
          if(P==Pos) then true
          else {PacmanOnLoop Pos T}
          end
       []nil then false
       end
         end
      in 
         {PacmanOnLoop Pos State.pac}
      end
      proc{Find Pinit Pcurrent Res}
         Val in 
         Val = {List.nth {List.nth Input.map Pcurrent.y} Pcurrent.x}
         if(Val\= 1) then 
       if({PacmanOn Pcurrent}) then Res = Pinit
       else 
          local V1 V2 V3 V4 in
             V1 = {Find Pinit pt(x:Pcurrent.x y:{Minus Pcurrent.y-1 Input.nRow})}
             V2 = {Find Pinit pt(x:{Max Pcurrent.x+1 Input.nColumn} y:Pcurrent.y)}
             V3 = {Find Pinit pt(x:Pcurrent.x y:{Max Pcurrent.y+1 Input.nRow})}
             V4 = {Find Pinit pt(x:{Minus Pcurrent.x-1 Input.nColumn} y:Pcurrent.y)}
             Res = {Wait4 V1 V2 V3 V4 }
          end
       end
         else 
          Res =_
         end      
      end

      proc{Wait4 V1 V2 V3 V4 ?R}
         thread {Wait V1} R =V1 end
         thread {Wait V2} R=V2 end
         thread {Wait V3} R=V3 end 
         thread {Wait V4} R=V4 end
      end

      fun {TakeOutWalls Liste} 
         case Liste of H|T then 
       if({List.member H WallList}) then
          {TakeOutWalls T}
       else 
          H|{TakeOutWalls T}
       end
         []nil then nil
         end
      end   
      fun {Minus X MaxX}
         if(X < 1)
         then MaxX
         else
       X
         end
      end
      fun {Max X MaxX}
         if(X > MaxX) then 1
         else 
       X
         end
      end
   in 
      if State.ob then %Next in
         local Pcurrent in
       Pcurrent = State.p

           %Next = {TakeOutWalls [pt(x:X y:{Minus Y-1 Input.nRow}) pt(x:{Max X+1 Input.nColumn} y:Y) pt(x:X y:{Max Y+1 Input.nRow}) pt(x:{Minus X-1 Input.nColumn} y:Y)]}
       P = {Wait4 {Find pt(x:Pcurrent.x y:{Minus Pcurrent.y-1 Input.nRow}) pt(x:Pcurrent.x y:{Minus Pcurrent.y-1 Input.nRow})}
            {Find pt(x:{Max Pcurrent.x+1 Input.nColumn} y:Pcurrent.y) pt(x:{Max Pcurrent.x+1 Input.nColumn} y:Pcurrent.y)} 
            {Find pt(x:Pcurrent.x y:{Max Pcurrent.y+1 Input.nRow}) pt(x:Pcurrent.x y:{Max Pcurrent.y+1 Input.nRow})}
            {Find pt(x:{Minus Pcurrent.x-1 Input.nColumn} y:Pcurrent.y) pt(x:{Minus Pcurrent.x-1 Input.nColumn} y:Pcurrent.y)}}
       ID = State.g
       {AdjoinList State [p#P]}
         end

      else
         P = null
         ID = null
         State
      end
   end

   fun {GotKilled State}
      {AdjoinList State [ob#false]}
   end

   fun {PacmanPos State ID P}
      fun {PacmanPosLoop Pacmans ID P}
	   case Pacmans
	     of H|T then
	        if H.id == ID then {AdjoinList H [p#P]}|T
	        else H|{PacmanPosLoop T ID P}
	        end
	   [] nil then pacmans(id:ID p:P)|nil
	   end
      end
   in

   {AdjoinList State [pac#{PacmanPosLoop State.pac ID P}]}
   end


   fun {DeathPacman State ID}
      fun {DeathPacmanLoop Pacmans ID}
	     case Pacmans of pacmans(id:IDp p:Pos)|T then
	        if IDp == ID then T
	        else
	           pacmans(id:IDp p:Pos)|{DeathPacmanLoop T ID}
	        end
	     end
      end
   in
      {AdjoinList State [pac#{DeathPacmanLoop State.pac ID}]}
   end


   fun {SetMode State M}
      {AdjoinList State [m#M]}
   end
   % ID is a <ghost> ID
   fun{StartPlayer ID}
    Stream Port
   in
      {NewPort Stream Port}
      thread
         WallList = {ListMap}
	     {TreatStream Stream state(g:ID s:nil ob:false p:nil pac:nil m:classic)}
      end
      Port
   end

   proc{TreatStream Stream State} % has as many parameters as you want
      % State = state(g:Ghost s:Spawn ob:OnBoard p:Position p:Pacmans m:Mode)
      
      case Stream
      of getId(?ID)|T then {TreatStream T {GetId State ID}}
      [] move(?ID ?P)|T then {TreatStream T {Move State ID P}}
      [] assignSpawn(P)|T then {TreatStream T {AssignSpawn State P}}
      [] spawn(?ID ?P)|T then {TreatStream T {Spawn State ID P}}
      [] gotKilled()|T then {TreatStream T {GotKilled State}}
      [] pacmanPos(ID P)|T then {TreatStream T {PacmanPos State ID P}}
      [] killPacman(_)|T then {TreatStream T State} %On ne fait rien de cette info
      [] deathPacman(ID)|T then {TreatStream T {DeathPacman State ID}}
      [] setMode(M)|T then {TreatStream T {SetMode State M}}	 
      end
   end
end