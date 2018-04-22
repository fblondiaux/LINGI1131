
/*
Dans la MAIN : (idée générale)
	   
- Création des ports des pacmans, ghosts, initialisation de la map, ...

MODE TURN BY TURN
- création d'un NewPortObject pour le server : Server={NewPortObjectServer ServerProc}
- local Vainqueur in Vainqueur = {ClientFonc jouer}


MODE SIMULTANE :
- création d'un NewPortObject pour le server : Server={NewPortObjectServer ServerProc}
- créations des clients : chaque joueur est un client.
- création de un thread par client et dans chaque thread : appel de la fonction du client pour jouer

--> dans ce mode, il n'y a rien à décrémenter (à la place : {Delay..}, ce qui simplifie ServerProc


*/

declare
fun {NewPortObjectServer PosP PosG PosPo PosB Mode HuntTime PacTime GTime BTime PTime}
   Stream Port
in
   {NewPort Stream Port}
   thread
      {ServerProc Stream state(posP:PosP posG:PosG posB:PosB m:Mode ht:HuntTime pact:PacTime gt:GTime bt:BTime pt:PTime)
   end
   Port
end


proc {ServerProc Msg State}
   case Msg
   of décrémenter|T then {ServerProc T {Décrémenter State}}
   [] jouer|T then {ServerProc T {Jouer State}}
   [] changeMode|T then {ServerProc T {ChangeMode State}}
   []...
   [] fin(X)|T then {ServerProc T {Fin(X) State}} 
   [] donneVainqueur(V)|T then {ServerProc T {DonneVainqueur(V) State}}  
   end
end


/*
Principe :
- Un appel récursif est un tour de jeu, où chaque joueur joue.
- Avant qu'un joueur ne joue, on regarde si le mode Hunt est mis, on décrémente ce qui doit l'être,... --> même structure qu'avant
- La différence est que pour chaque action qu'on veut faire, on envoie le message correspondant au port du server.
- Le port du server voit alors qu'il a recu un message, fait l'action et par là même modifie son état interne (= state(...), qui correspond à notre state d'avant)

Avantage : le code est plus clair, plus structuré, plus propre, et plus simple aussi. 
*/
fun {ClientFonc Msg}
   case Msg
   of jouer then
      for I in Liste do % Liste = liste de rec(Ports Pac) ou rec(Ports G) : Pac indique que c'est le port d'1 pacman, et G d'un ghost
	 local X in
	    {Send Server isHuntMode(X)}
	    {Wait X}
	    if X == true then {Send Server huntTime} end
	 end
	 {Send Server décrémenter}
	 if JoueurPacman /*à changer*/ then
	    if isModeHunt then
	       ...
	    else
	       ...
	    end
	 else
	    if isModeHunt then
	       ...
	    else
	       ...
	    end
	 end % if
      end % for
      local X in
	 {Send Server fin(X)}
	 {Wait X}
	 if X == true then {ClientProc fin}
	 else
	    {ClientProc jouer}
	 end
      end
   [] fin then
      ...
   end
end

   
	 
      
   


   