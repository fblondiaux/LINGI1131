functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   WindowPort
in

   % TODO add additionnal function

   thread
      % Create port for window
      WindowPort = {GUI.portWindow}

      % Open window
      {Send WindowPort buildWindow}

      {Send WindowPort initPacman(pacman(id:1 color:Input.colorPacman.1 name:Input.pacman.1))}
      {Send WindowPort initPacman(pacman(id:2 color:Input.colorPacman.2.1 name:Input.pacman.2.1))}
      {Send WindowPort initGhost(ghost(id:1 color:Input.colorGhost.1 name:Input.ghost.1))}
      {Send WindowPort spawnPacman(pacman(id:1 color:Input.colorPacman.1 name:Input.pacman.1) pt(x:4 y:6))}
      {Send WindowPort spawnPacman(pacman(id:2 color:Input.colorPacman.2.1 name:Input.pacman.2.1) pt(x:8 y:6))}
      {Send WindowPort spawnGhost(ghost(id:1 color:Input.colorGhost.1 name:Input.ghost.1) pt(x:6 y:2))}
   end
end
