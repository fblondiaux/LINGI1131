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

   WindowPort

   PortsPacman
   PortsGhost
   IdPacman
   IdGhost
   Sequence %List containing IDs in which we're gonna play. (Suffle applied on IdPacman and IdGhost)
   X
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
     case Ghost of nil then nil
       else {PlayerManager.playerGenerator Ghost.1 ghost(id:ID color:Color.1 name:Name.1)}|{CreatePortGhostFull Ghost.2 Color.2 Name.2 ID+1}
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

   thread
      % Create port for window
      WindowPort = {GUI.portWindow}
      % Open window
      {Send WindowPort buildWindow}

      %Create Ports
      {CreatePortPacman PortsPacman}
      {CreatePortGhost PortsGhost}
      IdPacman = {CreateIDs PortsPacman}
      IdGhost = {CreateIDs PortsGhost}
      Sequence = {Shuffle IdPacman IdGhost}

      %Init and spawn the pacman.
      for X in PortsPacman do
      local R ID P
      in
        {Send X getId(R)}
        {Send WindowPort initPacman(R)}
        {Send WindowPort spawnPacman(R pt(x:4 y:6))}
        {Send X assignSpawn(pt(x:4 y:6))} % Comment savoir sur quels points on peux spawn ?
        {Send X spawn(ID P)}

      end
      end

      %Init and spawn the ghost.
      for Y in PortsGhost do
      local R ID P
      in
        {Send Y getId(R)}
        {Send WindowPort initGhost(R)}
        {Send WindowPort spawnGhost(R pt(x:8 y:6))}
        {Send X assignSpawn(pt(x:8 y:6))} % Comment savoir sur quels points on peux spawn ?
        {Send X spawn(ID P)}

      end
      end



%Todo Ajouter ici l'initialisation des points et des bonus.

%J'ajouterais un port sur lequel on envoie des messages.
%   Ce port permettrait entre autre de savoir si on est sur un bonus.
%   Savoir si on est sur un point. (Aucune idée de comment gerer ça...) En plus à chauque fois que quelqu'un mange un bonus on doit prévenir tout les pacmans.
%   Savoir si un ghost ou un pacman se trouve sur la même place.

%Une fonction que l'on appelle en boucle.
%     Prends en argument un state et retourne un state.
%     Le record state contiendrait:
%         %Un qui nous permettrait de savoir quel est le joueur (À qui le tour par exemple pacman1)
%         %Plusieurs champs, un par pacman avec sa position.
%         %Plusieurs champs, un par ghost avec sa position.
%         %Liste avec les positions des points bonus
%         %Liste avec les positions des points
%         %Mode du jeu
%         %Un champ que l'on décrémente avec le respawnTimePoint (Quand il vaut 0 -> On spawn un nouveau point) Cas particulier: plus de place sur la board.
%         %Un champ que l'on décrémente avec le respawnTimeBonus (Quand il vaut 0 -> On spawn un nouveau point) Cas particulier: plus de place sur la board.
%         %Un champ que l'on décrémente avec le respawnTimePacman (Quand il vaut -1 -> On ne fait rien, Quand un pacman meurt on le met à respawnTimePacman et on décrémente quand c'est égal à 0 on respawn le pacman.)
%         %Un champ que l'on décrémente avec le respawnTimeGhost (Quand il vaut -1 -> On ne fait rien, Quand un pacman meurt on le met à respawnTimeGhost et on décrémente quand c'est égal à 0 on respawn le pacman.)
%         %Pour le respawnTimeGhost et respawnTimePacman comment faire quand plusieurs pacmans meurent à un ou deux tours d'écart et que le respawnTimePacman n'est pas écoulé.
%
%     Etapes de cette fonction.
%       %Décrementer ce qui doit l'etre (respawnTime...(4) si il y en à. )
%           %Si certaines valeurs sont arrivée au bout -> faire les actions correspondante
%           %A détailler
%       %Si le joueur est un pacman
%         %Vérifier si il y à point sur la case courrante. %On prends quand même le point si le pacman va se faire tuer ?
%               %Envoyer un message au pacman pour dire qu'il à un point
%               %Envoyer un message au GUI pour dire que le point à disparu.
%         %Vérifier si il y à un bonus sur la case. %Pareil comment réagir si il y à 1 ghost et un bonus sur la même case
%               %Changer le mode si besoin.
%         %Si mode normal
%               %Vérifier si le pacman est sur la case d'un ghost -> Pacman meurt= envoyer les messages correspondants.
%                       %Cas particulier à aprofondir, plusieurs ghost sur une même case qui prends le point.
%         %Si mode Hunt.
%               %Vérifier si le pacman est sur la case d'un ghost -> Pacman meurt= envoyer les messages correspondants.
%                       %Cas particulier à aprofondir, plusieurs ghost sur une même case qui prends le point.

of nil then 
[] H|T then
end

      % bouger un pacman
      local ID in
      {Send WindowPort movePacman(IdPacman.1 pt(x:6 y:6))}
      end
      {Delay 2000}
      {Send WindowPort movePacman(IdPacman.2.1 pt(x:6 y:6))}

      % hide a pacman
      {Delay 2000}
      {Send WindowPort hidePacman(IdPacman.2.1)}


%%% mode turn by turn
      % déterminer aléatoirement l'ordre entre tous les pacmans et les ghosts.
      % Leurs assigner des positions et initialiser le GUI (Graphical User Interface)
      % Puis partie principale : boucles où chaque joueur joue à son tour (bouge si possible)
      % Fin : tous les pacmans ont perdu toutes leurs vies.

%%% mode simultaneous
      % Initialisation (emplacements, initialisation GUI)
      % ...


   end
end
