
functor
import
   GUI
   Input
   PlayerManager
   Browser
   OS
define
   CreatePortPacman
   CreatePortGhost
   CreateIDs
   Shuffle
   ListMap
   AssignRandomSpawn
   DecListPacman
   DecListGhost
   BonusDec

   WindowPort

   PortsPacman
   PortsGhost
   IdPacman
   IdGhost
   MapRecord

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

   Diffusion
   Mult
   InitSList
   Remove
   AssignRandomSpawn
   
in

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
   In : Liste de port et le message à diffuser
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

   % Fonction qui décrémente
      %Record rec(inactive: active:)
      %Si on lui donne Id1#3 Id2#1 Id3#2
      %Il retourne rec(inactive: Id1#2 Id3#1 active:Id2#pt(x: y:))
   fun{DecListGhost L Rec}
      case L of Id#Time|T then
   	 if Time == 1 then
   	    local Port IdCheck PCheck in
   	       Port ={List.nth PortsGhost Id.id}
   	       {Send Port spawn(IdCheck PCheck)}
      	       %Faut il verifier les valeurs de retour ? On sait peut-être mettre un symbole pour ne pas recuperer IdCheck
	       % le $ ne fonctionne pas dans ce cas la
   	       {Diffusion PortsPacman ghostPos(IdCheck PCheck)}
   	       {Send WindowPort spawnGhost(IdCheck PCheck)}
   	       {DecListGhost T {Record.adjoinAt active IdCheck#PCheck|Rec.active}}
   	    end
   	 else {DecListGhost T {Record.adjoinAt Rec inactive IdCheck#Time-1|Rec.inactive}}
   	 end
      []nil then Rec
      end
   end

      %Meme principe que decListGhost
   fun{DecListPacman L Rec}
      case L of Id#Time|T then
   	 if Time == 1 then
   	    local Port IdCheck PCheck in
   	       Port ={List.nth PortsPacman Id.id}
   	       {Send Port spawn(IdCheck PCheck)}
      	       %Faut il verifier les valeurs de retour ? On sait peut-être mettre un symbole pour ne pas recuperer IdCheck
	       % le $ ne fonctionne pas dans ce cas la
   	       {Diffusion PortsGhost pacmanPos(IdCheck PCheck)}
   	       {Send WindowPort spawnPacman(IdCheck PCheck)}
   	       {DecListPacman T {Record.adjoinAt active IdCheck#PCheck|Rec.active}}
   	    end
   	 else {DecListPacman T {Record.adjoinAt Rec inactive IdCheck#Time-1|Rec.inactive}}
   	 end
      []nil then Rec
      end
   end

      %L = [pt1#1 pt2#5]
      %retourne rec(inactive:[pt2#4] active:[pt1])
   fun{BonusDec L P Rec} %Teste individuellement ca fonctionne
      case L of Pos#Time|T then
   	 if Time == 1 then {P Pos} {BonusDec T P {Record.adjoinAt Rec active Pos|Rec.active}}
   	 else {BonusDec T P {Record.adjoinAt Rec inactive Pos#Time-1|Rec.inactive}}
   	 end
      []nil then Rec
      end
   end


   /* state(who:QuiVAJouer posP: PositionDesPacmans posG: PositionGhost posB:Listepositiondesbonus posP:Listepositionpoints mode: Mode(0=normal 1 =hunt) huntTime:(-1 -> on fait rien, 0 on swich mode vers normal, X = nb de tours restants) pacTime: (liste de pt + nombre de tours) gTime: pointTime: bTime:)
   */

   fun{Play State}
      local State1 State2 in
         %Verification HuntTime
   	 case State.huntTime of 1 then
   	    {Diffusion PortsPacman setMode(classic)}
   	    {Send WindowPort setMode(classic)}
   	    {Diffusion PortsGhost setMode(classic)}
   	    State1 = {AdjoinList State [huntTime#0 mode#0]}
   	 [] 0 then
   	    State1 = {AdjoinList State [huntTime#0 mode#0]}
   	 else
   	    State1 = {AdjoinList State [huntTime#State.huntTime-1 mode#1]}
   	 end
         %Décremente pacTime - gTime - bonus et point.
   	 local PacRecord GRecord BTimeProc BRecord PointTimeProc PRecord in

   	    PacRecord = {DecListPacman State1.pacTime rec(active:nil inactive:nil)}

   	    GRecord = {DecListGhost State1.gTime GTimeProc rec(active:nil inactive:nil)}

   	    proc{BTimeProc Pos}
   	       {Diffusion PortsPacman bonusSpawn(Pos)}
   	       {Send WindowPort spawnBonus(P)}
   	    end
   	    BRecord = {BonusDec State.bTime BTimeProc rec(active:nil inactive:nil)}

   	    proc{PointTimeProc Pos}
   	       {Diffusion PortsPacman pointSpawn(Pos)}
   	       {Send WindowPort spawnPoint(P)}
   	    end
   	    PRecord = {BonusDec State.pointTime PointTimeProc rec(active:nil inactive:nil)}


   	    State2 = {AdjoinList State1 [posP#{List.append PacRecord.active State1.posP} posG#{List.append GRecord.active State1.posG} posB#{List.append BRecord.active State1.posB} posP#{List.append PRecord.active State1.posP} pacTime#PacRecord.inactive gTime#GRecord.inactive pointTime#PRecord.inactive bTime#BRecord.inactive]}
   	 end

         %Separer en fonction pacman ou ghost
         %Move ...
   	 case {List.nth Sequence State2.who} of pacman(id:Id color:_ name:_) %_ pour dire qu'on ne veux pas stocker Color
   	 %TODO
   	 []ghost(id:Id color:_ name:_)
   	 %Todo
   	 end %End case pacman/ghost
      end%endlocal
   end%end Play

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
	 local E L N in
	    N = {List.length SList}
	    E = {List.nth SList ({OS.rand} mod N)+1}
	    E|{AssignRandomSpawn {Remove SList E} M-1} %        {List.subtract +Xs Y ?Zs} 
	 end
      end
   end


   proc {ServerProc Msg State}
      case Msg 
      of decrementer|T then {ServerProc T {Decrementer State}} %Flo
      [] movePacman(Id ?NewPos)|T then {ServerProc T {MovePacman State}} %TODO %Noemie
      [] huntMode(Mode)|T then {ServerProc T {HuntMode State}} % Noémie (dit s'il est en mode hunt ou pas)
      [] changeMode|T then {ServerProc T {ChangeMode State}} %Noemie
      [] ghostOn{Pos ?List}|T then {ServerProc T {GhostOn State}}%Parcours posG, retourne une liste des <ghost> sur cette case.
      [] killPacman(IdPacman IdGhost ?endOfGame)|T then {ServerProc T {KillPacman State}}%IdPacman c'est la victime Messages a envoyer voir commentaires + retirer pacman de posP + ajouter dans pacTime (en focntion du nombre de vie qu'il a)
      [] pointOn(Pos ?Point)|T then {ServerProc T {PointOn State}}
      [] winPoint(Id Point)|T then {ServerProc T {WinPoint State}}
      [] winBonus(Id Bonus)|T then {ServerProc T {WinBonus State}}
      [] bonusOn(Pos ?Point)|T then {ServerProc T {BonusOn State}}
      [] killGhost(IdPacman ListGhosts) |T then {ServerProc T {KillGhost State}}
      [] pacmanOn(Pos ?List)|T then {ServerProc T {PacmanOn State}}
      [] whoWin(?Vainqueur)|T then {ServerProc T {WhoWin State}}
      end
   end

   fun {ClientFonc Msg}
      case Msg
      of 0 then
	 {Send Server decrementer}
	 for I in Sequence do % Sequence =  id ghost et id pacmans melanges
	    case I
	    of pacman(id:Id color:_ name:_) then
	       local NewPos in
		  {Send Server movePacman(Id NewPos)} %BOUGER PACMAN
               %Envoyer au server {Send Server movePacman(Id ?NewPos)} -> {Send Port move(IdCheck Pos)}
	       % Port = {List.nth PortsPacman Id} (GhostS) pacmanPos(ID P) + GUI movePacman(ID P) + Change l'etat -> liste des pacmans s'actualise posP
               %Case if IdCheck == null -> le pacman est mort -> on s'arrete la.
		  if(NewPos != null) then
		     local Mode in
			{Send Server huntMode(Mode)}
			if(Mode == classic) then
			   local List in
			      {Send Server ghostOn(NewPos List)}
			      if(List ~= nil) then
			      %Killer = take random de List.
				 local endOfGame in
				    {Send Server killPacman(Id /*IdGhost*/ endOfGame)}
				 %IdPacman c'est la victime Messages a envoyer voir commentaires + retirer pacman de posP + ajouter dans pacTime
				    if(endOfGame) then
				       {ClienFonc 1}
				    end
				 end
			      end
			   end
			else %mode hunt
			   local List in
			      {Send Server ghostOn(NewPos List)}
			      if(List != nil) then
				 {Send Server killGhost(IdPacman List)}
			      %-> les ghost meurent, tous les messgaes dans commentaires +  retirer ghosts de posG + ajouter dans Gtime
			      end
			   end
			end
		     %Points et bonus
			local Point in
			   {Send Server pointOn(NewPos Point)}
			% PointOn : s'il y a un point sur la case il le retire de la liste(et le renvoie) l'ajoute dans les points à respawn
			   if Point ~= nil then %ou null ?
			      {Send Server winPoint(Id Point)} % Faire gager le point + prévenir les autre + update + aller voir commentaires
			   end
			end
			local Bonus in
			   {Send Send bonusOn(NewPos Bonus)}
			% BonusOn : s'il y a un point sur la case il le retire de la liste(et le renvoie) l'ajoute dans les points à respawn
			   if Bonus ~= nil then %ou null ?
			      {Send Server winBonus(Id Bonus)} % Faire gager le point + prévenir les autre + updateLaListeDesBonus + mode(hunt)
			   % + remettre le temps a temps hunt + aller voir commentaires
			   end
			end
		     end
		  end %If pos ! null
	       end % end local NewPos
	    []ghost(id:Id color:_ name:_) then
	       local NewPos in
	       %BOUGER GHOST
		  {Send Server moveGhost(Id ?NewPos)
               % -> {Send Port move(IdCheck Pos)} Port = {List.nth PortsGhost Id}voir messages dans commentaires
		% + Change l'etat -> liste des ghost s'actualise posG
                %Case if IdCheck == null -> le ghost est mort -> on s'arrete la.
		   if(NewPos ~= nil) then
		      local Mode in
			 {Send Server huntMode(Mode)}
			 if (Mode==classic) then
			    local List in
			       {Send Server pacmanOn(NewPos List)}
			       if(List ~= nil) then
				  local endOfGame in
				     {Send Server  killPacman(Id List endOfGame)} %La meme qu'au dessus dans case pacman
				     if(endOfGame) then
					{ClienFonc 1}
				     end
				  end
			       end
			    end
			 else % Mode hunt
			    local List in
			       {Send Server pacmanOn(NewPos ?List)}
			       if(List ~= nil) then
			       %-> Random dans la liste le tueur.
				  {Send Server killGhost(IdPacman List)}%La meme qu'au dessus
			       end
			    end
			 end
		      end
		   end
		  end 
	       end
	    end
	 end % end for
	 local X in
	    {Send Server fin(X)}
	    if X == true then {ClientProc 1}
	    else
	       {ClientProc 0}
	    end
	 end
      [] 1 then %fin du jeu
	 local Vainqueur in
	    {Send Server whoWin(Vainqueur)}
	 end
      end
   end

   fun {NewPortObjectServer PosP PosG PosPo PosB Mode HuntTime PacTime GTime BTime PTime}
      Stream Port
   in
      {NewPort Stream Port}
      thread
	 {ServerProc Stream state(posPac:PosPac posG:PosG posB:PosB pos:PosP m:Mode hT:HuntTime pacT:PacTime gT:GTime bT:BTime pT:PTime)}
	 /*
	 posPac : <pacman>#<position>|T
	 posG : <ghost>#<position>|T
	 posB :  <position>|T
	 m: <mode> = classic|hunt
	 ht : nombre
	 pacT : <pacman>#nombre|T
	 gT : <ghost>#nombre|T
	 bT : <position>#nombre|T
	 gT : <position>#nombre|T
	 */
      end
      Port
   end
   
    
   thread
      % Create port for window
      WindowPort = {GUI.portWindow}
      % Open window
      {Send WindowPort buildWindow}

      %Create Ports
      PortsPacman = {CreatePortPacman} % Liste de ports pour les pacmans
      PortsGhost = {CreatePortGhost} % Liste de ports pour les ghosts

      IdPacman = {CreateIDs PortsPacman} % Liste des <pacman> IDs
      IdGhost = {CreateIDs PortsGhost} % Liste des <ghost> IDs
      Sequence = {Shuffle IdPacman IdGhost} % Liste avec tous les pacmans et les ghosts dans un ordre aléatoire

      MapRecord = {ListMap PortsPacman}
      PointList = MapRecord.1
      WallList = MapRecord.2
      PSList = MapRecord.3 % pacman spawn list
      GSList = MapRecord.4 % ghost spawn list
      BonusList = MapRecord.5

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
	 for I in 1..{List.length PortsPacman} do
	    local R ID P S Port in
	       Port = {List.nth PortsPacman I}
	       {Send Port getId(R)}
	       {Send WindowPort initPacman(R)}
	       S = {List.nth ListSpawnPacman I}
	       {Send Port assignSpawn(S)}
	       {Send Port spawn(ID P)} % verifier valeurs?
	       {Send WindowPort spawnPacman(R S)}
	       {Diffusion PortsGhost pacmanPos(R S)} % Diffusion du spawn aux ghosts
	    end
	 end
      else
	 local ID P S in % vérifier qu'il y a toujours au minimum un spawn possible?
	    {Send WindowPort initPacman(IdPacman.1)}
	    S = {List.nth PSList ({OS.rand} mod {List.length PSList})+1}
	    {Send PortsPacman.1 assignSpawn(S)}
	    {Send PortsPacman.1 spawn(ID P)}
	    {Send WindowPort spawnPacman(IdPacman.1 S)}
	    {Diffusion PortsGhost pacmanPos(IdPacman.1 S)} % Diffusion du spawn aux ghosts
	 end %TODO Verifier les valeurs ID et P
      end

      if ({List.length PortsGhost} > 1) then
	 for I in 1..{List.length PortsGhost} do
	    local R ID P S Port in
	       Port = {List.nth PortsGhost I}
	       {Send Port getId(R)}
   	       {Send WindowPort initGhost(R)}
   	       S = {List.nth ListSpawnGhost I} 
   	       {Send Port assignSpawn(S)}
   	       {Send Port spawn(ID P)} % TODO : vérifier les valeurs ID et P
	       {Send WindowPort spawnGhost(R S)}
	       {Diffusion PortsPacman ghostPos(R S)} % Diffusion du spawn aux pacmans
	    end
	 end
      else
	 local ID P S in
	    {Send WindowPort initGhost(IdGhost.1)}
	    S = {List.nth ListSpawnGhost}
	    {Send PortsGhost.1 assignSpawn(S)}
	    {Send PortsGhost.1 spawn(ID P)}
	    {Send WindowPort spawnGhost(IdGhost.1 S)}
	    {Diffusion PortsPacman ghostPos(IdGhost.1 S)} % Diffusion du spawn aux pacmans
         end
      end

      % MODE TURN BY TURN
      Server={NewPortObjectServer ServerProc ...} % à compléter
      % {NewPortObjectServer PosP PosG PosPo PosB Mode HuntTime PacTime GTime BTime PTime}
     


	 
%Une fonction que l'on appelle récursivement.
%     Prends en argument un state et retourne un state.
%     Le record state contiendrait:
%         %Un champ qui nous permettrait de savoir quel est le joueur (À qui le tour par exemple pacman1) : c'est un nombre, incrémenté (avec modulo) et on appelle le n-eme nombre de la liste pour jouer.
%         %Plusieurs champs, un par pacman avec sa position.
%         %Plusieurs champs, un par ghost avec sa position.
%         %Liste avec les positions des  bonus
%         %Liste avec les positions des points
%         %Mode du jeu
%         %Un champ que l'on décrémente avec le hunt time. Quand il vaut 1-> le mode est mis à normal et on passe la valeur à 0 pour dire qu'il ne faut rien faire.
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimePoint (Quand il vaut 0 -> On spawn un nouveau point) Cas particulier: plus de place sur la board.
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimeBonus (Quand il vaut 0 -> On spawn un nouveau point) Cas particulier: plus de place sur la board.
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimePacman (Quand un pacman meurt on le met à respawnTimePacman et on décrémente quand c'est égal à 2 on respawn le pacman.)
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimeGhost
%     Etapes de cette fonction.
%       %
%       %Décrementer ce qui doit l'etre (respawnTime...(5)
%              %Si certaines valeurs sont arrivée au bout -> faire les actions correspondante
%              %Quand un pacman(resussite) de respawnTimePacman arrive à 0 -> (ressusite) spawn(?ID ?P) + (Ghosts) PacmanPos() +GUI spawnPacman(ID P)
%              %Quand un ghost(resussite) de respawnTimePacman arrive à 0 -> (ressusite) spawn(?ID ?P) + (PacmanS) PacmanPos() +GUI spawnGhost(ID P)
%              %Quand le respawnTimeBonus arrive à échéance -> (Pacmans) bonusSpawn(P) + GUI spawnBonus
%              %Quand le respawnTimePoint arrive à échéance -> on random une position libre pour le point. (Pacmans) pointSpawn(P)+ GUI spawnPoint(P)
%              %Quand le huntTime arrive à échéance -> Tous( GUI + Pacmans + GhostS) setMode(Normal)
%       %__________________________
%       %Si le joueur est un pacman
%       %(Joueur) move(?ID ?P)  %On envoie au joueur move(?ID ?P)
%       %(GhostS) pacmanPos(ID P) + GUI movePacman(ID P)
%
%         %Si mode normal
%               %Parcourir la liste des fantomes, si il y en à un sur la même case(Je l'appelle le tueur):
%                       %GUI: hidePacman(Joueur) + Joueur : gotKilled(?ID ?NewLife) + Gui = lifeUpdate(ID NewLife) +
%                       % deathPacman(ID) (GhostS) + (Tueur) killPacman(ID)   + scoreUpdate(ID NewScore) (Joueur).
%                               %Si NewLife == 0 Il est mort.
%                                        %Si il est le dernier en jeu : % Je ne sais pas encore comment savoir ça.
%                                                     %displayWinner(ID)
%                                                     %Finir la fonction ici.
%                                        %Si pas il faudra le retirer des listes/Ou bien l'ingnorer -> Pas encore bcp d'idées.
%                                %Si NewLife =! 0

%                       %Ajouter dans la liste contenant les pacmans qui sont mort  respawnPacmanList.
%                       %
%                       %Cas particulier à aprofondir, plusieurs ghost sur une même case qui prends le point.
%         %Si mode Hunt.
%               %Le pacman est sur la case d'un ghost(victime)
%               % (Victime) gotKilled() + (PacmanS) deathGhost(ID) +(Joueur) killGhost(ID).
%               %   + scoreUpdate(ID NewScore) (Joueur).
%               % (GUI-) HideGhost(Victime).
%               % L'ajouter dans la liste contenant les ghost qui doivent respawn.

      %Si il y à point sur la case courrante. %On prends quand même le point si le pacman va se faire tuer ?
%               hidePoint(P) (GUI)+ pointRemoved(P) (PacmanS) + addPoint(Add ?ID ?NewScore) (Joueur)  + scoreUpdate(ID NewScore) (Joueur).
%
%         %Vérifier si il y à un bonus sur la case. %Pareil comment réagir si il y à 1 ghost et un bonus sur la même case
%               hideBonus(P) (GUI)+ bonusRemoved(P) (PacmanS) + setMode(Add ?ID ?NewScore) (PacmanS + GhostS + GUI).
%               %le champ correspondant à Hunt time est mis à hunt time de l'input.

%       %_________________________
%       %Si le joueur est un ghost
%       %(Joueur) move(?ID ?P)
%       %(PacmanS) ghostPos(ID P) + GUI moveGhost(ID P)
%         %Si mode normal
%               %Parcourir la liste des pacmans, si il y en à un sur la même case(Je l'appelle victime):
%                       %GUI: hidePacman(Victime) + Victime : gotKilled(?ID ?NewLife) + Gui = lifeUpdate(ID NewLife) +
%                       % deathPacman(ID) (GhostS) + (Joueur) killPacman(ID)  + scoreUpdate(ID NewScore) (Victime).
%                               %Si NewLife == 0 Il est mort.
%                                        %Si il est le dernier en jeu : % Je ne sais pas encore comment savoir ça.
%                                                     %displayWinner(ID)
%                                                     %Finir la fonction ici.
%                                        %Si pas il faudra le retirer des listes/Ou bien l'ingnorer -> Pas encore bcp d'idées.
%                                %Si NewLife =! 0

%                       %Ajouter dans la liste contenant les pacmans qui sont mort  respawnPacmanList.
%                       %
%                       %Cas particulier à aprofondir, plusieurs ghost sur une même case qui prends le point.
%         %Si mode Hunt.
%               %Le pacman(Tueur) est sur la case d'un ghost(Joueur)
%               % (Joueur) gotKilled() + (PacmanS) deathGhost(ID) +(Tueur) killGhost(ID).
%               % (GUI-) HideGhost(Victime).  + scoreUpdate(ID NewScore) (Tueur).
%               % L'ajouter dans la liste contenant les ghost qui doivent respawn.




   end % end du thread
end % end du in



