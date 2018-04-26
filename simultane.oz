% MODE SIMULTANE
% A RAJOUTE DANS MAIN.OZ

% to allow your players to think while not stopping for the other messages (example player got killed while thinking for its move), we advise you to look at the timer protocol explained page 368 of the book

% Dans pacman et ghost : savoir gérer le cas où on retire 2 fois un pacman ou un ghost quand il est mort (ex : le ghost reçoit un KillGhost et un DeathGhost)
% IdPacman dans la fonction KillPacman de turn by turn

declare

EndGame
PacInLife
RemoveS
WinBonusS
PointOnS
BonusOnS
KillPacmanS
KillGhostS
RespawnPoint
RespawnBonus
RespawnPacman
ResPawnGhost
NewPortObject2
NewPortObjectServer
Timer
Controller
ClientFoncGhost
ClientFoncPacman
InitClient


in
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
/*
ID : un <pacman>
Life : une variable qui sera liée à true si le <pacman> ID n'est pas définitivement mort, à false sinon
L : liste des <pacman> non définitivement morts
*/
fun {PacInLife ID Life L State}
   case L
   of H|T then
      if ID == H then 
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

%Un bonus est attrapé, toutes les actions correspondantes sont réalisées. % MODIFIE PAR RAPPORT A TURN BY TURN
/*
Bonus : <position> du bonus
*/
fun{WinBonusS Bonus State}
   {Send WindowPort hideBonus(Bonus)}
   {Diffusion PortsPacman bonusRemoved(Bonus)}
   {Diffusion PortsPacman setMode(hunt)}
   {Diffusion PortsGhost setMode(hunt)}
   {Send WindowPort setMode(hunt)}
   {AdjoinList State [m#hunt]}
end


/* La fonction prends un point <position> en argument, si il y en a un dans le state, elle le retire et met dans la liste à décrémenter
si pas l'etat ne change pas et ret est bound à nil */
fun{PointOnS Pos Ret State PortTimer Server}
   if({List.member Point State.posP}) then %Si p est dans la liste posP
      Ret = Pos
      {Send PortTimer starttimerPoint(Pos PortTimer Server)} % pour le respawn
      {AdjoinList State [posP#{List.subtract State.posP Pos}]}
   else 
      Ret = nil 
      State
   end
end

/*Meme principe que pointOn */
fun{BonusOnS Pos Ret State PortTimer Server}
   if({List.member Pos State.posB}) then %Si Pt est dans la liste posB
      Ret = Pos
      {Send PortTimer starttimerBonus(Pos PortTimer Server)}
      {AdjoinList State [posB#{List.subtract State.posB Pos}]}
   else 
      Ret = nil 
      State
   end
end

% Différent de KillPacman du mode turn-by-turn
/*
ListPacmans : liste des <pacman> à tuer
IdG : <ghost> qui les a tués
PortTimer : port pour déclencher le timer
Server : port du server, à mettre dans le message envoyé au PortTimer
*/
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
	    {Send {List.nth PortsGhost IdG.id} killPacman(IdPacman)}
            % prévenir GUI
	    {Send WindowPort hidePacman(IdPacman)}
	    {Send WindowPort scoreUpdate(IdPacman NewScore)}
	    {Send WindowPort lifeUpdate(IdPacman NewLife)}
	    if NewLife == 0 then
	       {KillPacmanSLoop T IdG {AdjoinList State [posPac#{Delete IdPac State.posPac}]} {RemoveS IdPac L}}
	    else
	       {Send PortTimer starttimerPacman(IdPac {AdjoinList State [posPac#{Delete IdPac State.posPac}]} PortTimer Server)}
	       {KillPacmanSLoop T IdG {AdjoinList State [posPac#{Delete IdPac State.posPac}]} L}
	    end
	 end
      [] nil then {AdjoinList State pin#L}
      end
   end
in
   {KillPacmanSLoop ListPacmans IdG State State.pin}
end

fun {KillGhostS IdPac ListGhosts State PortTimer Server}
   PortGhost IDp NewScore
in
   case ListGhosts
   of IdG|T then
      PortGhost = {List.nth PortsGhost IdG.id}
       % prévénir le ghost qu'il a été tué
      {Send PortGhost gotKilled()}
       %prévénir tous les pacmans, avec un message différent pour celui qui a tué le ghost
      {Diffusion PortsPacman deathGhost(IdG)}
      {Send {List.nth PortsPacman IdPac.id} killGhost(IdG IDp NewScore)}
      % prévénir GUI
      {Send WindowPort scoreUpdate(IDp NewScore)}
      {Send WindowPort hideGhost(IdGhost)}
       % appel starttimer et appel récursif avec le nouveau State (State dans lequel on a retiré IdGhost de posG)
      {Send PortTimer starttimer(IdG {AdjoinList State [posG#{Delete IdGhost State.posG}]} PortTimer Server)}
      {KillGhost IdPacman T
       {AdjoinList State [posG#{Delete IdGhost State.posG}]}}
   [] nil then State
   end
end

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

   % Vient du livre p. 370
   % Le but est de permettre aux joueurs d'attendre un certain delay avant d'envoyer un message move, sans s'arrêter pour les autres messages
   % principe testé individuellement
fun {Timer}
   {NewPortObject2
    proc {$ Msg}
       case Msg
       of starttimerMove(T Server Id NewPos) then
	  thread
	     {Delay T}
	     {Send Server stoptimer(Id NewPos)}
	  end	  
       [] starttimerPoint(Pos PortTimer Server) then
	  thread
	     {Delay Input.respawnTimePoint}
	     {Send Server stoptimerPoint(Pos PortTimer Server)}
	  end
       [] starttimerBonus(Pos PortTimer Server) then
	  thread
	     {Delay Input.respawnTimeBonus}
	     {Send Server stoptimerBonus(Pos PortTimer Server)}   
	  end	  	  
       [] starttimerPacman(IdPac PortTimer Server) then
	  thread
	     {Delay Input.respawnTimePacman}
	     {Send Server stoptimerPacman(IdPad PortTimer Server)}
	  end   
       [] sarttimerGhost(IdG State PortTimer Server) then
	  thread
	     {Delay InputrespawnTimeGhost}
	     {Send Server stoptimerGhost(IdG PortTimer Server)}
	  end
       end
    end}
end

fun {RespawnPoint Pos PortTimer Server State}
   % respawn le point : diffusion à tous les pacmans et à windowPort
   {Diffusion PortsPacman pointSpawn(Pos)}
   {Send WindowPort spawnPoint(Pos)}
   % regarder si pacman dessus : s'il y en a plusieurs, un au hasard gagne le point --> winPoint
   local Ret in
      {PacmanOn Pos Ret State _}
      if Ret \= nil then % il y a au moins un pacman sur la case
	 {Send Server winPoint({List.nth Ret ({OS.rand} mod {List.length Ret})+1} Pos)}
	 {AdjoinList State [posP#{List.append Pos State.posP}]}
      else
	 {AdjoinList State [posP#{List.append Pos State.posP}]}
      end
   end
end

fun {RespawnBonus Pos PortTimer Server State}
   % respawn le bonus : diffusion à tous les pacmans et à windowPort
   {Diffusion PortsPacman bonusSpawn(Pos)}
   {Send WindowPort spawnBonus(Pos)}
	     % si pacman dessus : s'il y en a plusieurs, un au hasard gagne le bonus --> winBonus
   local Ret in
      {PacmanOn Pos Ret State _}
      if Ret \= nil then
	 {Send Server winBonus(Pos)}
	 {AdjoinList State [poB#{List.append Pos State.posB}]}
      else
	 {AdjoinList State [poB#{List.append Pos State.posB}]}
      end
   end
end

fun {RespawnPacman IdPac PortTimer Server State}
   local Port IdCheck PCheck in
      Port ={List.nth PortsPacman IdPac.id} % Port du pacman 
      {Send Port spawn(IdCheck PCheck)}
      local Ret in
	 {GhostOn PCheck Ret State _} % lier Ret à la liste des pacmans sur cette case
	 {Diffusion PortsGhost pacmanPos(IdCheck PCheck)} % Diffusion de la position du pacman à tous les ghosts
	 {Send WindowPort spawnPacman(IdCheck PCheck)}
	 if Ret \= nil then
            % prendre un ghost au hasard dans Ret
	    {Send Server killPacman( [IdCheck]  {List.nth Ret ({OS.rand} mod {List.length Ret})+1} PortTimer Server)}
	    {AdjoinList State [posPac#{List.append IdCheck#PCheck State.posPac}]}
	 else
	    {AdjoinList State [posPac#{List.append IdCheck#PCheck State.posPac}]} 
	 end
      end
   end
end

fun {RespawnGhost IdG PortTimer Server State}
   local Port IdCheck PCheck in
      Port = {List.nth PortsGhost IdG.id} % port du Ghost
      {Send Port spawn(IdCheck PCheck)}
      {Diffusion PortsPacman ghostPos(IdCheck PCheck)}
      {Send WindowPort spawnGhost(IdCheck PCheck)}
      local Ret in
	 {PacmanOn PCheck Ret State _}
	 if Ret \= nil then % il y a au moins 1 pacman sur la case où le ghost a spawn
	    {Send Server killPacman( Ret IdG PortTimer Server)}
	    {AdjoinList State [posG#{List.append IdCheck#PCheck State.posG}]}
	 else
	    {AdjoinList State [posG#{List.append IdCheck#PCheck State.G}]}
	 end
      end
   end
end


% State = state(posPac:PosPac posG:PosG posB:PosB posP:PosP m:Mode)
fun {Controller Init /*ce qui suit : à enlever*/ Input}
   PortTimer = {Timer}
   Cid
   proc {ServerProc Msg State}
      case Msg
      of stoptimerMovePacman(Id NewPos)|T then {ServerProc T {MovePacman Id NewPos State}}
      [] stoptimerMoveGhost(Id NewPos)|T then {ServerProc T {MoveGhost Id NewPos State}}
      [] stoptimerPoint(Pos PortTimer Server)|T then {ServerProc T {RespawnPoint Pos PortTimer Server State}}			
      [] stoptimerBonus(Pos PortTimer Server)|T then {ServerProc T {RespawnBonus Pos PortTimer Server State}}
      [] stoptimerPacman(IdPac PortTimer Server)|T then {ServerProc T {RespawnPacman IdPac PortTimer Server State}}
      [] stoptimerGhost(IdG PortTimer Server)|T then {ServerProc T {RespawnGhost IdG PortTimer Server State}}
	 
      [] movePacman(Id NewPos)|T then Temps in
	 Temps =  ({OS.rand} mod (Input.thinkMax-Input.thinkMin+1))+Input.thinkMin
	 {Send PortTimer starttimer(Temps Cid Id NewPos)}
	 {ServerProc T State}
	 
      [] moveGhost(Id NewPos)|T then Temps in
	 Temps =  ({OS.rand} mod (Input.thinkMax-Input.thinkMin+1))+Input.thinkMin
	 {Send PortTimer starttimer(Temps Cid Id NewPos)}
	 {ServerProc T State}
	 	 
      [] huntMode(Mode)|T then {ServerProc T {HuntMode State}}
      [] ghostOn{Pos List}|T then {ServerProc T {GhostOn Pos List State}} 
      [] pacmanOn(Pos List)|T then {ServerProc T {PacmanOn Pos List State }}
      [] pointOn(Pos Point)|T then {ServerProc T {PointOnS Pos Point State}}
      [] bonusOn(Pos Bonus)|T then {ServerProc T {BonusOnS Pos Bonus State}}	 

      [] killPacman(ListPacmans IdG)|T then {ServerProc T {KillPacmanS ListPacmans IdG State PortTimer Cid}}
      [] killGhost(IdPac ListGhosts) |T then {ServerProc T {KillGhostS IdPac ListGhosts State PortTimer Cid}}
	 
      [] winPoint(Id Point)|T then {ServerProc T {WinPoint Id Point State}}  
      [] winBonus(Id Bonus)|T then {ServerProc T {WinBonusS Id Bonus State}}
	 
     % [] whoWin(?Vainqueur)|T then {ServerProc T {WhoWin State}}
      [] pacmanInLife(ID Life)|T then {ServerProc T {PacmanInLife ID Life State.pin State)}
      [] endGame(End)|T then {ServerProc T {EndGame End State}}
      end   
   end
in
   Cid = {NewPortObjectServer ServerProc Init}
   Cid
end


% ID est un <pacman>
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
		  {Send Server winBonus(Point)}  %%%%%%%%%%%%%%%%%%%%%%%%%% à changer?
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
	       {Send Server winBonus(Point)}  %%%%%%%%%%%%%%%%%%%%%%%%%% à changer?
	    end
	 end
      end
   end
end


/*
ID est un <ghost>
*/
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

/*
ID est un <pacman> ou un <ghost>
Player est pacman|ghost
On appelle la bonne procédure, un thread pour chaque joueur				  
*/
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





			   
	  

  
      
   
	