% Ghost000other.oz
functor
import
   InputTest1
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


fun {Move State ID P}
   fun{PacmanOn Pos} %On ne retire p         
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
   fun {TakeOutWallsClassic Liste} 
      case Liste of H|T then 
         if({PacmanOn H}) then [H]
         else
     if({List.member H WallList}) then
        {TakeOutWallsClassic T}
     else 
        H|{TakeOutWallsClassic T}
     end
         end
         []nil then nil
      end
   end
   


   fun {TakeOutWallsHunt Liste} 
      case Liste of H|T then 
   if({List.member H WallList} orelse {PacmanOn H}) then
      {TakeOutWallsHunt T}
   else 
      H|{TakeOutWallsHunt T}
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
   if(State.m == classic) then
      Next = {TakeOutWallsClassic [pt(x:X y:{Minus Y-1 Input.nRow}) pt(x:{Max X+1 Input.nColumn} y:Y) pt(x:X y:{Max Y+1 Input.nRow}) pt(x:{Minus X-1 Input.nColumn} y:Y)]}
   else Next = {TakeOutWallsHunt [pt(x:X y:{Minus Y-1 Input.nRow}) pt(x:{Max X+1 Input.nColumn} y:Y) pt(x:X y:{Max Y+1 Input.nRow}) pt(x:{Minus X-1 Input.nColumn} y:Y)]}
   end

   if(Next == nil) then 
      P = State.p
      ID = State.g
   else
      P = {List.nth Next ({OS.rand} mod {List.length Next})+1}
      ID = State.g
   end

   {AdjoinList State [p#P]}
      end

   else
      P = null
      ID = null
      State
   end
end
/*
   fun {Move State ?ID ?P}
      fun{PacmanOn Pos} %On ne retire p         
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
      proc{Find Pinit Pcurrent Done Res}
         Val in 
         Val = {List.nth {List.nth Input.map Pcurrent.y} Pcurrent.x}
         if(Val\= 1) then 
       if({PacmanOn Pcurrent}) then Res = Pinit
       else 
          local Next NextNew in
             Next =[pt(x:Pcurrent.x y:{Minus Pcurrent.y-1 Input.nRow}) pt(x:{Max Pcurrent.x+1 Input.nColumn} y:Pcurrent.y) pt(x:Pcurrent.x y:{Max Pcurrent.y+1 Input.nRow}) pt(x:{Minus Pcurrent.x-1 Input.nColumn} y:Pcurrent.y)]
             NextNew = {KickList Next Done}
             {WaitList {StartFind NextNew Pinit {List.append Done NextNew}} Res}
          end
       end
         else 
       Res =_
         end      
      end

      fun{StartFind L InitPos Done}
         case L of H|T then
       {Find InitPos H Done}|{StartFind T InitPos Done}
         []nil then nil 
         end
      end

      proc{WaitList Liste R}
         for I in Liste do 
       thread {Wait I} R = I end
         end
      end

      fun {KickList Liste ToRemove} 
         case Liste of H|T then 
       if({List.member H ToRemove}) then
          {KickList T ToRemove}
       else 
          H|{KickList T ToRemove}
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
       P = {WaitList [{Find pt(x:Pcurrent.x y:{Minus Pcurrent.y-1 Input.nRow}) pt(x:Pcurrent.x y:{Minus Pcurrent.y-1 Input.nRow}) nil}
            {Find pt(x:{Max Pcurrent.x+1 Input.nColumn} y:Pcurrent.y) pt(x:{Max Pcurrent.x+1 Input.nColumn} y:Pcurrent.y) nil} 
            {Find pt(x:Pcurrent.x y:{Max Pcurrent.y+1 Input.nRow}) pt(x:Pcurrent.x y:{Max Pcurrent.y+1 Input.nRow}) nil}
            {Find pt(x:{Minus Pcurrent.x-1 Input.nColumn} y:Pcurrent.y) pt(x:{Minus Pcurrent.x-1 Input.nColumn} y:Pcurrent.y) nil}]}
       ID = State.g
       {AdjoinList State [p#P]}
         end

      else
         P = null
         ID = null
         State
      end
   end
   */

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
        []nil then nil
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
      [] spawn(?ID ?P)|T then  {TreatStream T {Spawn State ID P}}
      [] gotKilled()|T then {TreatStream T {GotKilled State}}
      [] pacmanPos(ID P)|T then {TreatStream T {PacmanPos State ID P}}
      [] killPacman(_)|T then {TreatStream T State} %On ne fait rien de cette info
      [] deathPacman(ID)|T then {TreatStream T {DeathPacman State ID}}
      [] setMode(M)|T then {TreatStream T {SetMode State M}}	 
      end
   end
end