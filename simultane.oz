% MODE SIMULTANE
% A RAJOUTE DANS MAIN.OZ

% to allow your players to think while not stopping for the other messages (example player got killed while thinking for its move), we advise you to look at the timer protocol explained page 368 of the book


% IdPacman dans la fonction KillPacman de turn by turn

declare
NewPortObject2
Timer
NewPortObjectServer
Controller
ServerProc
in
   
% FONCTIONS AUXILIAIRES
/*
Diffuse un message à toute une liste de ports
In : Liste de ports et le message à diffuser
Out : /
*/
proc {Diffusion PortsList Message}
   case PortsList
   of H|T then
      {Send H Message}
      {Diffusion T Message}
   [] nil then skip
   end
end

% Lie End à true si tous les pacmans sont définitivement morts, à false sinon
fun {EndGame End State}
   if State.pin == nil then
      End = true
      State
   else
      End = false
      State
   end
end

% Lie Life à true si le <pacman> ID n'est pas définitivement mort, à false sinon
fun {PacInLife ID Life L State}
   case L
   of H|T then
      if ID == H then true
	 Life = true
	 State
      else
	 {PacInLife ID Life T State}
      end
   [] nil then
      Life = false
      State
   end
end

% testé séparément
fun {RemoveS ID L}
   case L
   of H|T then
      if H == ID then T
      else
	 H|{RemoveS ID T}
      end
   [] nil then nil
   end
end

% Différent de KillPacman du mode turn-by-turn
fun {KillPacmanS ListPacmans IdG State PortTimer Server}
   fun {KillPacmanSLoop ListPacmans IdG State L}
      PortPac
   in
      case ListPacmans
      of IdPac|T then
	 PortPac = {List.nth PortsPacman IdPac.id}
	 local NewLife NewScore in
	    {Send PortPac gotKilled(_ NewLife NewScore)}
             % prévénir tous les ghosts, avec un message différent pour celui qui a tué le pacman
	    {Diffusion PortsGhost deathPacman(IdPacman)}
	    {Send {List.nth PortsGhost IdGhost.id} killPacman(IdPacman)}
            % prévenir GUI
	    {Send WindowPort hidePacman(IdPacman)}
	    {Send WindowPort scoreUpdate(IdPacman NewScore)}
	    {Send WindowPort lifeUpdate(IdPacman NewLife)}
	    if NewLife == 0 then
	       {KillPacmanSLoop T IdG State {RemoveS IdPac L}}
	    else
	       {Send PortTimer starttimerPacman(IdPac Server)}
	       {KillPacmanSLoop T IdG State L}
	    end
	 end
      [] nil then {AdjoinList State pin#L}
      end
   end
in
   {KillPacmanSLoop ListPacmans IdG State State.pin}
end

/*
Attention !
Pour KillPacman : si un des pacmans présents dans la liste n'est pas définitivement mort, il faut appeler le timer pour le faire revivre --> pac encore fait


*/
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
       case Msg
       of starttimerMove(T Pid Id ?NewPos) then
	  thread {Delay T} {Send Pid stoptimer(Id NewPos)} end
       [] starttimerPoint() then
	  ...
       [] starttimerBonus() then
	  ...
       [] starttimerPacman(IdPac Server) then
	  local Port IdCheck PCheck in
	     
       [] sarttimerGhost() then
	  ...
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
      of stoptimerMove(Id NewPos)|T then {ServerProc T {Move Id NewPos State}}
      [] stoptimerBonus()|T then ...
      [] stoptimerPoint()|T then ...
      [] stoptimerPacman()|T then...
      [] stoptimerGhost()|T then ...
	 
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

      [] killPacman(ListPacmans IdGhost)|T then {ServerProc T {KillPacmanS ListPacmans IdGhost State}}
      [] killGhost(IdPacman ListGhosts) |T then {ServerProc T {KillGhostS IdPacman ListGhosts State}}
	 
      [] winPoint(Id Point)|T then {ServerProc T {WinPoint Id Point State}}  
      [] bonusOn(Pos ?Point)|T then {ServerProc T {BonusOn Pos ?Point State}}
      [] winBonus(Id Bonus)|T then {ServerProc T {WinBonus Id Bonus State}} 
      [] whoWin(?Vainqueur)|T then {ServerProc T {WhoWin State}}
      [] pacmanInLife(ID Life)|T then {ServerProc T {PacmanInLife ID Life State.pin State)}
      [] endGame(End)|T then {ServerProc T {EndGame End State}}
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
	       {Send Server killPacman(ID|nil IdGhost)}
	       local Life in
		  {Send Server pacInLife(ID Life)}
		  if Life == false then skip
		  end
	       end
	    end
	 else
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
      else %%%%%%%%%%% MODE HUNT %%%%%%%%%%
	 {Send Server ghostOn(NewPos Liste)}
	 if Liste \= nil then % il y a au moins 1 ghost sur la case %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier (le nil)
	    {Send Server killGhost(ID Liste)}
	 end
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
end


proc {ClientFoncGhost ID}
   local End in
      {Send Server endGame(End)}
      if End == true then skip
      end
   end
   local NewPos Mode Liste in
      {Send Server moveGhost(ID NewPos)}
      if NewPos \= nil then
	 {Send Server huntMode(mode)}
	 if Mode==classic then
	    {Send Server pacmanOn(NewPos Liste)}
	    if List \= nil then
	       {Send Server killPacman(Liste ID)} % On tue le/les pacman(s)
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

/*
Gérer une mort définitive ou la fin du jeur
Un pacman peut mourir selon de deux "façons" :
- Soit le pacman avance sur une case où un ghost est présent. Dans ce cas, s'il meurt définitvement, la procédure ClientFoncPac se termine
				   --> il faut que killpacman enlève de PacInLife le pacman définitvement mort
				   --> puis il faut une fonction qui parcourt pacInLife et répond si le pacman est définivement mort
- Soit un ghost arrive sur une case où il y a déjà un/plusieurs pacman(s). la fonction KillPacman est appelée et chaque pacman meurt. Une fonction enlève de pacInLife chaque pacman définitivement morts et prévient pour chaque pacman si c'est la fin du jeu ou pas. Ainsi, chaque proc ClientFoncGhost peut demander en début de tour s'il y a encore des pacmans non définitivement morts.
								     
		     
*/		 
		  
		  
	       
      
      
      
      
      
  
      
   
	