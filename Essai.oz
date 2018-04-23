
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
						%      <position>|<position>	 un nombre		   <ghost>#<Nombre>|...
       {ServerProc Stream state(posPac:PosPac posG:PosG posB:PosB posP:PosP m:Mode ht:HuntTime pact:PacTime gt:GTime bt:BTime pt:PTime)}
			%Id#pt()|T    <Ghost>#<position>|...       classic ou hunt    <pacman>#<Nombre>|..   <position>#<Nombre>|...
		%On dec que si plus grand que 1 huntime
   end
   Port
end

/*Exchange the current state 
*/

/*
fun {ChangeMode State} 
  if(State.mode == classic) then
  {AdjoinList State [mode#hunt ht#Input.huntTime]}
  {Send WindowPort mode(hunt)}
  {Diffusion PortsGhost mode(hunt)} %Verifier
  {Diffusion PortsPacman mode(hunt)}
  else
  {AdjoinList State [mode#classic]}
  {Send WindowPort mode(classic)}
  {Diffusion PortsGhost mode(classic)} %Verifier
  {Diffusion PortsPacman mode(classic)}
  end
end
*/
/*
fun{PointOn Pt Ret State}
  if({List.member Pt State.posP}) then %Si p est dans la liste posP
    Ret = Pt  
    {AdjoinList State [posP#{List.subtract State.posP Pt} pt#{List.append State.pt [Pt]]}
  else 
    Ret = null %Attention peutêtre à changer
    State
  end
end

fun{GhostOn Pos Ret State} %On ne retire pas les ghost de l'état, l'état n'est pas modifié
  fun{GhostOnLoop Pos List}
    case List of H|T then
      if(H == Pos) then H|{GhostOnLoop Pos T}
      else {GhostOnLoop Pos T}
      end
    []nil then nil
    end
  end
  in 
  Ret = {GhostOnLoop Pos State.posG}
  State
end


fun{PacmanOn Pos Ret State} %On ne retire pas les pacman de l'état, l'état n'est pas modifié
  fun{PacmanOnLoop Pos List}
    case List of H|T then
      if(H == Pos) then H|{PacmanOnLoop Pos T}
      else {PacmanOnLoop Pos T}
      end
    []nil then nil
    end
  end
  in 
  Ret = {PacmanOnLoop Pos State.posPac}
  State
end



fun{BonusOn Pt Ret State}
  if({List.member Pt State.posB}) then %Si p est dans la liste posP
    Ret = Pt  
    {AdjointList State [posB#{List.subtract State.posB Pt} bt#{List.append State.bt [Pt]]}
  else 
    Ret = null %Attention peutêtre à changer
    State
  end
end
*/
proc {ServerProc Msg State}
   case Msg 
   of decrementer|T then {ServerProc T {Decrementer State}} %Flo
   [] movePacman(Id ?NewPos)|T then %TODO %Flo
   [] changeMode|T then {ServerProc T {ChangeMode State}} %Flo A verifier il doit surement y avoir un argument
   [] ghostOn{Pos ?List}|T then {ServerProc T {GhostOn Pos List State}}%Flo - C'est fait
   [] killPacman(IdPacman IdGhost ?endOfGame)|T then {ServerProc T {KillPacman State}}%IdPacman c'est la victime Messages a envoyer voir commentaires + retirer pacman de posP + ajouter dans pacTime (en focntion du nombre de vie qu'il a)
   [] pointOn(Pt ?Ret)|T then {ServerProc T {PointOn Pt ?Ret State}} %Flo - C'est fait
   [] winPoint(Id Pt)|T then {ServerProc T {WinPoint State}}%todo Flo
   [] winBonus(Id Pt)|T then {ServerProc T {WinBonus State}}%todo Flo
   [] bonusOn(Pt ?Ret)|T then {ServerProc T {BonusOn Pt ?Ret State}} %Flo - C'est fait
   [] killGhost(IdPacman ListGHos ...) |T then {ServerProc T {KillGhost State}}
   [] pacmanOn(pos ?List)|T then {ServerProc T {PacmanOn State}} %Flo c'est fait
   [] whoWin(?Vainqueur)|T then {ServerProc T {WhoWin State}}%TODO FLO
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
      {Send Server decrementer}djoinList State [mode#classic]}
  
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
           {Send Send pointOn(Pt ?Pt)} %Si il y a un point sur la case il le retire de la liste(et le renvoie) l'ajoute dans les points à respawn
           if(Pt!= nil) then %ou null ?
          {Send Server winPoint(Id Pt)} % Faire gager le point + prévenir les autre + update + aller voir commentaires
           end
           {Send Send bonusOn(Pt ?Pt)} %Si il y a un point sur la case il le retire de la liste(et le renvoie) l'ajoute dans les points à respawn
           if(Pt!= nil) then %ou null ?
          {Send Server winBonus(Id Pt)} % Faire gager le point + prévenir les autre + updateLaListeDesBonus + mode(hunt) + remettre le temps a temps hunt + aller voir commentaires
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
   
	 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BROUILLON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% coucou
      
   


   
