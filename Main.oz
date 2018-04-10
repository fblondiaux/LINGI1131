functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   WindowPort
   Pacman1
   Pacman2
in

   % TODO add additionnal function

   thread
      % Create port for window
      WindowPort = {GUI.portWindow}

      % Open window
      {Send WindowPort buildWindow}

      
      % exemple
      Pacman1 = pacman(id:1 color:Input.colorPacman.1 name:Input.pacman.1)
      Pacman2 = pacman(id:2 color:Input.colorPacman.2.1 name:Input.pacman.2.1)
      
      {Send WindowPort initPacman(Pacman1)}
      {Send WindowPort initPacman(Pacman2)}
      {Send WindowPort initGhost(ghost(id:1 color:Input.colorGhost.1 name:Input.ghost.1))}
      {Send WindowPort spawnPacman(Pacman1 pt(x:4 y:6))}
      {Send WindowPort spawnPacman(Pacman2 pt(x:8 y:6))}
      {Send WindowPort spawnGhost(ghost(id:1 color:Input.colorGhost.1 name:Input.ghost.1) pt(x:6 y:2))}

      % bouger un pacman
      {Delay 4000}
      {Send WindowPort movePacman(Pacman1 pt(x:5 y:6))}
      {Delay 2000}
      {Send WindowPort movePacman(Pacman1 pt(x:6 y:6))}

      % hide a pacman
      {Delay 2000}
      {Send WindowPort hidePacman(Pacman1)}

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
