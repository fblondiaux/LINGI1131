% Pacman000other.oz

% à faire : vérifier que un ID est bien de type <pacman>
functor
import
   Input
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
   fun {AssignSpawn State S}
      {AdjoinList State [p#S s#S]}
   end
   fun {Spawn State P ID}
      
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


   fun {Move State P ID}
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
      if State.ob then Next in
   case State.p of pt(x:X y:Y) then
      Next = {TakeOutWalls [pt(x:X y:{Minus Y-1 Input.nRow}) pt(x:{Max X+1 Input.nColumn} y:Y) pt(x:X y:{Max Y+1 Input.nRow}) pt(x:{Minus X-1 Input.nColumn} y:Y)]}
      P = {List.nth Next ({OS.rand} mod {List.length Next})+1}

      ID = State.id
      {AdjoinList State [p#P]}
   end

      else
   P = null
   ID = null
   State
      end
   end


   fun {BonusSpawn State P}
      {AdjoinList State [bo#(P|State.bo)]}
   end

   fun {PointSpawn State P}
      {AdjoinList State [po#(P|State.po)]}
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
      {AdjoinList State [bo#{BonusRemovedLoop P State.bo}]} 
   end


   fun {PointRemoved State P}
      fun {PointRemovedLoop P Point}
   case Point
   of H|T then
      if H==P then T
      else H|{PointRemovedLoop P T}
      end
   [] nil then nil
   end
      end
   in
      {AdjoinList State [po#{PointRemovedLoop P State.po}]} 
  
   end

   fun {AddPoint State Add ID NewScore}
      NewScore = State.sc + Add
      ID = State.id
      {AdjoinList State [sc#NewScore]}
   end

   fun {GotKilled State ID NewLife NewScore}
   % n'est plus on board, met à jour le nombre de vie et le nombre de points
      ID = State.id
      NewLife = State.l-1
      NewScore = State.sc-Input.penalityKill % points peuvent être négatif? ou il faut gérer le cas?
      {AdjoinList State [sc#NewScore l#NewLife ob#false]}
   end

   fun {GhostPos State ID P}
      fun {GhostPosLoop Ghost ID P}
   case Ghost
   of go(id:IDg p:Position)|T then
      if IDg == ID then go(id:IDg p:P)|T
      else go(id:IDg p:Position)|{GhostPosLoop T ID P}
      end
   [] nil then go(id:ID p:P)|nil
   end
      end
   in
      {AdjoinList State [gh#{GhostPosLoop State.gh ID P}]}
   end

   fun {DeathGhost State ID}
      fun {DeathGhostLoop ID Ghost}
   case Ghost
   of go(id:IDg p:Position)|T then
      if IDg == ID then T
      else
         go(id:IDg p:Position)|{DeathGhostLoop ID T}
      end
   end
      end
   in 
      {AdjoinList State [gh#{DeathGhostLoop ID State.gh}]}
   end

   % Je ne sais pas comment informer que ce ghost a été tué par moi (le pacman)
   fun {KillGhost State IDg IDp NewScore}
      IDp = State.id
      NewScore = State.sc+Input.rewardKill
      {AdjoinList State [sc#NewScore]}
   end

   fun {SetMode State M}
      {AdjoinList State [m#M]}
   end

  % ID is a <pacman> ID
   fun{StartPlayer ID}
      Stream Port
   in
      {NewPort Stream Port}
      thread
   {TreatStream Stream state(id:ID s:nil ob:false p:nil po:nil bo:nil l:Input.nbLives sc:0 gh:nil m:classic)}
      end
      WallList = {ListMap}
      Port
   end
 
   proc{TreatStream Stream State} % has as many parameters as you want

     % State = state(p:pacman s:Spawn ob:OnBoard p:Position po:Point b:Bonus l:Lives sc:Score gh:Ghost m:Mode)
  %OnBoard : true / false B and po : List of infos gh:Ghost ID and position (Record)  

      case Stream
      of getId(ID)|T then
   {TreatStream T {GetId State ID}}
  
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