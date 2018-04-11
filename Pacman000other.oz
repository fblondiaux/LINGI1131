% Pacman000other.oz
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
   BonusSpawn
   PointSpawn
   BonusRemoved
   PointRemoved
   AddPoint
   GotKilled
   GhostPos
   KillGhost
   DeathGost
   SetMode
   
in
   fun {GetId State ID}
      case State
      of state(p:pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives) then
	 ID = Pacman
   end
   fun {AssignSpawn State S}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives) then
	 state(p:Pacman s:S ob:OnBoard p:Position po:Point b:Bonus l:Lives)
      end
   end
   fun {Spawn State P ID}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives) then
	 if OnBoard == false && Lives >0 then
	    P = Position
	    ID = Pacman
	    state(p:Pacman s:Spawn ob:true p:Position po:Point b:Bonus l:Lives)
	 else
	    P = null
	    ID = null
	    State
	 end
      end
   end
   fun {Move State P ID}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives) then
	 if Lives > 0 then
	    P = null
	    ID = null
	    State
	    % Je n'ai pas compris comment le pacman devait choisir sa position
	 else
	    P = null
	    ID = null
	    State
	 end
      end
   end
   fun {BonusSpawn State P}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives) then
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:P|Bonus l:Lives)
      end
   end
   fun {PointSpawn State P}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives) then
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:P|Point b:Bonus l:Lives)
      end
   end

   
  % ID is a <pacman> ID
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

     % State = state(p:pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives)
     
     case Stream
     of getId(ID)|T then
	{TreatStream T {getId State ID}}
	
     [] assignSpawn(P)|T then
	{TreatStream T {AssignSpawn State P}}
	
     [] spawn(ID P)|T then 
	{TreatStream T {Spawn State P ID}}
	
     [] move(ID P)|T then
	{TreatStream T {Move State P ID}}
	
     [] bonusSpawn(P)|T then
	{TreatStream T {BonusSpawn State P}}
	
     [] pointSpawn(P)|T then
	{TreatStream T {PointSpawn State P}}
	
     [] bonusRemoved(P)|T then {Browse 'coucou'}
     [] pointRemoved(P)|T then {Browse 'coucou'}
     [] addPoint(Add ?ID ?NewScore)|T then {Browse 'coucou'}
     [] gotKilled(?ID ?NewLife ?NewScore)|T then {Browse 'coucou'}
     [] ghostPos(ID P)|T then {Browse 'coucou'}
     [] killGhost(IDg ?IDp ?NewScore)|T then {Browse 'coucou'}
     [] deathGhost(ID)|T then {Browse 'coucou'}
     [] setMode(M)|T then {Browse 'coucou'}
     end
  end


  
   
