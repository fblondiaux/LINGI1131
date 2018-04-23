
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


proc {ServerProc Msg State}
   case Msg
   of decrementer|T then {ServerProc T {Decrementer State}}
   [] jouer|T then {ServerProc T {Jouer State}}
   [] changeMode|T then {ServerProc T {ChangeMode State}}
   []...
   [] fin(X)|T then {ServerProc T {Fin(X) State}} 
   [] donneVainqueur(V)|T then {ServerProc T {DonneVainqueur(V) State}}  
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
   of jouer then
      {Send Server decrementer}
      for I in Liste do  ->Liste = Sequence =  id ghost et id pacmans melanges
	 local X in
	    {Send Server isHuntMode(X)}

	 
	 if JoueurPacman /*à changer*/ then
		move
	    if X then
	       ...
	    else
	       ...
	    end
	 else
	    if X isModeHunt then
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
	 end
   [] fin then
      ...
   end
end

   
	 
      
   


   
