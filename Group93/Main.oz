functor
import
   GUI
   Input
   PlayerManager
   OS
   
define
   CreatePortPacman
   CreatePortGhost
   CreateIDs
   Shuffle
   Diffusion
   ListMap
   Mult
   InitSList
   Remove
   AssignRandomSpawn
   DecGhost
   DecPacman
   BonusDec
   DecPoint
   DecBonus
   DecHunt
   Delete
   KillPacman
   KillGhost
   PointOn
   BonusOn
   GhostOn
   PacmanOn
   WinPoint
   WinBonus
   HuntMode
   WhoWin
   MovePacman
   MoveGhost
   ServerProc
   ClientFonc
   NewPortObjectServer
   SpawnToIdPos

   WindowPort
   PortsPacman
   PortsGhost
   IdPacman
   IdGhost
   MapRecord
   Server

   Sequence %List containing IDs in which we're gonna play. (Suffle applied on IdPacman and IdGhost)
   PointList
   WallList
   PSList % pacman spawn list : tous les spawns possibles pour les pacmans
   GSList % ghost spawn list
   BonusList

   PSList2
   GSList2
   ListSpawnPacman % liste des spawns pour chaque pacman
   ListSpawnGhost

%%%% SIMULTANE
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
   RespawnGhost
   NewPortObject2
   NewPortObjectServer2
   Timer
   Controller
   ClientFoncGhost
   ClientFoncPacman
   InitClient
   OnBoard
%%%%%
in

   %SIMULTANE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   

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
      if({List.member Pos State.posP}) then %Si p est dans la liste posP
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
	       {Wait NewLife}
	       {Wait NewScore}
             % prévénir tous les ghosts, avec un message différent pour celui qui a tué le pacman
	       {Diffusion PortsGhost deathPacman(IdPac)}
	       {Send {List.nth PortsGhost IdG.id} killPacman(IdPac)}
            % prévenir GUI
	       {Send WindowPort hidePacman(IdPac)}
	       {Send WindowPort scoreUpdate(IdPac NewScore)}
	       {Send WindowPort lifeUpdate(IdPac NewLife)}
	       if NewLife == 0 then
		  {KillPacmanSLoop T IdG {AdjoinList State [posPac#{Delete IdPac State.posPac}]} {RemoveS IdPac L}}
	       else
		  {Send PortTimer starttimerPacman(IdPac PortTimer Server)}
		  {KillPacmanSLoop T IdG {AdjoinList State [posPac#{Delete IdPac State.posPac}]} L}
	       end
	    end
	 [] nil then {AdjoinList State [pin#L]}
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
	 {Wait IDp}
	 {Wait NewScore}
      % prévénir GUI
	 {Send WindowPort scoreUpdate(IDp NewScore)}
	 {Send WindowPort hideGhost(IdG)}
       % appel starttimer et appel récursif avec le nouveau State (State dans lequel on a retiré IdGhost de posG)
	 {Send PortTimer starttimerGhost(IdG PortTimer Server)}
	 {KillGhost IdPac T
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
   fun {NewPortObjectServer2 Proc Init}
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
	  of starttimerMovePacman(T Server Id NewPos) then
	     thread
		{Delay T}
		{Send Server stoptimerMovePacman(Id NewPos)}
	     end
	  [] starttimerMoveGhost(T Server Id NewPos) then
	     thread
		{Delay T}
		{Send Server stoptimerMoveGhost(Id NewPos)}
	     end
	  [] starttimerPoint(Pos PortTimer Server) then
	     thread
		{Delay (Input.respawnTimePoint)*1000}
		{Send Server stoptimerPoint(Pos PortTimer Server)}
	     end
	  [] starttimerBonus(Pos PortTimer Server) then
	     thread
		{Delay (Input.respawnTimeBonus)*1000}
		{Send Server stoptimerBonus(Pos PortTimer Server)}   
	     end	  	  
	  [] starttimerPacman(IdPac PortTimer Server) then
	     thread
		{Delay (Input.respawnTimePacman)*1000}
		{Send Server stoptimerPacman(IdPac PortTimer Server)}
	     end   
	  [] starttimerGhost(IdG PortTimer Server) then
	     thread
		{Delay (Input.respawnTimeGhost)*1000}
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
	    thread  {Send Server winPoint({List.nth Ret ({OS.rand} mod {List.length Ret})+1} Pos)} end
	    {AdjoinList State [posP#{List.append [Pos] State.posP}]}
	 else
	    {AdjoinList State [posP#{List.append [Pos] State.posP}]}
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
	    thread {Send Server winBonus(Pos)} end
	    {AdjoinList State [poB#{List.append [Pos] State.posB}]}
	 else
	    {AdjoinList State [poB#{List.append [Pos] State.posB}]}
	 end
      end
   end

   %L = State.pin % (liste de <pacman>|<position> aves les pacmans non définitivement morts)
   fun {RespawnPacman IdPac L PortTimer Server State}
      local Life  in
   {PacInLife IdPac Life State.pin State _}
	 if Life == false then
	    State % arrêter cette procédure
	 else
	    local Port IdCheck PCheck in
	       Port ={List.nth PortsPacman IdPac.id} % Port du pacman 
	       {Send Port spawn(IdCheck PCheck)}
	       {Wait IdCheck}
	       {Wait PCheck}
	       if IdCheck == null then
		  State
	       else 
		  local Ret in
		     {GhostOn PCheck Ret State _} % lier Ret à la liste des ghosts? sur cette case
		     {Diffusion PortsGhost pacmanPos(IdCheck PCheck)} % Diffusion de la position du pacman à tous les ghosts
		     {Send WindowPort spawnPacman(IdCheck PCheck)}
		     if Ret \= nil then
                        % prendre un ghost au hasard dans Ret
			thread {Send Server killPacman( [IdCheck]  {List.nth Ret ({OS.rand} mod {List.length Ret})+1})} end
			{AdjoinList State [posPac#{List.append [IdCheck#PCheck] State.posPac}]}
		     else
			{AdjoinList State [posPac#{List.append [IdCheck#PCheck] State.posPac}]} 
		     end
		  end
	       end
	    end
	 end
      end
   end


   fun {RespawnGhost IdG PortTimer Server State}
      local Port IdCheck PCheck in
	 Port = {List.nth PortsGhost IdG.id} % port du Ghost
	 {Send Port spawn(IdCheck PCheck)}
	 {Wait IdCheck}
	 {Wait PCheck}
	 {Diffusion PortsPacman ghostPos(IdCheck PCheck)}
	 {Send WindowPort spawnGhost(IdCheck PCheck)}
	 local Ret in
	    {PacmanOn PCheck Ret State _}
	    if Ret \= nil then % il y a au moins 1 pacman sur la case où le ghost a spawn
	       thread {Send Server killPacman( Ret IdG )} end
	       {AdjoinList State [posG#{List.append [IdCheck#PCheck] State.posG}]}
	    else
	       {AdjoinList State [posG#{List.append [IdCheck#PCheck] State.posG}]}
	    end
	 end
      end
   end

   fun {OnBoard ID Ret State}
      fun {OnBoardLoop ID Ret L}
	 case L
	 of Pac#pt(x:_ y:_)|T then
	    if Pac == ID then
	       Ret = true
	       State
	    else
	       {OnBoard ID  Ret T}
	    end
	 [] nil then
	    Ret = false
	    State
	 end
      end
   in
      {OnBoardLoop ID Ret State.posPac}	    
   end

% State = state(posPac:PosPac posG:PosG posB:PosB posP:PosP m:Mode)
   fun {Controller Init}
      PortTimer = {Timer}
      Cid
      proc {ServerProc2 Msg State}
	 case Msg
	 of stoptimerMovePacman(Id NewPos)|T then {ServerProc2 T {MovePacman Id NewPos State}}
	 [] stoptimerMoveGhost(Id NewPos)|T then {ServerProc2 T {MoveGhost Id NewPos State}}
	 [] stoptimerPoint(Pos PortTimer Server)|T then {ServerProc2 T {RespawnPoint Pos PortTimer Server State}}			
	 [] stoptimerBonus(Pos PortTimer Server)|T then {ServerProc2 T {RespawnBonus Pos PortTimer Server State}}
	 [] stoptimerPacman(IdPac PortTimer Server)|T then {ServerProc2 T {RespawnPacman IdPac State.pin PortTimer Server State}}
	 [] stoptimerGhost(IdG PortTimer Server)|T then {ServerProc2 T {RespawnGhost IdG PortTimer Server State}}
	 
	 [] movePacman(Id NewPos)|T then Temps in
	    Temps =  ({OS.rand} mod (Input.thinkMax-Input.thinkMin+1))+Input.thinkMin
	    {Send PortTimer starttimerMovePacman(Temps Cid Id NewPos)}
	    {ServerProc2 T State}
	 
	 [] moveGhost(Id NewPos)|T then Temps in
	    Temps =  ({OS.rand} mod (Input.thinkMax-Input.thinkMin+1))+Input.thinkMin
	    {Send PortTimer starttimerMoveGhost(Temps Cid Id NewPos)}
	    {ServerProc2 T State}
	 	 
	 [] huntMode(Mode)|T then {ServerProc2 T {HuntMode Mode State}}
	 [] ghostOn(Pos List)|T then {ServerProc2 T {GhostOn Pos List State}} 
	 [] pacmanOn(Pos List)|T then {ServerProc2 T {PacmanOn Pos List State }}
	 [] pointOn(Pos Point)|T then {ServerProc2 T {PointOnS Pos Point State PortTimer Cid}}
	 [] bonusOn(Pos Bonus)|T then {ServerProc2 T {BonusOnS Pos Bonus State PortTimer Cid}}	 

	 [] killPacman(ListPacmans IdG)|T then {ServerProc2 T {KillPacmanS ListPacmans IdG State PortTimer Cid}}
	 [] killGhost(IdPac ListGhosts) |T then {ServerProc2 T {KillGhostS IdPac ListGhosts State PortTimer Cid}}
	 
	 [] winPoint(Id Point)|T then {ServerProc2 T {WinPoint Id Point State}}  
	 [] winBonus(Bonus)|T then {ServerProc2 T {WinBonusS Bonus State}}
	 
         [] whoWin|T then {ServerProc2 T {WhoWin State}}
	 [] pacInLife(ID Life)|T then {ServerProc2 T {PacInLife ID Life State.pin State}}
	 [] endGame(End)|T then {ServerProc2 T {EndGame End State}}
	 [] onBoard(ID Ret)|T then {ServerProc2 T {OnBoard ID Ret State}}
	 end   
      end
   in
      Cid = {NewPortObjectServer2 ServerProc2 Init}
      Cid
   end


% ID est un <pacman>
   proc {ClientFoncPacman ID Msg}
      case Msg
      of 0 then % Continuer	 
         % le pacman veut jouer
	 local NewPos Mode Liste in
	    {Send Server movePacman(ID NewPos)}
	    {Wait NewPos}
	    {Wait ID} 
	    if NewPos \= null then
	       {Send Server huntMode(Mode)}
	       if Mode==classic then %%%%%%%%%%% MODE CLASSIC %%%%%%%%%%
		  % {Send Server ghostOn(NewPos Liste)}
		  % if Liste \= nil then % il y a au moins 1 ghost sur la case %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier (le nil)
	          % % Prendre un ghost au hasard sur la liste
		  %    local Length Number IdGhost in
		  % 	Length = {List.length Liste}
		  % 	Number = ({OS.rand} mod Length)+1
		  % 	IdGhost = {List.nth Liste Number}  %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier
		  % 	local Ret in
		  % 	   {Send Server onBoard(ID Ret)}
		  % 	   if Ret == true then % est on board (n'a pas déjà été tué par le ghost)
		  % 	      {Send Server killPacman(ID|nil IdGhost)}
		  % 	      local Life in
		  % 		 {Send Server pacInLife(ID Life)}
		  % 		 if Life == false then {ClientFoncPacman ID 1} % fin
		  % 		 end
		  % 	      end
		  % 	   end
		  % 	end
		  %    end
		  % else
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
			   {Send Server winBonus(Bonus)}  %%%%%%%%%%%%%%%%%%%%%%%%%% à changer?
			end
		     end
		  %end
	       else %%%%%%%%%%% MODE HUNT %%%%%%%%%%
		  {Send Server ghostOn(NewPos Liste)}
		  {Wait Liste}
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
			{Send Server winBonus(Bonus)}  %%%%%%%%%%%%%%%%%%%%%%%%%% à changer?
		     end
		  end
	       end
	    end
	    local Life in
	       {Send Server pacInLife(ID Life)}
	       if Life == false then
		  {ClientFoncPacman ID 1} % arrêter cette procédure
	       else
		  {ClientFoncPacman ID 0} % Continuer
	       end
	    end
	 end
	 
      [] 1 then
	 {Send Server whoWin}
	 {Delay 3000}
	 % fin
      end

   end


   /*
   ID est un <ghost>
   */
   proc {ClientFoncGhost ID Msg}
      case Msg
      of 0 then
	 local NewPos Mode Liste in
	    {Send Server moveGhost(ID NewPos)}
	    if NewPos \= nil then
	       {Send Server huntMode(Mode)}
	       if Mode==classic then
		  {Send Server pacmanOn(NewPos Liste)}
		  if Liste \= nil then
		    % for I in Liste do
		    % 	local Ret in
		    % 	   {Send Server onBoard(I Ret)}
		    % 	   {Wait Ret}
		    % 	   if Ret == true then % est on board (n'a pas déjà été tué par le ghost)
		    % 	      {Send Server killPacman(I|nil ID)
		    % 	  end
		    % 	end
		    %  end
		     {Send Server killPacman(Liste ID)}
		  end
	       % else % Mode Hunt
	       % 	  {Send Server pacmanOn(NewPos Liste)}
	       % 	  if Liste \= nil then % il y a au moins un pacman sur la case
	       % 	     local Length Number IdPac in
	       % 		Length = {List.length Liste}
	       % 		Number =  ({OS.rand} mod Length)+1
	       % 		IdPac = {List.nth Liste Number} %%%%%%%%%%%%%%%%%%%%%%%%%% à vérifier
	       % 		{Send Server killGhost(IdPac ID|nil)}
	       % 	     end
	       % 	  end
	       end
	    end
	 end
	 local End in
	    {Send Server endGame(End)}
	    if End == true then
	       {ClientFoncGhost ID 1} % fin
	    else
	       {ClientFoncGhost ID 0} % continuer
	    end
	 end
	 
      [] 1 then
	 skip
      end
   end

   
   %ID est un <pacman> ou un <ghost>
   %Player est pacman|ghost
   %On appelle la bonne procédure, un thread pour chaque joueur
				
					
   proc {InitClient ID Player}
      case Player
      of pacman then
	 case ID
	 of H|T then
	    thread {ClientFoncPacman H 0} end
	    {InitClient T Player}
	 [] nil then skip
	 end
      [] ghost then
	 case ID
	 of H|T then
	    thread {ClientFoncGhost H 0} end
	    {InitClient T Player}
	 [] nil then skip
	 end
      end
   end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   % TODO add additionnal function
   %Transform a list of spawn to ID#<position>|... We need it do create port server
   % List : list of <position>
   fun{SpawnToIdPos IdPacman Liste }
      case Liste of H|T then
	 IdPacman.1#H|{SpawnToIdPos IdPacman.2 T}
      []nil then nil
      end
   end

   %Function who creates ports for all Pacmans defined in Input.
   %In: Nothing
   %Out: Returns a list of all the ports.
   %We assume that Pacman Color and Name contains the same number of elements.
   %TODO = Name can be a different List - It can be funny names, we should decide if we change that.
   fun{CreatePortPacman}
      fun{CreatePortPacmanFull Pacman Color Name ID}
	 case Pacman of _|_ then
	    {PlayerManager.playerGenerator Pacman.1 pacman(id:ID color:Color.1 name:Name.1)}|{CreatePortPacmanFull Pacman.2 Color.2 Name.2 ID+1}
	 []nil then nil
	 end
      end
   in
      {CreatePortPacmanFull Input.pacman Input.colorPacman Input.pacman 1}
   end

    %Function who creates ports for all Ghosts defined in Input.
   %In: Nothing
   %Out: Returns a list of all the ports.
   %We assume that Pacman Color and Name contains the same number of elements.
   %TODO = Name can be a different List - It can be funny names, we should decide if we're gonna change that.
   fun{CreatePortGhost}
      fun{CreatePortGhostFull Ghost Color Name ID}
	 case Ghost of _|_ then {PlayerManager.playerGenerator Ghost.1 ghost(id:ID color:Color.1 name:Name.1)}|{CreatePortGhostFull Ghost.2 Color.2 Name.2 ID+1}
	 []nil then nil
	 end
      end
   in
      {CreatePortGhostFull Input.ghost Input.colorGhost Input.ghost 1}
   end

   %Function who transform a list of Ports into a list of <pacman ID>
   %In: List of Ports
   %Out: List of IDs
   fun{CreateIDs PortList}
      case PortList of H|T then
	 local R in
	    {Send H getId(R)}
	    R|{CreateIDs T}
	 end
      []nil then nil
      end
   end

   %Append the two lists and then shuffle the result
   %In : A list in a certain order
   %Out : Same elements but in a random order
   fun{Shuffle L1 L2}
      fun{TakeRandom L}
	 case L of _|_ then
	    local R Elem in
	       R = ({OS.rand} mod {List.length L})+1
	       Elem ={List.nth L R}
	       Elem|{TakeRandom {List.subtract L Elem}}
	    end
	 []nil then nil
	 end
      end
   in
      {TakeRandom {List.append L1 L2}}
   end

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

   %Fuction who transform a map into 4 lists of positions
   %In : Nothing -> we take Input.Map
   %Out : Gives a record with four list of <positions>, each position have been initialised.
   %Bonus and points are now visible on the map. Spawn have been created (but not assigned to a pacman/ghost 
   fun {ListMap PortsPacman}
      fun {ReadMap Row Column Rec}
	 if (Row > (Input.nRow)) then Rec
	 else
	    local Temp in
	       Temp = {List.nth Input.map Row}
	       case {List.nth Temp Column} % element a la rangee Row et a la colonne Column
	       of 0 then
		  local Pos in
		     Pos = pt(x:Column y:Row)
		     {Send WindowPort initPoint(Pos)}
		     {Send WindowPort spawnPoint(Pos)}
		     {Diffusion PortsPacman pointSpawn(Pos)} % Diffusion du point à tous les pacmans
		     if Column == Input.nColumn then
			{ReadMap Row+1 1 {Record.adjoinAt Rec pl Pos|Rec.pl}}
		     else
			{ReadMap Row Column+1 {Record.adjoinAt Rec pl Pos|Rec.pl}}
		     end
		  end
	       [] 1 then
		  local Pos in
		     Pos = pt(x:Column y:Row)
		     if Column == Input.nColumn then
			{ReadMap Row+1 1 {Record.adjoinAt Rec wl Pos|Rec.wl}}
		     else
			{ReadMap Row Column+1 {Record.adjoinAt Rec wl Pos|Rec.wl}}
		     end
		  end
	       [] 2 then
		  local Pos in
		     Pos = pt(x:Column y:Row)
		     if Column == Input.nColumn then
			{ReadMap Row+1 1 {Record.adjoinAt Rec psl Pos|Rec.psl}}
		     else
			{ReadMap Row Column+1 {Record.adjoinAt Rec psl Pos|Rec.psl}}
		     end
		  end
	       [] 3 then
		  local Pos in
		     Pos = pt(x:Column y:Row)
		     if Column == Input.nColumn then
			{ReadMap Row+1 1 {Record.adjoinAt Rec gsl Pos|Rec.gsl}}
		     else
			{ReadMap Row Column+1 {Record.adjoinAt Rec gsl Pos|Rec.gsl}}
		     end
		  end
	       [] 4 then
		  local Pos in
		     Pos = pt(x:Column y:Row)
		     {Send WindowPort initBonus(Pos)}
		     {Send WindowPort spawnBonus(Pos)}
		     {Diffusion PortsPacman bonusSpawn(Pos)} % Diffusion du bonus à tous les pacmans
		     if Column == Input.nColumn then
			{ReadMap Row+1 1 {Record.adjoinAt Rec bl Pos|Rec.bl}}
		     else
			{ReadMap Row Column+1 {Record.adjoinAt Rec bl Pos|Rec.bl}}
		     end
		  end
	       end
	    end
	 end
      end
   in
      {ReadMap 1 1 ptlist(pl:nil wl:nil psl:nil gsl:nil bl:nil)} %pl = point list, wl = wall list psl = pacman spawn list,
          %gsl = ghost spawn list, bl = bonus list.
   end

   % testé séparément
   fun {Mult E Max}
      if Max==0 then nil
      else
	 E|{Mult E Max-1}
      end
   end

   % testé séparément
   fun {InitSList L Max Acc}
      case L
      of H|T then
	 {InitSList T Max {Append Acc {Mult H Max}}}
      [] nil then Acc
      end
   end

   % testé séparément
   fun {Remove List E}
      case List
      of H|T then
	 if H == E then T
	 else
	    H|{Remove T E}
	 end
      end
   end

   % testé séparément
   fun {AssignRandomSpawn SList M}
      if M == 0 then nil
      else 
	 local E N in
	    N = {List.length SList}
	    E = {List.nth SList ({OS.rand} mod N)+1}
	    E|{AssignRandomSpawn {Remove SList E} M-1} %        {List.subtract +Xs Y ?Zs} 
	 end
      end
   end

   % Fonction qui décrémente
      %Record rec(inactive: active:)
      %Si on lui donne Id1#3 Id2#1 Id3#2
      %Il retourne rec(inactive: Id1#2 Id3#1 active:Id2#pt(x: y:))
   fun{DecGhost State}
      Rec
      fun{DecListGhost L Rec}
	 case L of Id#Time|T then
	    local Port IdCheck PCheck in
	       if Time == 1 then
            
		  Port ={List.nth PortsGhost Id.id}
		  {Send Port spawn(IdCheck PCheck)}
		  {Diffusion PortsPacman ghostPos(IdCheck PCheck)}
		  {Send WindowPort spawnGhost(IdCheck PCheck)}
		  {DecListGhost T {Record.adjoinAt Rec active IdCheck#PCheck|Rec.active}}
            
	       else {DecListGhost T {Record.adjoinAt Rec inactive Id#Time-1|Rec.inactive}}
	       end
	    end
	 []nil then Rec
	 end
      end
   in
      if State.gT == nil then
	 State
      else
	 Rec = {DecListGhost State.gT rec(active:nil inactive:nil)}
	 {AdjoinList State [posG#{List.append Rec.active State.posG}  gT#Rec.inactive]}
      end
   end

   fun{DecPacman PacToKill State}
      Rec
      fun{DecListPacman L Rec}
	 case L of Id#Time|T then         
	    local Port IdCheck PCheck in
	       if Time == 1 then
		  Port ={List.nth PortsPacman Id.id}
		  {Send Port spawn(IdCheck PCheck)}
		  local Ret in
		     {GhostOn PCheck Ret State _}
		     {Diffusion PortsGhost pacmanPos(IdCheck PCheck)}
		     {Send WindowPort spawnPacman(IdCheck PCheck)}
		     if Ret \= nil then
			{DecListPacman T {Record.adjoinAt Rec pacToKill {List.nth Ret ({OS.rand} mod {List.length Ret})+1}#Id|Rec.pacToKill}}
		     else
			{DecListPacman T {Record.adjoinAt Rec active IdCheck#PCheck|Rec.active}}
		     end
		  end          
	       else {DecListPacman T {Record.adjoinAt Rec inactive Id#Time-1|Rec.inactive}}
	       end
	    end
	 []nil then Rec
	 end
      end
   in
      if State.pacT == nil then
	 PacToKill = nil
	 State
      else
	 Rec = {DecListPacman State.pacT rec(active:nil inactive:nil pacToKill:nil)}
	 PacToKill = Rec.pacToKill
	 {AdjoinList State [posPac#{List.append Rec.active State.posPac} pacT#Rec.inactive]}
      end
   end


   

     %L = [pt1#1 pt2#5]
     %retourne rec(inactive:[pt2#4] active:[pt1])
   fun{BonusDec L P Rec} 
      case L of pt(x:_ y:_)#Time|T then
	 if Time == 1 then {P L.1.1} {BonusDec T P {Record.adjoinAt Rec active L.1.1|Rec.active}}
	 else {BonusDec T P {Record.adjoinAt Rec inactive L.1.1#Time-1|Rec.inactive}}
	 end
      []nil then Rec
      end
   end

   fun{DecPoint State}
      Rec in
      Rec = {BonusDec State.pT proc{$ Pos} {Diffusion PortsPacman pointSpawn(Pos)} {Send WindowPort spawnPoint(Pos)} end  rec(active:nil inactive:nil)}
      {AdjoinList State [posP#{List.append Rec.active State.posP} pT#Rec.inactive]}
   end

   fun{DecBonus State}
      Rec in
      Rec = {BonusDec State.bT  proc{$ Pos} {Diffusion PortsPacman bonusSpawn(Pos)} {Send WindowPort spawnBonus(Pos)} end rec(active:nil inactive:nil)}
      {AdjoinList State [posB#{List.append Rec.active State.posB} bT#Rec.inactive]}
   end

   fun{DecHunt State}
      if State.hT == 1 then 
	 {Diffusion PortsPacman setMode(classic)} 
	 {Send WindowPort setMode(classic)}
	 {Diffusion PortsGhost setMode(classic)}
	 {AdjoinList State [hT#0 m#classic]}
      else
	 if(State.hT == 0) then
	    State
	 else 
	    {AdjoinList State [hT#(State.hT-1)]}
	 end
      end
   end
   

    % Renvoie la liste posPac/posG avec un élément retiré (celui donc le <pacman>/<ghost> correspond à Id)
    % Renvoie la liste intacte si l'élément n'a pas été trouvé
   fun {Delete Id PosPlayer}
      case PosPlayer
      of (ID#pt(x:_ y:_))|T then
	 if ID==Id then T
	 else PosPlayer.1|{Delete Id T}
	 end
      []nil then nil
      end
   end


    % IdPacman : le <pacman> qui est mort
   % IdGhost : le <ghost> qui l'a tué
   % State =  state(posPac:PosPac posG:PosG posB:PosB pos:PosP m:Mode hT:HuntTime pacT:PacTime gT:GTime bT:BTime pT:PTime
   fun {KillPacman IdGhost ListPacmans State}
      PortPac
      
   in

      case ListPacmans
      of IdPacman|T then
	 PortPac = {List.nth PortsPacman IdPacman.id}
         % prévenir le pacman qu'il a été tué
	 local NewLife NewScore in
	    {Send PortPac gotKilled(_ NewLife NewScore)}
     % prévénir tous les ghosts, avec un message différent pour celui qui a tué le pacman
	    {Diffusion PortsGhost deathPacman(IdPacman)}
	    {Send {List.nth PortsGhost IdGhost.id} killPacman(IdPacman)}
       % prévenir GUI
	    {Send WindowPort hidePacman(IdPacman)}
	    {Send WindowPort scoreUpdate(IdPacman NewScore)}
	    {Send WindowPort lifeUpdate(IdPacman NewLife)}
	    if NewLife == 0 then % le pacman est définitivement mort
	       if {List.length State.posPac} == 1 andthen State.pacT == nil then % il était le seul pacman non définitvement mort
		  
		  {AdjoinList State [posPac#nil]}
	       else
		  {KillPacman ghost(id:IdGhost.id color:IdGhost.color name:IdGhost.name) T  {AdjoinList State [posPac#{Delete IdPacman State.posPac}]}}
	       end % if
	    else 
         % renvoi du State dans lequel on a retiré IdPacman de posPac et ajouté dans pacTime
	       {KillPacman ghost(id:IdGhost.id color:IdGhost.color name:IdGhost.name) T  {AdjoinList State [posPac#{Delete IdPacman State.posPac} pacT#{Append State.pacT [IdPacman#(Input.respawnTimePacman *(Input.nbPacman + Input.nbGhost))]}]}}
	    end % if
	 end %local
      [] nil then
	 State
      end
   end

   fun {KillGhost IdPacman ListGhosts State}
      PortGhost  IDp NewScore
   in
      case ListGhosts
      of IdGhost|T then
	 PortGhost = {List.nth PortsGhost IdGhost.id}
     % prévénir le ghost qu'il a été tué
	 {Send PortGhost gotKilled()}
     % prévénir tous les pacmans, avec un message différent pour celui qui a tué le ghost
	 {Diffusion PortsPacman deathGhost(IdGhost)}
	 {Send {List.nth PortsPacman IdPacman.id} killGhost(IdGhost IDp NewScore)}
	
      % prévénir GUI
	 {Send WindowPort scoreUpdate(IDp NewScore)}
	 {Send WindowPort hideGhost(IdGhost)}
     % appel récursif avec le nouveau State (State dans lequel on a retiré IdGhost de posG et ajouté dans gT)
	 {KillGhost IdPacman T
	  {AdjoinList State [posG#{Delete IdGhost State.posG} gT#{Append State.gT [IdGhost#(Input.respawnTimeGhost *(Input.nbPacman + Input.nbGhost))]}]}}
      [] nil then State
      end
   end
   /* La fonction prends un point <position> en argument, si il y en a un dans le state, elle le retire et met dans la liste à décrémenter
   si pas l'etat ne change pas et ret est bound à false */
   fun{PointOn Pt Ret State}
      if({List.member Pt State.posP}) then %Si p est dans la liste posP
	 Ret = Pt 
	 {AdjoinList State [posP#{List.subtract State.posP Pt} pT#{List.append State.pT [Pt#(Input.respawnTimePoint *(Input.nbGhost + Input.nbPacman))]}]}
      else 
	 Ret = nil %Attention peutêtre à changer
	 State
      end
   end

   /*Meme principe que pointOn */
   fun{BonusOn Pt Ret State}
      if({List.member Pt State.posB}) then %Si Pt est dans la liste posB
	 Ret = Pt  
	 {AdjoinList State [posB#{List.subtract State.posB Pt} bT#{List.append State.bT [Pt#(Input.respawnTimeBonus *(Input.nbGhost + Input.nbPacman))]}]}
      else 
	 Ret = nil %Attention peutêtre à changer
	 State
      end
   end
 
% La fonction prend un point en arguement et retourne la liste des ghost sur cette case. L'etat n'est pas modifié
   fun{GhostOn Pos Ret State} 
      fun{GhostOnLoop Pos List}
	 case List of Id#pt(x:X y:Y)|T then
	    if(X == Pos.x andthen Y == Pos.y) then Id|{GhostOnLoop Pos T}
	    else {GhostOnLoop Pos T}
	    end
	 []nil then nil
	 end
      end
   in 
      Ret = {GhostOnLoop Pos State.posG}
      State
   end

   /* Meme principe que GhostOn */
   fun{PacmanOn Pos Ret State} %On ne retire pas les pacman de l'état, l'état n'est pas modifié
      fun{PacmanOnLoop Pos List}
	 case List of Id#pt(x:X y:Y)|T then
	    if(X == Pos.x andthen Y == Pos.y) then Id|{PacmanOnLoop Pos T}
	    else {PacmanOnLoop Pos T}
	    end
	 []nil then nil
	 end
      end
   in 
      Ret = {PacmanOnLoop Pos State.posPac}
      State
   end

    %Un point est gagné, toutes les actions correspondantes sont réalisées.
   fun{WinPoint Id Point State}
      IdCheck NewScore in
      {Send WindowPort hidePoint(Point)}
      {Diffusion PortsPacman pointRemoved(Point)}
      {Send {List.nth PortsPacman Id.id} addPoint(Input.rewardPoint ?IdCheck ?NewScore)}
      {Wait IdCheck}
      {Wait NewScore}
      {Send WindowPort scoreUpdate(IdCheck NewScore)}
      State
   end

    %Un bonus est attrapé, toutes les actions correspondantes sont réalisées.
   fun{WinBonus Bonus State}
      {Send WindowPort hideBonus(Bonus)}
      {Diffusion PortsPacman bonusRemoved(Bonus)}
      {Diffusion PortsPacman setMode(hunt)}
      {Diffusion PortsGhost setMode(hunt)}
      {Send WindowPort setMode(hunt)}
      {AdjoinList State [m#hunt hT#(Input.huntTime * (Input.nbGhost + Input.nbPacman))]}
   end

   fun{HuntMode Mode State}
      Mode = State.m
      State
   end

   fun{WhoWin State}
      Vainqueur
      fun{PointMax Max MaxId List}
	 ID NewScore in
	 case List of H|T then
	    {Send H addPoint(0 ID NewScore)}
	    {Wait ID}
	    {Wait NewScore}
	    if(NewScore > Max) then  {PointMax NewScore ID T}
	    else {PointMax Max MaxId T}
	    end
	 []nil then MaxId
	 end
      end
   in
      Vainqueur ={PointMax ~((Input.nbLives)*(Input.penalityKill))-1 nil PortsPacman}
      {Send WindowPort displayWinner(Vainqueur)}
      State
   end

   /*Demande au pacman sa nouvelle position,
   préviens les ghost et le déplace sur la map*/
   % Id est de type <pacman>
   fun{MovePacman Id NewPos State}
      IdCheck in
      {Send {List.nth PortsPacman Id.id} move(IdCheck NewPos)}
      {Wait IdCheck}
      {Wait NewPos}
      if(IdCheck == null) then
	 State
      else
	 {Diffusion PortsGhost pacmanPos(IdCheck NewPos)}
	 {Send WindowPort movePacman(IdCheck NewPos)}
	 {AdjoinList State [posPac#{Append {Delete IdCheck State.posPac} [IdCheck#NewPos]}]}
      end
   end

   fun{MoveGhost Id NewPos State}
      IdCheck in
      {Send {List.nth PortsGhost Id.id} move(IdCheck NewPos)}
      {Wait IdCheck}
      {Wait NewPos}
      if(IdCheck == null) then
	 State
      else
	 {Diffusion PortsPacman ghostPos(IdCheck NewPos)}
	 {Send WindowPort moveGhost(IdCheck NewPos)}
	 {AdjoinList State [posG#{Append {Delete IdCheck State.posG} [IdCheck#NewPos]}]}
      end
   end

   proc {ServerProc Msg State}

      case Msg
      of decPacman(PacToKill)|T then {ServerProc T {DecPacman PacToKill State}} 
      [] decGhost|T then {ServerProc T {DecGhost State}} %Flo c'est fait
      [] decPoint|T then {ServerProc T {DecPoint State}}%Flo c'est fait
      [] decBonus|T then {ServerProc T {DecBonus State}}%Flo c'est fait
      [] decHunt|T then {ServerProc T {DecHunt State}}%Flo c'est fait
      [] movePacman(Id ?NewPos)|T then {ServerProc T {MovePacman Id NewPos State}} 
      [] moveGhost(Id ?NewPos)|T then {ServerProc T {MoveGhost Id NewPos State}}
      [] huntMode(Mode)|T then {ServerProc T {HuntMode Mode State}} %Flo c'est fait
      [] ghostOn(Pos ?List)|T then {ServerProc T {GhostOn Pos ?List State}} % Flo c'est fait
      [] pacmanOn(Pos ?List)|T then {ServerProc T {PacmanOn Pos ?List State }} % Flo c'est fait
      [] pointOn(Pos ?Point)|T then {ServerProc T {PointOn Pos Point State}} %Flo c'est fait
      [] killPacman(IdGhost ListPacmans)|T then {ServerProc T {KillPacman IdGhost ListPacmans State}}%IdPacman c'est la victime Messages a envoyer voir commentaires + retirer pacman de posP + ajouter dans pacTime (en focntion du nombre de vie qu'il a)    [] pointOn(Pos ?Point)|T then {ServerProc T {PointOn Pos ?Point State}} %Flo c'est fait
      [] winPoint(Id Point )|T then {ServerProc T {WinPoint Id Point State }}  %Flo c'est fait
      [] bonusOn(Pos ?Point)|T then {ServerProc T {BonusOn Pos ?Point State }} %Flo c'est fait
      [] winBonus(Bonus)|T then {ServerProc T {WinBonus Bonus State}} %Flo c'est fait
      [] killGhost(IdPacman ListGhosts) |T then {ServerProc T {KillGhost IdPacman ListGhosts State}}
      [] whoWin|T then {ServerProc T {WhoWin State}} %Flo ok
      [] endOfGame(?B)|T then B = State.posPac == nil andthen State.pacT == nil {ServerProc T State}

      end
   end


   proc{ClientFonc Msg Server}
      if(Msg == 0) then
	 for I in Sequence do % Sequence =  id ghost et id pacmans melanges
		
	    local PacToKill in

	       {Send Server decPacman(PacToKill)} %TODO 
	       {Wait PacToKill}
	       for I in PacToKill do
		  {Send Server killPacman(I.1 [I.2])}

	       end
	    end
	    
	    {Send Server decGhost}
	    {Send Server decPoint}
	    {Send Server decBonus}
	    {Send Server decHunt}

	    case I of pacman(id:_ color:_ name:_) then
	       local NewPos in
		  {Send Server movePacman(I NewPos)}
		  if(NewPos \= null) then
		     local Mode in
			{Send Server huntMode(Mode)}
			if(Mode == classic) then
			   local Liste in
			      {Send Server ghostOn(NewPos Liste)}
			      if(Liste \= nil) then
				 local IdGHost in
				    IdGHost ={List.nth Liste ({OS.rand} mod {List.length Liste})+1}
				    {Send Server killPacman(IdGHost [I])} /*IdGhost =  Un random sur un élément de la liste pour savoir qui on prends*/

				 end % local
			      end % if
			   end %  local
			else %mode hunt
			   local Liste in
			      {Send Server ghostOn(NewPos Liste)}
			      if(Liste \= nil) then
				 {Send Server killGhost(I Liste)}
			      end % if
			   end % local
			end % if-else
       %Points et bonus
			local Point Bonus in
			   {Send Server pointOn(NewPos Point)}
			   if (Point \= nil) then
			      {Send Server winPoint(I Point)} % Faire gager le point + prévenir les autre + update + aller voir commentaires
			   end % if
			   {Send Server bonusOn(NewPos Bonus)}
			   if (Bonus \= nil) then
			      {Send Server winBonus(Bonus)}
			   end % if
			end % local
		     end % local Mode
		  end %If pos != null
	       end % local NewPos
	    []ghost(id:_ color:_ name:_) then
	       local NewPos in
		  {Send Server moveGhost(I ?NewPos)}
		  if(NewPos \= null) then
		     local Mode in
			{Send Server huntMode(Mode)}
			if (Mode==classic) then
			   local Liste in
			      {Send Server pacmanOn(NewPos Liste)}
			      if(Liste \= nil) then
				 {Send Server  killPacman(I Liste)} %La meme qu'au dessus dans case pacman


			      end % if
			   end % local
			else % Mode hunt
			   local Liste in
			      {Send Server pacmanOn(NewPos ?Liste)}
			      if(Liste \= nil) then
                      %-> Random dans la liste le tueur.
				 {Send Server killGhost({List.nth Liste ({OS.rand} mod {List.length Liste})+1} [I])}%La meme qu'au dessus
			      end % if
			   end % local
			end % if-else
		     end % local Mode
		  end % if NewPos \= nil
	       end %local new pos
	    end%end case pacman/ghost
	 end%end for    

	 local B in 
	    {Send Server endOfGame(B)}
	    if(B) then 
	       {ClientFonc 1 Server}
	    else
	       {ClientFonc 0 Server}

	    end
	 end

      else %[] 1 then %fin du jeu
	 {Send Server whoWin}
	 {Delay 5000} % Ici il recommence Clientfonc et je ne vois pas pourquoi il fait ça
      end %end of cas
   end%end fun

   fun {NewPortObjectServer PosPac PosG PosP PosB Mode HuntTime PacTime GTime BTime PTime}
      Stream Port
   in
      Port = {NewPort Stream}
      thread
	 {ServerProc Stream state(posPac:PosPac posG:PosG posB:PosB posP:PosP m:Mode hT:HuntTime pacT:PacTime gT:GTime bT:BTime pT:PTime)}
      end
      Port
   end

   thread
      % Create port for window
      WindowPort = {GUI.portWindow}

      % Open window
      {Send WindowPort buildWindow}

      % TODO complete
            %Create Ports
      PortsPacman = {CreatePortPacman} % Liste de ports pour les pacmans
      PortsGhost = {CreatePortGhost} % Liste de ports pour les ghosts
      {Wait PortsPacman}
      {Wait PortsGhost}

      IdPacman = {CreateIDs PortsPacman} % Liste des <pacman> IDs
      IdGhost = {CreateIDs PortsGhost} % Liste des <ghost> IDs
      Sequence = {Shuffle IdPacman IdGhost} % Liste avec tous les pacmans et les ghosts dans un ordre aléatoire


      MapRecord = {ListMap PortsPacman}
      {Wait MapRecord}
      PointList = MapRecord.pl
      WallList = MapRecord.wl
      PSList = MapRecord.psl % pacman spawn list
      GSList = MapRecord.gsl % ghost spawn list
      BonusList = MapRecord.bl
      
           % Assignation des spawns pour les pacmans et ghosts
      local N M in
	 N = {List.length PSList}
	 M = Input.nbPacman
	 if M mod N == 0 then
	    PSList2 = {InitSList PSList (M div N) nil}
	    ListSpawnPacman = {AssignRandomSpawn PSList2 M}
	 else
	    PSList2 = {InitSList PSList (M div N)+1 nil}
	    ListSpawnPacman = {AssignRandomSpawn PSList2 M}
	 end
      end


      local N M in
	 N = {List.length GSList}
	 M = Input.nbGhost
	 if M mod N == 0 then
	    GSList2 = {InitSList GSList (M div N) nil}
	    ListSpawnGhost = {AssignRandomSpawn GSList2 M}
	 else
	    GSList2 = {InitSList GSList (M div N)+1 nil}
	    ListSpawnGhost = {AssignRandomSpawn GSList2 M}
	 end
      end
      % Initialisation des pacmans et ghosts
      % Initialisation des spawns pour les pacmans et les ghosts
      % Affichage des pacmans et des ghosts

      if {List.length PortsPacman} > 1 then
	 for Port in PortsPacman do
	    local R S in
	       {Send Port getId(R)}
	       {Wait R}
	       {Send WindowPort initPacman(R)}
	       S = {List.nth ListSpawnPacman R.id}
	       {Send Port assignSpawn(S)}
	       {Send Port spawn(_ _)} % verifier valeurs?
	       {Send WindowPort spawnPacman(R S)}
	       {Diffusion PortsGhost pacmanPos(R S)} % Diffusion du spawn aux ghosts
	    end
	 end
      else
	 local S in % vérifier qu'il y a toujours au minimum un spawn possible?
	    {Send WindowPort initPacman(IdPacman.1)}
	    S = {List.nth PSList ({OS.rand} mod {List.length PSList})+1}
	    {Send PortsPacman.1 assignSpawn(S)}
	    %local ID NewLife NewScore in
	       % {Send PortsPacman.1 gotKilled(IdPacman.1 NewLife NewScore)}
	       % {Wait NewLife}
	       % {Wait NewScore}
	    %end
	    {Send PortsPacman.1 spawn(_ _)}
	    {Send WindowPort spawnPacman(IdPacman.1 S)}
	    {Diffusion PortsGhost pacmanPos(IdPacman.1 S)} % Diffusion du spawn aux ghosts
	 end %TODO Verifier les valeurs ID et P
      end

      if ({List.length PortsGhost} > 1) then
	 for Port in PortsGhost do
	    local R S in
	       {Send Port getId(R)}
	       {Send WindowPort initGhost(R)}
	       S = {List.nth ListSpawnGhost R.id} 
	       {Send Port assignSpawn(S)}
	       {Send Port spawn(_ _)} % TODO : vérifier les valeurs ID et P
	       {Send WindowPort spawnGhost(R S)}
	       {Diffusion PortsPacman ghostPos(R S)} % Diffusion du spawn aux pacmans
	    end
	 end
      else
	 local S in
	    {Send WindowPort initGhost(IdGhost.1)}
	    S = {List.nth ListSpawnGhost ({OS.rand} mod {List.length GSList})+1 }
	    {Send PortsGhost.1 assignSpawn(S)}
	    {Send PortsGhost.1 spawn(_ _)}
	    {Send WindowPort spawnGhost(IdGhost.1 S)}
	    {Diffusion PortsPacman ghostPos(IdGhost.1 S)} % Diffusion du spawn aux pacmans
	 end
      end

      if(Input.isTurnByTurn) then
	 local
	    PosPac PosG in
	    PosPac = {SpawnToIdPos IdPacman ListSpawnPacman} 
	    PosG = {SpawnToIdPos IdGhost ListSpawnGhost}
	    Server = {NewPortObjectServer PosPac PosG PointList BonusList classic 0 nil nil nil nil } % à compléter
              % {NewPortObjectServer PosP PosG PosPo PosB Mode HuntTime PacTime GTime BTime PTime}
	 end %local
	 {ClientFonc 0 Server}

      %MODE SIMULATNE MODE SIMULTANE MODE SIMULTANE
      else
	 local PosPac PosG in
	    PosPac = {SpawnToIdPos IdPacman ListSpawnPacman}
	    PosG = {SpawnToIdPos IdGhost ListSpawnGhost}
	    Server = {Controller state(posPac:PosPac posG:PosG posB:BonusList posP:PointList m:classic pin:IdPacman)}
	 end
	 {InitClient IdPacman pacman} % InitPacman = liste des IDs des pacmans
	 {InitClient IdGhost ghost}
 
	    
      end

   end

end
