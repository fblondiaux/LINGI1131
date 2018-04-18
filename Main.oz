functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   CreatePortPacman
   CreatePortGhost
   CreateIDs

   WindowPort

   PortsPacman
   PortsGhost
   IdPacman %
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
	       case Pacman of H|T then
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
      case L of H|T then
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


      % bouger un pacman
      local ID P in
      {Send PortsPacman.1 move(ID P)}
            {Delay 1000}
      {Send WindowPort movePacman(IdPacman.1 P)}
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
