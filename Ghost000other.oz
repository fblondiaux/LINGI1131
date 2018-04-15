% Ghost000other.oz
functor
import
   Input
   Browser
   OS
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
   KillPacman
   DeathPacman
   SetMode
   
in
   fun {GetId State ID}
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 ID = Ghost
	 state
      end
   end
   fun {AssignSpawn State P}
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 state(g:Ghost s:P ob:OnBoard p:Position pac:Pacmans m:Mode)
      end
   end
   fun {Spawn State ID P}
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 if OnBoard == false then
	    P = Spawn
	    ID = Ghost
	    state(g:Ghost s:Spawn ob:true p:Spawn pac:Pacmans m:Mode)
	 else
	    P = null
	    ID = null
	    State
	 end
      end
   end
   fun {Move State ID P}
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 if OnBoard then Next in
	    Next = ({OS.rand} mod 4)+1
	    case Next#P
	    of 1#pt(x:X y:Y) then
	       P = pt(x:X y:Y-1)
	       ID = Ghost
	       state(g:Ghost s:Spawn ob:OnBoard p:P pac:Pacmans m:Mode)
	    [] 2#pt(x:X y:Y) then
	       P = pt(x:X+1 y:Y)
	       ID = Ghost
	       state(g:Ghost s:Spawn ob:OnBoard p:P pac:Pacmans m:Mode)
	    [] 3#pt(x:X y:Y) then
	       P = pt(x:X y:Y+1)
	       ID = Ghost
	       state(g:Ghost s:Spawn ob:OnBoard p:P pac:Pacmans m:Mode)
	    [] 4#pt(x:X y:Y) then
	       P = pt(x:X-1 y:Y)
	       ID = Ghost
	       state(g:Ghost s:Spawn ob:OnBoard p:P pac:Pacmans m:Mode)
	    end
	 else
	    P = null
	    ID = null
	    State
	 end
      end
   end
   fun {GotKilled State}
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 state(g:Ghost s:Spawn ob:false p:Position pac:Pacmans m:Mode)
      end
   end
   fun {PacmanPos State ID P}
      fun {PacmanPosLoop Pacmans ID P}
	 case Pacmans
	 of pacmans(id:IDg p:Position)|T then
	    if IDg == ID then pacmans(id:IDg p:P)|T
	    else pacmans(id:IDg p:Position)|{PacmanPosLoop T ID P}
	    end
	 [] nil then pacmans(id:ID p:P)|nil
	 end
      end
   in
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 state(g:Ghost s:Spawn ob:OnBoard p:Position pac:{PacmanPosLoop Pacmans ID P} m:Mode)
      end
   end
   fun {DeathPacman State ID}
      fun {DeathPacmanLoop Pacmans ID}
	 case Pacmans
	 of pacmans(id:IDp p:P)|T then
	    if IDp == ID then T
	    else
	       pacmans(id:IDp p:P)|{DeathPacmanLoop T ID}
	    end
	 end
      end
   in
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 state(g:Ghost s:Spawn ob:OnBoard p:Position pac:{DeathPacmanLoop Pacmans ID} m:Mode)
      end
   end

% Je ne sais pas comment faire de différence avec DeathPacman
   fun {KillPacman State ID}
      fun {KillPacmanLoop Pacmans ID}
	 case Pacmans
	 of pacmans(id:IDp p:P)|T then
	    if IDp == ID then T
	    else
	       pacmans(id:IDp p:P)|{KillPacmanLoop T ID}
	    end
	 end
      end
   in
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 state(g:Ghost s:Spawn ob:OnBoard p:Position pac:{KillPacmanLoop Pacmans ID} m:Mode)
      end
   end
   fun {SetMode State M}
      case State
      of state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:Mode) then
	 state(g:Ghost s:Spawn ob:OnBoard p:Position pac:Pacmans m:M)
      end
   end
   % ID is a <ghost> ID
   fun{StartPlayer ID}
    Stream Port
   in
      {NewPort Stream Port}
      thread
	 {TreatStream Stream}
      end
      Port
   end

   proc{TreatStream Stream State} % has as many parameters as you want

      % State = state(g:Ghost s:Spawn ob:OnBoard p:Position p:Pacmans m:Mode)
      
      case Stream
      of getId(?ID)|T then {TreatStream T {GetId State ID}}
      [] move(?ID ?P)|T then {TreatStream T {Move State ID P}}
      [] gotKilled()|T then {TreatStream T {GotKilled State}}
      [] pacmanPos(ID P)|T then {TreatStream T {PacmanPos ID P}}
      [] killPacman(ID)|T then {TreatStream T {KillPacman State ID}}
      [] deathPacman(ID)|T then {TreatStream T {DeathPacman State ID}}
      [] setMode(M)|T then {TreatStream T {SetMode State M}}	 
      end
   end
end
