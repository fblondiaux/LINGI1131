functor
import
   GUI
   Input
   PlayerManager
   Browser
   OS
   System
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
in
   
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

   fun{DecPacman State}
      Rec
      fun{DecListPacman L Rec}
	 case L of Id#Time|T then
            
	    local Port IdCheck PCheck in
	       if Time == 1 then
		  Port ={List.nth PortsPacman Id.id}
		  {Send Port spawn(IdCheck PCheck)}
		  {Diffusion PortsGhost pacmanPos(IdCheck PCheck)}
		  {Send WindowPort spawnPacman(IdCheck PCheck)}
		  {DecListPacman T {Record.adjoinAt Rec active IdCheck#PCheck|Rec.active}}
                  
	       else {DecListPacman T {Record.adjoinAt Rec inactive Id#Time-1|Rec.inactive}}
	       end
	    end
	 []nil then Rec
	 end
      end
   in
      if State.pacT == nil then
	 State
      else
	 Rec = {DecListPacman State.pacT rec(active:nil inactive:nil)}
	 {AdjoinList State [posP#{List.append Rec.active State.posP} pacT#Rec.inactive]}
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
	 {AdjoinList State [hT#0]}
      else
	 if(State.hT == 0) then
	    State
	 else 
	    {AdjoinList State [hT#State.hT-1]}
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
   % EndOfGame : variable qui sera liée à true si c'est la fin du jeu, et à false sinon
   % State =  state(posPac:PosPac posG:PosG posB:PosB pos:PosP m:Mode hT:HuntTime pacT:PacTime gT:GTime bT:BTime pT:PTime
   fun {KillPacman IdGhost ListPacmans EndOfGame State}
      PortPac
      
   in
      {System.show "IDGhost"}
      {System.show IdGhost}

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
		  EndOfGame = true
		  {AdjoinList State [posPac#nil]}
	       else
		  {KillPacman ghost(id:IdGhost.id color:IdGhost.color name:IdGhost.name) T  EndOfGame {AdjoinList State [posPac#{Delete IdPacman State.posPac}]}}
	       end % if
	    else 
         % renvoi du State dans lequel on a retiré IdPacman de posPac et ajouté dans pacTime
	       {KillPacman ghost(id:IdGhost.id color:IdGhost.color name:IdGhost.name) T  EndOfGame {AdjoinList State [posPac#{Delete IdPacman State.posPac} pacT#{Append State.pacT [IdPacman#(Input.respawnTimePacman *(Input.nbPacman + Input.nbGhost))]}]}}
	    end % if
	 end %local
      [] nil then
	 EndOfGame = false
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
      {Send WindowPort scoreUpdate(IdCheck NewScore)}
      State
   end

    %Un bonus est attrapé, toutes les actions correspondantes sont réalisées.
   fun{WinBonus Id Bonus State}
      {Send WindowPort hideBonus(Bonus)}
      {Diffusion PortsPacman bonusRemoved(Bonus)}
      {Diffusion PortsPacman setMode(hunt)}
      {Diffusion PortsGhost setMode(hunt)}
      {Send WindowPort setMode(hunt)}
      {AdjoinList State [m#hunt hT#((Input.huntTime)*(Input.nbPacman + Input.nbGhost))]}
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
	    if(NewScore > Max) then {PointMax NewScore ID T}
	    else {PointMax Max MaxId T}
	    end
	 []nil then MaxId
	 end
      end
   in
      Vainqueur ={PointMax 0 nil PortsPacman}
      {Send WindowPort displayWinner(Vainqueur)}
      State
   end

   /*Demande au pacman sa nouvelle position,
   préviens les ghost et le déplace sur la map*/
   % Id est de type <pacman>
   fun{MovePacman Id NewPos State}
      IdCheck in
      {Send {List.nth PortsPacman Id.id} move(IdCheck NewPos)}
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
      if(IdCheck == null) then

	 State
      else
	 {Diffusion PortsPacman ghostPos(IdCheck NewPos)}
	 {Send WindowPort moveGhost(IdCheck NewPos)}
	 {AdjoinList State [posG#{Append {Delete IdCheck State.posG} [IdCheck#NewPos]}]}
      end
   end

   proc {ServerProc Msg State}
      {Browser.browse Msg} 
      {Browser.browse State}
      {Delay 1000}
      case Msg 
      of decPacman|T then {ServerProc T {DecPacman State}} %Flo c'est fait
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
      [] killPacman(IdGhost ListPacmans EndOfGame)|T then {System.show State}{ServerProc T {KillPacman IdGhost ListPacmans EndOfGame State}}%IdPacman c'est la victime Messages a envoyer voir commentaires + retirer pacman de posP + ajouter dans pacTime (en focntion du nombre de vie qu'il a)    [] pointOn(Pos ?Point)|T then {ServerProc T {PointOn Pos ?Point State}} %Flo c'est fait
      [] winPoint(Id Point )|T then {ServerProc T {WinPoint Id Point State }}  %Flo c'est fait
      [] bonusOn(Pos ?Point)|T then {ServerProc T {BonusOn Pos ?Point State }} %Flo c'est fait
      [] winBonus(Id Bonus)|T then {ServerProc T {WinBonus Id Bonus State}} %Flo c'est fait
      [] killGhost(IdPacman ListGhosts) |T then {ServerProc T {KillGhost IdPacman ListGhosts State}}
      [] whoWin|T then {ServerProc T {WhoWin State}} %Flo ok
      end
   end


   proc{ClientFonc Msg Server}
      case Msg 
      of 0 then
	 for I in Sequence do % Sequence =  id ghost et id pacmans melanges

        {Send Server decPacman} %TODO 
        {Send Server decGhost}
        {Send Server decPoint}
         {Send Server decBonus}
         {Send Server decHunt}
         {Delay 2000}
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
				     local EndOfGame IdGHost in
                     IdGHost ={List.nth Liste ({OS.rand} mod {List.length Liste})+1}
                     {System.show "killPacman valeur de IDGHost"}
                     {System.show IdGHost}

				        {Send Server killPacman(IdGHost [I]  EndOfGame)} /*IdGhost =  Un random sur un élément de la liste pour savoir qui on prends*/
				      if(EndOfGame) then
				       {ClientFonc 1 Server}
				    end % if
				 end % local
			      end % if
			   end %  local
			else %mode hunt
			   local Liste in
			      {Send Server ghostOn(NewPos Liste)}
               %{Browser.browse Liste}
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
			      {Send Server winBonus(I Bonus)}
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
               %{Browser.browse Liste}
			      if(Liste \= nil) then
				 local EndOfGame in

                     {System.show "killPacman valeur de IDGHost"}
                     {System.show I}
				    {Send Server  killPacman(I Liste EndOfGame)} %La meme qu'au dessus dans case pacman
				    if(EndOfGame) then
				       {ClientFonc 1 Server}
				    end % if
				 end % local
			      end % if
			   end % local
			else % Mode hunt
			   local Liste in
			      {Send Server pacmanOn(NewPos ?Liste)}
               %{Browser.browse Liste}
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
	 {ClientFonc 0 Server}
      [] 1 then %fin du jeu
	 {Send Server whoWin}
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
       	    {Send PortsPacman.1 spawn(_ _)}
       	    {Send WindowPort spawnPacman(IdPacman.1 S)}
      	    {Diffusion PortsGhost pacmanPos(IdPacman.1 S)} % Diffusion du spawn aux ghosts
       	 end %TODO Verifier les valeurs ID et P
       end


       if ({List.length PortsGhost} > 1) then
       	 for Port in PortsGhost do
       	    local R P ID S in
       	       {Send Port getId(R)}
       	       {Send WindowPort initGhost(R)}
       	       S = {List.nth ListSpawnGhost R.id} 
       	       {Send Port assignSpawn(S)}
       	       {Send Port spawn(ID P)} % TODO : vérifier les valeurs ID et P
       	       {Send WindowPort spawnGhost(R S)}
       	       {Diffusion PortsPacman ghostPos(R S)} % Diffusion du spawn aux pacmans
       	    end
       	 end
       else
       	 local ID P S in
       	    {Send WindowPort initGhost(IdGhost.1)}
       	    S = {List.nth ListSpawnGhost ({OS.rand} mod {List.length GSList})+1 }
       	    {Send PortsGhost.1 assignSpawn(S)}
       	    {Send PortsGhost.1 spawn(ID P)}
       	    {Send WindowPort spawnGhost(IdGhost.1 S)}
       	    {Diffusion PortsPacman ghostPos(IdGhost.1 S)} % Diffusion du spawn aux pacmans
       	 end
       end
      
       if(Input.isTurnByTurn) then
       	 local
       	    PosP PosG in
       	    PosP = {SpawnToIdPos IdPacman ListSpawnPacman} 
       	    PosG = {SpawnToIdPos IdGhost ListSpawnGhost}
       	    Server = {NewPortObjectServer PosP PosG PointList BonusList classic 0 nil nil nil nil } % à compléter
              % {NewPortObjectServer PosP PosG PosPo PosB Mode HuntTime PacTime GTime BTime PTime}
       	 end %local

	 {ClientFonc 0 Server}

      %MODE SIMULATNE MODE SIMULTANE MODE SIMULTANE
      %else 
      end

   end

end
