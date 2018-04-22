% structure du doc à l'intérieur du in :

/*
in
   % additionnal functions
   thread
      % ports
      % open window
      % TODO
   end
end

*/

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



   WindowPort

   PortsPacman
   PortsGhost
   IdPacman
   IdGhost
   MapRecord

   Sequence %List containing IDs in which we're gonna play. (Suffle applied on IdPacman and IdGhost)
   PointList
WallList
PSList % pacman spawn list
GSList % ghost spawn list
BonusList

Diffusion
AssignRandom

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

   /* Fuction who transform a map into 4 lists of positions
   In : Nothing -> we take Input.Map
   Out : Gives a record with four list of <positions>, each position have been initialised.
   Bonus and points are now visible on the map. Spawn have been created (but not assigned to a pacman/ghost */
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

   /* Donne des positions aléatoires acceptables pour un pacman ou un ghost
   In : map, nombre de lignes, nombre de colonnes, et valeur acceptable (2 pour pacman, 3 pour ghost)
   Out : un position <position>
   */
   % Renvoie un élément aléatoire de la liste (utile par exemple pour assigner un spawn random)
   % In : la liste
   fun {AssignRandom Liste}
      N
   in
      N = {List.length Liste}
      {List.nth Liste ({OS.rand} mod N)+1}
   end

  /* state(who:QuiVAJouer posP: PositionDesPacmans posG: PositionGhost posB:Listepositiondesbonus posP:Listepositionpoints mode: Mode(0=normal 1 =hunt) huntTime:(-1 -> on fait rien, 0 on swich mode vers normal, X = nb de tours restants) pacTime: (liste de pt + nombre de tours) gTime: pointTime: bTime:)

fun{Play State}
   local State1 State2 State in
      %Verification HuntTime
      case State.huntTime of 0 then
	 State1 = {AdjoinList State [huntTime#~1 mode#0]}
      [] -1 then
	  State1 = {AdjoinList State [huntTime#~1 mode#0]}
      else
	  State1 = {AdjoinList State [huntTime#State.huntTime-1 mode#1]}
      end


      case State1.pacTime of H|T then




   end%endlocal
end%end Play

*/


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

      % Initialisation des pacmans et ghosts
      % Initialisation des spawns pour les pacmans et les ghosts
      % Affichage des pacmans et des ghosts



      if {List.length PortsPacman} > 1 then

      for X in PortsPacman do
   	    local R ID P S in
   	       {Send X getId(R)}
   	       {Send WindowPort initPacman(R)}
   	       S = {AssignRandom PSList} % position d'un Spawn aléatoire
   	       % TODO : verifier qu'on ne dépasse pas la limite de pacmans/ghosts par spawns
   	       {Send X assignSpawn(S)}
   	       {Send X spawn(ID P)}
   	       if ID== null then {Browse 'erreur spawn pacman'} end % TODO : vérifier si null = nil?
   	       {Send WindowPort spawnPacman(R S)}
   	    end
         end
      else
      local ID P S in
   	    {Send WindowPort initPacman(IdPacman.1)}
   	    S = {AssignRandom PSList}
   	    {Send PortsPacman.1 assignSpawn(S)} % Comment savoir sur quels points on peux spawn ?
   	    {Send PortsPacman.1 spawn(ID P)}
   	    {Send WindowPort spawnPacman(IdPacman.1 S)}
   	 end %TODO Verifier les valeurs ID et P
      end



      if ({List.length PortsGhost} > 1) then
         for Y in PortsGhost do
         local R ID P S in
   	       {Send Y getId(R)}
   	       {Send WindowPort initGhost(R)}
   	       S = {AssignRandom GSList} % TODO : verifier qu'on ne dépasse pas la limite de pacmans/ghosts par spawns
   	       {Send Y assignSpawn(S)}
   	       {Send Y spawn(ID P)}
   	       {Send WindowPort spawnGhost(R S)}
   	       %TODO Verifier les valeurs ID et P

            end
         end
      else
      local ID P S in
	 {Send WindowPort initGhost(IdGhost.1)}
	 S = {AssignRandom GSList}
         {Send PortsGhost.1 assignSpawn(S)}
	 {Send PortsGhost.1 spawn(ID P)}
	 {Send WindowPort spawnGhost(IdGhost.1 S)}
         end
      end



%Une fonction que l'on appelle récursivement.
%     Prends en argument un state et retourne un state.
%     Le record state contiendrait:
%         %Un champ qui nous permettrait de savoir quel est le joueur (À qui le tour par exemple pacman1) : c'est un nombre, incrémenté (avec modulo) et on appelle le n-eme nombre de la liste pour jouer.
%         %Plusieurs champs, un par pacman avec sa position.
%         %Plusieurs champs, un par ghost avec sa position.
%         %Liste avec les positions des  bonus
%         %Liste avec les positions des points
%         %Mode du jeu
%         %Un champ que l'on décrémente avec le hunt time. Quand il vaut 0 -> le mode est mis à normal et on passe la valeur à -1 pour dire qu'il ne faut rien faire.
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimePoint (Quand il vaut 0 -> On spawn un nouveau point) Cas particulier: plus de place sur la board.
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimeBonus (Quand il vaut 0 -> On spawn un nouveau point) Cas particulier: plus de place sur la board.
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimePacman (Quand il vaut -1 -> On ne fait rien, Quand un pacman meurt on le met à respawnTimePacman et on décrémente quand c'est égal à 0 on respawn le pacman.)
%         %Liste avec à chauqe fois un champ que l'on décrémente avec le respawnTimeGhost (Quand il vaut -1 -> On ne fait rien, Quand un pacman meurt on le met à respawnTimeGhost et on décrémente quand c'est égal à 0 on respawn le pacman.)
%
%     Etapes de cette fonction.
%       %
%       %Décrementer ce qui doit l'etre (respawnTime...(5)
%              %Si certaines valeurs sont arrivée au bout -> faire les actions correspondante
%              %Quand un pacman(resussite) de respawnTimePacman arrive à 0 -> (ressusite) spawn(?ID ?P) + (Ghosts) PacmanPos() +GUI spawnPacman(ID P)
%              %Quand un ghost(resussite) de respawnTimePacman arrive à 0 -> (ressusite) spawn(?ID ?P) + (PacmanS) PacmanPos() +GUI spawnGhost(ID P)
%              %Quand le respawnTimeBonus arrive à échéance -> on random une position libre pour le bonus. (Pacmans) bonusSpawn(P) + GUI initBonus + GUI spawnBonus
%              %Quand le respawnTimePoint arrive à échéance -> on random une position libre pour le point. (Pacmans) pointSpawn(P) + GUI initPoint(P) + GUI spawnPoint(P)
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
