% Pacman000other.oz

% à faire : vérifier que un ID est bien de type <pacman>
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
   DeathGhost
   SetMode
   WallList 
   ListMap
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


   fun {GetId State ID}
         ID = State.id
         State
      end 
   end
   fun {AssignSpawn State S}
        {AdjoinList State [p#P s#P]}
   end
   fun {Spawn State P ID}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 if State.ob == false andthen State.l >0 then
	    P = State.s
	    ID = State.id
      {AdjoinList State [p#State.s ob#true]}
	 else
	    P = null
	    ID = null
	    State
	 end
      end
   end
%ICI

   fun {Move State P ID}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 if OnBoard then Next in
	    Next = ({OS.rand} mod 4)+1
	    case Next#P
	    of 1#pt(x:X y:Y) then
	       P = pt(x:X y:Y-1)
	       ID = Pacman
	       state(p:Pacman s:Spawn ob:OnBoard p:P po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
	    [] 2#pt(x:X y:Y) then
	       P = pt(x:X+1 y:Y)
	       ID = Pacman
	       state(p:Pacman s:Spawn ob:OnBoard p:P po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
	    [] 3#pt(x:X y:Y) then
	       P = pt(x:X y:Y+1)
	       ID = Pacman
	       state(p:Pacman s:Spawn ob:OnBoard p:P po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
	    [] 4#pt(x:X y:Y) then
	       P = pt(x:X-1 y:Y)
	       ID = Pacman
	       state(p:Pacman s:Spawn ob:OnBoard p:P po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
	    end  
	 else
	    P = null
	    ID = null
	    State
	 end
      end
   end
   fun {BonusSpawn State P}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:P|Bonus l:Lives sc:Score gh:Ghost m:Mode)
      end
   end
   fun {PointSpawn State P}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:P|Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
      end
   end
   fun {BonusRemoved State P}
      fun {BonusRemovedLoop P Bonus}
	 case Bonus
	 of H|T then
	    if H == P then T
	    else
	       H|{BonusRemovedLoop P T}
	    end
	 [] nil then nil
	 end
      end
   in 
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then B in
	 B = {BonusRemovedLoop P Bonus}
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:B l:Lives sc:Score gh:Ghost m:Mode)
      end	 
   end
   fun {PointRemoved State P}
      fun {PointRemovedLoop P Point}
	 case Point
	 of H|T then
	    if H==P then T
	    else H|{PointRemoved P T}
	    end
	 [] nil then nil
	 end
      end
   in
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then Point2 in
	 Point2 = {PointRemovedLoop P Point}
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point2 b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
      end 
   end

   fun {AddPoint State Add ID NewScore}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 NewScore = Score + Add
	 ID = Pacman
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:NewScore gh:Ghost m:Mode)
      end
   end

   fun {GotKilled State ID NewLife NewScore}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 % n'est plus on board, met à jour le nombre de vie et le nombre de points
	 ID = Pacman
	 NewLife = Lives-1
	 NewScore = Score-Input.penalityKill % points peuvent être négatif? ou il faut gérer le cas?
	 state(p:Pacman s:Spawn ob:false p:Position po:Point b:Bonus l:NewLife sc:NewScore gh:Ghost m:Mode)
      end
   end

   fun {GhostPos State ID P}
      fun {GhostPosLoop Ghost ID P}
	 case Ghost
	 of ghost(id:IDg p:Position)|T then
	    if IDg == ID then ghost(id:IDg p:P)|T
	    else ghost(id:IDg p:Position)|{GhostPosLoop T ID P}
	    end
	 [] nil then ghost(id:ID p:P)|nil
	 end
      end
   in
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:{GhostPosLoop Ghost ID P} m:Mode)
      end
   end

   fun {DeathGhost State ID}
      fun {DeathGhostLoop ID Ghost}
	 case Ghost
	 of ghost(id:IDg p:Position)|T then
	    if IDg == ID then T
	    else
	       ghost(id:IDg p:Position)|{DeathGhostLoop ID T}
	    end
	 end
      end
   in
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then NewGhost in
	 NewGhost = {DeathGhostLoop ID Ghost}
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:NewGhost m:Mode)
      end
   end

   % Je ne sais pas comment informer que ce ghost a été tué par moi (le pacman)
   fun {KillGhost State IDg IDp NewScore}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then NewState in
	 IDp = Pacman
	 NewScore = Score+Input.rewardKill
	 NewState = {DeathGhost State IDg}
	 case NewState
	 of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	    state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:NewScore gh:Ghost m:Mode)
	 end
      end  
   end

   fun {SetMode State M}
      case State
      of state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode) then
	 state(p:Pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:M)
      end
   end

  % ID is a <pacman> ID
  fun{StartPlayer ID}
    Stream Port
  in
    {NewPort Stream Port}
    thread
       {TreatStream Stream state(id:ID s:nil ob:false p:nil po:nil bo:nil l:Input.nbLives sc:0 gh:nil m:classic)}
    end
    Port
  end
 
  proc{TreatStream Stream State} % has as many parameters as you want

     % State = state(p:pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
	%OnBoard : true / false B and po : List of infos gh:Ghost ID and position (Record)	
     
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
	
     [] bonusRemoved(P)|T then
	{TreatStream T {BonusRemoved State P}}
	
     [] pointRemoved(P)|T then
	{TreatStream T {PointRemoved State P}}
	
     [] addPoint(Add ID NewScore)|T then
	{TreatStream T {AddPoint State Add ID NewScore}}
	
     [] gotKilled(ID NewLife NewScore)|T then
	{TreatStream T {GotKilled State ID NewLife NewScore}}
	
     [] ghostPos(ID P)|T then
	{TreatStream T {GhostPos State ID P}}
	
     [] killGhost(IDg IDp NewScore)|T then
	{TreatStream T {KillGhost State IDg IDp NewScore}}
	
     [] deathGhost(ID)|T then
	{TreatStream T {DeathGhost State ID}}
	
     [] setMode(M)|T then
	{TreatStream T {SetMode State M}}
     end
  end
end

   


  
   
