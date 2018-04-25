% MODE SIMULTANE
% A RAJOUTE DANS MAIN.OZ

% to allow your players to think while not stopping for the other messages (example player got killed while thinking for its move), we advise you to look at the timer protocol explained page 368 of the book

declare
NewPortObject2
Timer
NewPortObjectServer
Controller
ServerProc
in
   
% FONCTIONS AUXILIAIRES

   % NewPortObject Pour le Timer
   % testé individuellement
fun {NewPortObject2 Proc}
   P
in
   thread S in
      P = {NewPort S}
      for M in S do {Proc M} end
   end
   P
end

   % Vient du livre p. 370
   % Le but est de permettre aux joueurs d'attendre un certain delay avant d'envoyer un message move, sans s'arrêter pour les autres messages
   % principe testé individuellement
fun {Timer}
   {NewPortObject2
    proc {$ Msg}
       case Msg of starttimer(T Pid Id ?NewPos) then
	  thread {Delay T} {Send Pid stoptimer(Id NewPos)} end
       end
    end}
end

   %Init = state(posPac:PosPac posG:PosG posB:PosB posP:PosP m:Mode)
fun {NewPortObjectServer Proc Init}
   Stream Port
in
   {NewPort Stream Port}
   thread
      {Proc Stream Init}
   end
   Port
end

fun {Controller Init /*ce qui suit : à enlever*/ Input}
   Pid = {Timer}
   proc {ServerProc Msg State}
      case Msg
      of stoptimer(Id NewPos)|T then {ServerProc T {Move Id NewPos State}}	 
      [] movePacman(Id NewPos)|T then Temps in
	 Temps =  ({OS.rand} mod (Input.thinkMax-Input.thinkMin+1))+Input.thinkMin
	 {Send Pid starttimer(Temps Cid Id NewPos)}
	 {ServerProc T State}
      [] moveGhost(Id NewPos)|T then
	 {Send Pid starttimer(Temps Cid Id NewPos)}
	 {ServerProc T State}
      [] movePacman(Id ?NewPos)|T then {ServerProc T {MovePacman State}} 
      [] huntMode(Mode)|T then {ServerProc T {HuntMode State}}
      [] ghostOn{Pos ?List}|T then {ServerProc T {GhostOn Pos ?List State}} 
      [] pacmanOn(Pos ?List)|T then {ServerProc T {PacmanOn Pos ?List State }}
      [] pointOn(Pos ?Point)|T then {ServerProc T {PointOn State}}
      [] killPacman(ListPacmans IdGhost EndOfGame)|T then {ServerProc T {KillPacman ListPacmans IdGhost EndOfGame State}}
      [] winPoint(Id Point)|T then {ServerProc T {WinPoint Id Point State}}  
      [] bonusOn(Pos ?Point)|T then {ServerProc T {BonusOn Pos ?Point State}}
      [] winBonus(Id Bonus)|T then {ServerProc T {WinBonus Id Bonus State}} 
      [] killGhost(IdPacman ListGhosts) |T then {ServerProc T {KillGhost IdPacman ListGhosts State}}
      [] whoWin(?Vainqueur)|T then {ServerProc T {WhoWin State}}
      [] pacmanInLife(End)|T then {ServerProc T {PacmanInLife End State)} % A rajouter : demande à tous les pacmans leur nombre de vie restant
	                                                                % et lie End à true si il ne reste aucune vie à aucun pacman, false sinon
      end   
   end
   Cid
in
   Cid = {NewPortObjectServer ServerProc Init}
   Cid
end

% Pour un pacman
proc {ClientFoncPacman ID}
   % le pacman veut jouer
   local NewPos Mode Liste in
      {Send Server movePacman(ID NewPos)}
      {Wait NewPos} % à enlever?
      {Send Server huntMode(Mode)}
      if Mode==classic then %%%%%%%%%%% MODE CLASSIC %%%%%%%%%%
	 {Send Server ghostOn(NewPos Liste)}
	 if Liste \= nil then % il y a au moins 1 ghost sur la case %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier (le nil)
	    % Prendre un ghost au hasard sur la liste
	    local Length Number IdGhost EndOfGame in
	       Length = {List.length Liste}
	       Number = ({OS.rand} mod Length)+1
	       IdGhost = {List.nth Liste Number}  %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier
	       {Send Server killPacman(ID|nil IdGhost EndOfGame)} 
	       if (EndOfGame) then
		  skip % fin du jeu
	       end
	    end
	 end
      else %%%%%%%%%%% MODE HUNT %%%%%%%%%%
	 {Send Server ghostOn(NewPos Liste)}
	 if Liste \= nil then % il y a au moins 1 ghost sur la case %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier (le nil)
	    {Send Server killGhost(ID Liste)}
	 end	 	    
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier : le pacman peut gagner des points même en mode hunt?
      % Points et bonus
      local Point in
	 {Send Server pointOn(NewPos Point)}
	 if Point \= nil then %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier (le nil)
	    {Send Server winPoint(ID Point)}
	 end
      end
      local Bonus in
	 {Send Server bonusOn(NewPos Bonus)}
	 if Bonus \= nil then %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier (le nil)
	    {Send Server winBonus(ID Point)}  %%%%%%%%%%%%%%%%%%%%%%%%%% à changer?
	 end
      end
   end
end


proc {ClientFoncGhost ID}
   local NewPos Mode Liste in
      {Send Server moveGhost(ID NewPos)}
      if NewPos \= nil then
	 {Send Server huntMode(mode)}
	 if Mode==classic then
	    {Send Server pacmanOn(NewPos Liste)}
	    if List \= nil then
	       local EndOfGame in
		  {Send Server killPacman(ID Liste EndOfGame)}
		  if (EndOfGame) then
		     skip
		  end
	       end
	    end
	 else % Mode Hunt
	    local Liste in
	       {Send Server pacmanOn(NewPos Liste)}
	       if Liste \= nil then % il y a au moins un pacman sur la case
		  local Length Number IdPacman in
		     Length = {List.length Liste}
		     Number =  ({OS.rand} mod Length)+1
		     IdPacman = {List.nth Liste Number} %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier
		     {Send Server killGhost(IdPacman ID|nil)}
		  end
	       end
	    end
	 end
      end
   end
   local End in
      {Send Server pacmanInLife(End)}
      if End == true then skip
      end
   end
end

proc {InitClient ID Player}
   case Player
   of pacman then
      case ID
      of H|T then
	 thread {ClientFoncPacman H} end
	 {InitClient T Player}
      [] nil then skip
      end
   [] ghost then
      case ID
      of H|T then
	 thread {ClientFoncGhost H} end
	 {InitClient T Player}
      [] nil then skip
      end
   end
end



% création du server
Server = {Controller state(posPac:PosPac posG:PosG posB:PosB posP:PosP m:Mode)} %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier

% création des clients
{InitClient IdPacman pacman} % InitPacman = liste des IDs des pacmans
{InitClient IdGhost ghost}


		     
		     
		 
		  
		  
	       
      
      
      
      
      
  
      
   
	