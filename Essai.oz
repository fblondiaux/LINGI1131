
/*
Dans la MAIN : (idee generale)
	   
- Creation des ports des pacmans, ghosts, initialisation de la map, ...

MODE TURN BY TURN
- creation d'un NewPortObject pour le server : Server={NewPortObjectServer ServerProc}
- local Vainqueur in Vainqueur = {ClientFonc jouer}


MODE SIMULTANE :
- creation d'un NewPortObject pour le server : Server={NewPortObjectServer ServerProc}
- creations des clients : chaque joueur est un client.
- creation de un thread par client et dans chaque thread : appel de la fonction du client pour jouer

--> dans ce mode, il n'y a rien à decrementer (à la place : {Delay..}, ce qui simplifie ServerProc


*/

declare

fun {NewPortObjectServer PosP PosG PosPo PosB Mode HuntTime PacTime GTime BTime PTime}
   Stream Port
in
   {NewPort Stream Port}
   thread
						       <position>|<position>	 un nombre		   <ghost>#<Nombre>|...
       {ServerProc Stream state(posPac:PosPac posG:PosG posB:PosB pos:PosP m:Mode ht:HuntTime pact:PacTime gt:GTime bt:BTime pt:PTime)
				Id#pt()|T    <Ghost>#<position>|...       classic ou hunt    <pacman>#<Nombre>|..   <position>#<Nombre>|...
		%On dec que si plus grand que 1 huntime
   end
   Port
end

fun {ChangeMode State}
  if(State.mode == classic) then
  {AdjoinList State [ mode#hunt]}
  else
  {AdjoinList State [ mode#hunt]}
  end
end

proc {ServerProc Msg State}
   case Msg 
   of decrementer|T then {ServerProc T {Decrementer State}} %Flo
   [] movePacman(Id ?NewPos)|T then %TODO %Noemie
   [] changeMode|T then {ServerProc T {ChangeMode State}} %Flo
   [] ghostOn{Pos ?List}|T then {ServerProc T {GhostOn State}}%Parcours posG, retourne une liste des <ghost> sur cette case.
   [] killPacman(IdPacman IdGhost ?endOfGame)|T then {ServerProc T {KillPacman State}}%IdPacman c'est la victime Messages a envoyer voir commentaires + retirer pacman de posP + ajouter dans pacTime (en focntion du nombre de vie qu'il a)
   [] pointOn(pt ?pt)|T then {ServerProc T {PointOn State}}
   [] winPoint(Id pt)|T then {ServerProc T {WinPoint State}}
   [] winBonus(Id pt)|T then {ServerProc T {WinBonus State}}
   [] bonusOn(pt ?pt)|T then {ServerProc T {BonusOn State}}
   [] killGhost(IdPacman ListGHos ...) |T then {ServerProc T {KillGhost State}}
   [] pacmanOn(pos ?List)|T then {ServerProc T {PacmanOn State}}
   [] whoWin(?Vainqueur)|T then {ServerProc T {WhoWin State}}
   end
end


/*
Principe :
- Un appel recursif est un tour de jeu, où chaque joueur joue.
- Avant qu'un joueur ne joue, on regarde si le mode Hunt est mis, on decremente ce qui doit l'être,... --> même structure qu'avant
- La difference est que pour chaque action qu'on veut faire, on envoie le message correspondant au port du server.
- Le port du server voit alors qu'il a recu un message, fait l'action et par là même modifie son etat interne (= state(...), qui correspond à notre state d'avant)

Avantage : le code est plus clair, plus structure, plus propre, et plus simple aussi. 
*/
fun {ClientFonc Msg}
   case Msg
   of 0 then
      {Send Server decrementer}
      for I in Liste do  ->Liste = Sequence =  id ghost et id pacmans melanges
     case I of
        pacman(id:Id color:_ name:_) then
           %BOUGER PACMAN
           %Envoyer au server {Send Server movePacman(Id ?NewPos)} -> {Send Port move(IdCheck Pos)} Port = {List.nth PortsPacman Id} (GhostS) pacmanPos(ID P) + GUI movePacman(ID P) + Change l'etat -> liste des pacmans s'actualise posP
           %Case if IdCheck == null -> le pacman est mort -> on s'arrete la.
        if(NewPos != null) then
          %Mode hunt ? -> envoyer un message a server.
           if(classic) then
             %{Send Server ghostOn{Pos ?List}}
          if(List != nil) then
            %Killer = take random de List.
            %{Send Server killPacman(IdPacman IdGhost ?endOfGame)} %IdPacman c'est la victime Messages a envoyer voir commentaires + retirer pacman de posP + ajouter dans pacTime
             if(endOfGame) then
            {ClienFonc 1}
             end
          end
           else %mode hunt
          %%{Send Server ghostOn{Pos ?List}}
          if(List != nil) then
            %{Send Server killGhost(IdPacman ListGhosts)} -> les ghost meurent, tous les messgaes dans commentaires +  retirer ghosts de posG + ajouter dans Gtime
          end       
           end
          %Points et bonus
           {Send Send pointOn(pt ?pt)} %Si il y a un point sur la case il le retire de la liste(et le renvoie) l'ajoute dans les points à respawn
           if(pt!= nil) then %ou null ?
          {Send Server winPoint(Id pt)} % Faire gager le point + prévenir les autre + update + aller voir commentaires
           end
           {Send Send bonusOn(pt ?pt)} %Si il y a un point sur la case il le retire de la liste(et le renvoie) l'ajoute dans les points à respawn
           if(pt!= nil) then %ou null ?
          {Send Server winBonus(Id pt)} % Faire gager le point + prévenir les autre + updateLaListeDesBonus + mode(hunt) + remettre le temps a temps hunt + aller voir commentaires
           end
        end %If pos ! null
        
     []ghost(id:Id color:_ name:_) then
         %BOUGER GHOST
           %Envoyer au server {Send Server moveGhost(Id ?NewPos)} -> {Send Port move(IdCheck Pos)} Port = {List.nth PortsGhost Id}voir messages dans commentaires + Change l'etat -> liste des ghost s'actualise posG
           %Case if IdCheck == null -> le ghost est mort -> on s'arrete la.
        if(NewPos ~= nil) then
           if(classic) then
          {Send Server pacmanOn(pos ?List)}
          if(List ~= nil) then
             {Send Server killPacmanList} %La meme qu'au dessus dans case pacman
             if(endOfGame) then
            {ClienFonc 1}
             end
          end
          %RIEN A FAIRE
           else % hUNt
          {Send Server pacmanOn(pos ?List)}
          if(List ~= nil) then
             %-> Random dans la liste le tueur.
             {Send Server killGHost  }%La meme qu'au dessus
          end
           end
        end
        
     end
      end % for
      local X in
     {Send Server fin(X)}
     {Wait X}
     if X == true then {ClientProc fin}
     else
        {ClientProc jouer}
     end
      end
   [] 1 then %fin du jeu
      {Send Server whoWin(?Vainqueur)}
   end
end
   
	 
      
   


   
